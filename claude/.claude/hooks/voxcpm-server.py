# /// script
# requires-python = ">=3.10,<3.13"
# dependencies = ["voxcpm", "soundfile"]
# ///
"""VoxCPM TTS daemon for Claude Code speak notifications.

Loads the VoxCPM2 model once and serves synthesis over localhost HTTP.
speak-notification.ts calls this before falling back to piper.

  GET  /health -> {"status": "ok", "model_loaded": true, "profiles": [...]}
  POST /speak  {"text": "...", "profile": "success"}
               -> {"wav_path": "/tmp/claude-voxcpm-<ms>.wav", "elapsed_ms": N}

Run: uv run --script voxcpm-server.py [--check-deps]
Managed by launchd: com.alistairstead.claude-voxcpm
"""

import argparse
import glob
import json
import os
import random
import re
import sys
import threading
import time
from http.server import BaseHTTPRequestHandler, ThreadingHTTPServer
from pathlib import Path

CONFIG_PATH = Path(__file__).resolve().parent / "voxcpm-voices.json"
MODEL_ID = "openbmb/VoxCPM2"
TMP_PREFIX = "/tmp/claude-voxcpm-"
TMP_MAX_AGE_S = 3600


def load_config() -> dict:
    with open(CONFIG_PATH) as f:
        return json.load(f)


def voices_dir(config: dict) -> Path:
    return Path(os.path.expanduser(config.get("voicesDir", "~/.local/share/voxcpm-voices")))


# The only tags the model renders as sounds; anything else is read aloud
# literally. Mirrors the NONVERBAL_PATTERN in the model's reference
# implementations (vllm-omni, mlx-audio). All lowercase.
VALID_TAGS = {
    "[laughter]", "[sigh]", "[confirmation-en]",
    "[question-en]", "[question-ah]", "[question-oh]", "[question-ei]", "[question-yi]",
    "[surprise-ah]", "[surprise-oh]", "[surprise-wa]", "[surprise-yo]",
    "[dissatisfaction-hnn]",
}


def inject_tag(text: str, profile_cfg: dict, force: bool = False) -> str:
    tag = profile_cfg.get("tag")
    if not tag:
        return text
    if tag not in VALID_TAGS:
        print(f"skipping unknown tag {tag} (would be spoken literally)", flush=True)
        return text
    if not force and random.random() >= profile_cfg.get("tagProbability", 0):
        return text
    placement = profile_cfg.get("tagPlacement")
    if placement == "end":
        return f"{text} {tag}"
    if placement == "after-first-clause":
        # Insert after the first dash/sentence boundary; fall back to start.
        m = re.search(r"[–—-]\s|[.!?]\s", text)
        if m:
            return f"{text[: m.end()]}{tag} {text[m.end() :]}"
    return f"{tag} {text}"


def gc_tmp_wavs() -> None:
    cutoff = time.time() - TMP_MAX_AGE_S
    for f in glob.glob(f"{TMP_PREFIX}*.wav"):
        try:
            if os.path.getmtime(f) < cutoff:
                os.unlink(f)
        except OSError:
            pass


class Synthesizer:
    def __init__(self) -> None:
        from voxcpm import VoxCPM

        # load_denoiser=False: the denoiser fetches from modelscope.cn (unreachable
        # here) and only cleans noisy reference audio; ours is VoxCPM-generated.
        self.model = VoxCPM.from_pretrained(MODEL_ID, load_denoiser=False)
        self.sample_rate = getattr(self.model.tts_model, "sample_rate", 44100)
        self.lock = threading.Lock()

    def speak(self, text: str, profile: str, force_tag: bool = False) -> str:
        import soundfile as sf

        config = load_config()
        profiles = config.get("profiles", {})
        profile_cfg = profiles.get(profile) or profiles.get("default") or {}
        text = inject_tag(text, profile_cfg, force=force_tag)

        kwargs: dict = {
            "cfg_value": profile_cfg.get("cfgValue", 2.0),
            "inference_timesteps": profile_cfg.get("inferenceTimesteps", 10),
            # No bad-case retry: a retry doubles latency past the hook's timeout,
            # so the hook would have fallen back to piper before it finished.
            "retry_badcase": False,
        }
        ref_wav = voices_dir(config) / "base.wav"
        if ref_wav.exists():
            # Clone via reference_wav_path (isolated ref_audio tokens), NOT
            # prompt_wav_path: prompt mode is continuation, where the model
            # reads "(control)" aloud because it lands mid-text-stream. With
            # a reference, the text stream starts at our "(control)" prefix
            # and the model interprets it as a style instruction.
            control = profile_cfg.get("styleInstruction", "")
            kwargs["text"] = f"({control}){text}" if control else text
            kwargs["reference_wav_path"] = str(ref_wav)
        else:
            # No reference yet: design per request from the base description.
            description = config.get("voice", {}).get("description", "")
            kwargs["text"] = f"({description}){text}" if description else text

        with self.lock:
            wav = self.model.generate(**kwargs)

        out_path = f"{TMP_PREFIX}{int(time.time() * 1000)}.wav"
        sf.write(out_path, wav, self.sample_rate)
        gc_tmp_wavs()
        return out_path


def make_handler(synth: Synthesizer):
    class Handler(BaseHTTPRequestHandler):
        def _json(self, code: int, body: dict) -> None:
            data = json.dumps(body).encode()
            self.send_response(code)
            self.send_header("Content-Type", "application/json")
            self.send_header("Content-Length", str(len(data)))
            self.end_headers()
            self.wfile.write(data)

        def do_GET(self) -> None:  # noqa: N802
            if self.path == "/health":
                try:
                    profiles = list(load_config().get("profiles", {}).keys())
                except Exception:
                    profiles = []
                self._json(200, {"status": "ok", "model_loaded": True, "profiles": profiles})
            else:
                self._json(404, {"error": "not found"})

        def do_POST(self) -> None:  # noqa: N802
            if self.path != "/speak":
                self._json(404, {"error": "not found"})
                return
            try:
                length = int(self.headers.get("Content-Length", 0))
                payload = json.loads(self.rfile.read(length))
                text = str(payload["text"]).strip()
                if not text:
                    raise ValueError("empty text")
                profile = str(payload.get("profile", "default"))
                t0 = time.time()
                # force_tag: testing/audition aid, bypasses tagProbability
                wav_path = synth.speak(text, profile, force_tag=bool(payload.get("force_tag")))
                self._json(200, {"wav_path": wav_path, "elapsed_ms": int((time.time() - t0) * 1000)})
            except Exception as e:  # never crash the daemon on a bad request
                self._json(500, {"error": str(e)})

        def log_message(self, fmt: str, *args) -> None:
            print(f"[{self.log_date_time_string()}] {fmt % args}", flush=True)

    return Handler


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument("--check-deps", action="store_true", help="import deps and exit (cache warm-up)")
    args = parser.parse_args()

    if args.check_deps:
        import soundfile  # noqa: F401
        import voxcpm  # noqa: F401

        print("deps ok")
        return

    port = load_config().get("port", 17865)
    print(f"loading {MODEL_ID}...", flush=True)
    t0 = time.time()
    synth = Synthesizer()
    print(f"model loaded in {time.time() - t0:.1f}s, serving on 127.0.0.1:{port}", flush=True)

    server = ThreadingHTTPServer(("127.0.0.1", port), make_handler(synth))
    try:
        server.serve_forever()
    except KeyboardInterrupt:
        sys.exit(0)


if __name__ == "__main__":
    main()
