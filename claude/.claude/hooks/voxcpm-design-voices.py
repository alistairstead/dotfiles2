# /// script
# requires-python = ">=3.10,<3.13"
# dependencies = ["mlx-audio", "soundfile"]
# ///
"""Materialize the VoxCPM base voice from its text description.

Generates the reference audio that voxcpm-server.py clones from:
  ~/.local/share/voxcpm-voices/base.wav  (designed voice, ~2 sentences)
  ~/.local/share/voxcpm-voices/base.txt  (its transcript, needed for cloning)

Iterate: edit voice.description in voxcpm-voices.json, re-run with --play
until the voice sounds right. The daemon picks up the new base.wav on the
next request; no restart needed.

  uv run --script voxcpm-design-voices.py --play
  uv run --script voxcpm-design-voices.py --play --audition-profiles
"""

import argparse
import json
import os
import subprocess
import sys
from pathlib import Path

CONFIG_PATH = Path(__file__).resolve().parent / "voxcpm-voices.json"
MODEL_ID = "mlx-community/VoxCPM2-8bit"

# Long enough for a >=5s clone reference, no longer: the daemon re-encodes
# this audio on every request, so reference length costs latency directly.
AUDITION_PASSAGE = (
    "Right then, the build has finished and everything looks to be in proper order."
)

PROFILE_SAMPLES = {
    "error": "I've hit a problem, and need help with the failing build.",
    "warning": "Just so you know, the context is filling up rather quickly.",
    "success": "Nailed it. The refactor is complete and all tests pass.",
    "prompt": "Quick question. Should I use the staging or production config?",
    "default": "I'm carrying on with the migration you asked about.",
}


def load_config() -> dict:
    with open(CONFIG_PATH) as f:
        return json.load(f)


def play(path: Path) -> None:
    subprocess.run(["afplay", str(path)], check=False)


def normalize(path: Path) -> None:
    # VoxCPM output level varies wildly between runs; normalize to -1dB peak
    # so the clone reference (and auditions) play at a sane volume.
    tmp = path.with_suffix(".norm.wav")
    result = subprocess.run(
        ["sox", str(path), str(tmp), "gain", "-n", "-1"],
        capture_output=True,
    )
    if result.returncode == 0 and tmp.exists():
        tmp.replace(path)


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument("--play", action="store_true", help="audition results via afplay")
    parser.add_argument(
        "--audition-profiles",
        action="store_true",
        help="also clone the new base with each profile's style instruction",
    )
    args = parser.parse_args()

    config = load_config()
    description = config.get("voice", {}).get("description", "").strip()
    if not description:
        sys.exit("voice.description missing in voxcpm-voices.json")

    out_dir = Path(os.path.expanduser(config.get("voicesDir", "~/.local/share/voxcpm-voices")))
    out_dir.mkdir(parents=True, exist_ok=True)

    import numpy as np
    import soundfile as sf
    from mlx_audio.tts.utils import load

    print(f"loading {MODEL_ID}...")
    model = load(MODEL_ID)

    def generate(text: str, instruct: str | None, ref_audio: str | None = None, profile_cfg: dict | None = None):
        cfg = profile_cfg or {}
        result = next(model.generate(
            text=text,
            instruct=instruct,
            ref_audio=ref_audio,
            cfg_value=cfg.get("cfgValue", 2.0),
            inference_timesteps=cfg.get("inferenceTimesteps", 10),
        ))
        return np.asarray(result.audio), getattr(result, "sample_rate", 48000) or 48000

    print("designing base voice from description...")
    wav, sample_rate = generate(AUDITION_PASSAGE, instruct=description)
    base_wav = out_dir / "base.wav"
    base_txt = out_dir / "base.txt"
    sf.write(base_wav, wav, sample_rate)
    normalize(base_wav)
    base_txt.write_text(AUDITION_PASSAGE)
    print(f"wrote {base_wav} ({len(wav) / sample_rate:.1f}s) and {base_txt}")
    if args.play:
        play(base_wav)

    if not args.audition_profiles:
        return

    for name, profile_cfg in config.get("profiles", {}).items():
        text = PROFILE_SAMPLES.get(name, AUDITION_PASSAGE)
        tag = profile_cfg.get("tag")
        if tag:  # force the tag so it can be auditioned
            text = f"{text} {tag}" if profile_cfg.get("tagPlacement") == "end" else f"{tag} {text}"
        control = profile_cfg.get("styleInstruction", "")
        out = out_dir / f"audition-{name}.wav"
        print(f"cloning profile '{name}' ({control})...")
        wav, sample_rate = generate(text, instruct=control or None, ref_audio=str(base_wav), profile_cfg=profile_cfg)
        sf.write(out, wav, sample_rate)
        normalize(out)
        print(f"wrote {out} ({len(wav) / sample_rate:.1f}s)")
        if args.play:
            play(out)


if __name__ == "__main__":
    main()
