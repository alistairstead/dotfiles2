#!/usr/bin/env bun

import { appendFileSync } from "fs";
import { homedir } from "os";
import {
  type HookPayload,
  IDLE_VERBS,
  normalizeSpeech,
  stripMarkdown,
  extractSpokenSentences,
  extractQuestionText,
  pick,
} from "./hooks-shared";

export { normalizeSpeech, stripMarkdown, extractSpokenSentences, extractQuestionText, wordCount, inRange, SPOKEN_MIN_WORDS, SPOKEN_MAX_WORDS } from "./hooks-shared";

// ─── Voice config ─────────────────────────────────────────────────────────────

// Available downloaded piper voice models in ~/.local/share/piper-voices/:
//   en_GB-southern_english_female-low   — British female, southern accent (low quality)
//   en_GB-northern_english_male-medium  — British male, northern accent (medium quality)
//   en_GB-alba-medium                   — British female, Scottish-influenced (medium quality)
//   en_GB-cori-high                     — British female, highest quality GB option
//   en_GB-jenny_dioco-medium            — British female, distinctive character (medium quality)
//   en_GB-semaine-medium                — Multi-speaker GB: speaker 0=Prudence, 1=Spike, 2=Obadiah, 3=Poppy
//   en_US-lessac-high                   — American male, clear/professional (high quality)
//
// Current assignment: Jenny for all event types.

type VoiceProfile = "error" | "warning" | "success" | "prompt" | "default";

interface VoiceConfig {
  model: string;
  lengthScale: number;
  noiseScale: number;
  noiseWScale: number;
  sentenceSilence: number;
  speaker?: number;
  sayVoice: string;
  sayRate: number;
  prefixes: string[];
}

const VOICE_PROFILES: Record<VoiceProfile, VoiceConfig> = {
  error: {
    model: "en_GB-jenny_dioco-medium",
    lengthScale: 1.2,
    noiseScale: 0.9,
    noiseWScale: 0.9,
    sentenceSilence: 0.4,
    sayVoice: "Serena (Premium)",
    sayRate: 160,
    prefixes: [
      "I've hit a problem, and need help.",
      "Something went wrong, I don't know how to proceed.",
      "There's an issue, many many issues.",
      "I've run into B–I–G trouble!",
    ],
  },
  warning: {
    model: "en_GB-jenny_dioco-medium",
    lengthScale: 1.15,
    noiseScale: 0.8,
    noiseWScale: 0.8,
    sentenceSilence: 0.3,
    sayVoice: "Daniel (Enhanced)",
    sayRate: 170,
    prefixes: [
      "Just so you know,",
      "Quick heads up,",
      "Be aware,",
      "Worth noting,",
    ],
  },
  success: {
    model: "en_GB-jenny_dioco-medium",
    lengthScale: 0.9,
    noiseScale: 0.35,
    noiseWScale: 0.4,
    sentenceSilence: 0.1,
    sayVoice: "Jamie (Premium)",
    sayRate: 200,
    prefixes: [
      "Done – ",
      "Sorted – ",
      "All good – ",
      "That kinda worked – ",
      "Nailed it – ",
    ],
  },
  prompt: {
    model: "en_GB-jenny_dioco-medium",
    lengthScale: 0.9,
    noiseScale: 0.4,
    noiseWScale: 0.45,
    sentenceSilence: 0.15,
    sayVoice: "Serena (Premium)",
    sayRate: 190,
    prefixes: [
      "I need your input.",
      "Over to you.",
      "I need a decision.",
      "Quick, question.",
    ],
  },
  default: {
    model: "en_GB-jenny_dioco-medium",
    lengthScale: 1.15,
    noiseScale: 0.667,
    noiseWScale: 0.8,
    sentenceSilence: 0.2,
    sayVoice: "Jamie (Premium)",
    sayRate: 175,
    prefixes: [],
  },
};

// ─── Helpers ──────────────────────────────────────────────────────────────────

const GREETINGS = ["Hey – ", "Hi – ", "Right then – ", "Heads up – "];

function resolveVoiceProfile(payload: HookPayload): VoiceProfile {
  if (payload.hook_event_name === "StopFailure") return "error";
  if (payload.notification_type === "permission_prompt") return "prompt";
  if (payload.notification_type === "elicitation_dialog") return "prompt";
  if (payload.notification_type === "auth_success") return "success";
  return "default";
}

// ─── Logging ─────────────────────────────────────────────────────────────────

const LOG_PATH = process.env.CLAUDE_SPEAK_LOG ?? "/tmp/speak-notification.log";

function logInvocation(
  payload: HookPayload,
  voiceProfile: VoiceProfile,
  spoken: string,
  audioFile?: string,
): void {
  try {
    const entry = JSON.stringify({
      ts: new Date().toISOString(),
      hook: payload.hook_event_name,
      notification_type: payload.notification_type ?? null,
      voice_profile: voiceProfile,
      message: payload.message ?? null,
      last: payload.last_assistant_message ?? null,
      spoken,
      audio_file: audioFile ?? null,
    });
    appendFileSync(LOG_PATH, entry + "\n");
    Bun.write(
      "/tmp/hook-notification-payload.json",
      JSON.stringify(payload, null, 2),
    );
  } catch {
    // ignore log errors
  }
}

// ─── TTS ─────────────────────────────────────────────────────────────────────

async function findPiper(): Promise<string | null> {
  try {
    const proc = Bun.spawn(
      ["mise", "exec", "pipx:piper-tts", "--", "which", "piper"],
      { stdout: "pipe", stderr: "ignore" },
    );
    await proc.exited;
    const path = (await new Response(proc.stdout).text()).trim();
    return path || null;
  } catch {
    return null;
  }
}

const EM_DASH_PAUSE_S = 0.9; // seconds of silence per em dash

async function synthesizeSegment(
  text: string,
  outFile: string,
  config: VoiceConfig,
  piperPath: string,
  onnxPath: string,
): Promise<void> {
  const args = [
    piperPath,
    "--model", onnxPath,
    "--length-scale", String(config.lengthScale),
    "--noise-scale", String(config.noiseScale),
    "--noise-w-scale", String(config.noiseWScale),
    "--sentence-silence", String(config.sentenceSilence),
    "--output_file", outFile,
  ];
  if (config.speaker !== undefined) args.push("--speaker", String(config.speaker));
  const proc = Bun.spawn(args, { stdin: new Response(text), stdout: "ignore", stderr: "ignore" });
  await proc.exited;
}

async function speakWithPiper(
  spoken: string,
  config: VoiceConfig,
  piperPath: string,
  runId: string,
): Promise<string> {
  const home = homedir();
  const onnxPath = `${home}/.local/share/piper-voices/${config.model}.onnx`;
  const rawFile = `/tmp/claude-speak-${runId}.wav`;
  const normFile = `/tmp/claude-speak-norm-${runId}.wav`;
  const segments = spoken.split("EM_DASH_PAUSE").map((s) => s.trim()).filter(Boolean);

  // Always synthesize with sentenceSilence: 0 — the jenny_dioco model generates
  // loud broadband noise when sentenceSilence > 0. Use sox pad for intentional pauses.
  if (segments.length === 1) {
    await synthesizeSegment(spoken, rawFile, { ...config, sentenceSilence: 0 }, piperPath, onnxPath);
  } else {
    // Synthesize each segment with sentence-silence=0 to avoid piper's noisy model tail,
    // then pad clean silence (true zeros, same format) after each segment except the last.
    const segFiles: string[] = [];
    for (let i = 0; i < segments.length; i++) {
      const segFile = `/tmp/claude-speak-seg-${runId}-${i}.wav`;
      await synthesizeSegment(segments[i], segFile, { ...config, sentenceSilence: 0 }, piperPath, onnxPath);
      if (!(await Bun.file(segFile).exists())) continue;
      if (i < segments.length - 1) {
        const paddedFile = `/tmp/claude-speak-pad-${runId}-${i}.wav`;
        await Bun.spawn(
          ["sox", segFile, paddedFile, "pad", "0", String(EM_DASH_PAUSE_S)],
          { stdout: "ignore", stderr: "ignore" },
        ).exited;
        segFiles.push(paddedFile);
      } else {
        segFiles.push(segFile);
      }
    }
    await Bun.spawn(
      ["sox", ...segFiles, rawFile],
      { stdout: "ignore", stderr: "ignore" },
    ).exited;
  }

  // Normalize to -1dB to prevent clipping artifacts
  const soxProc = Bun.spawn(
    ["sox", rawFile, normFile, "gain", "-n", "-1"],
    { stdout: "ignore", stderr: "ignore" },
  );
  await soxProc.exited;
  return await Bun.file(normFile).exists() ? normFile : rawFile;
}

async function speakFallback(
  spoken: string,
  config: VoiceConfig,
): Promise<void> {
  const swiftSpeak = `${homedir()}/.claude/hooks/speak`;
  if (await Bun.file(swiftSpeak).exists()) {
    Bun.spawn([swiftSpeak, spoken], { stdout: "ignore", stderr: "ignore" });
  } else {
    Bun.spawn(["say", "-v", config.sayVoice, "-r", String(config.sayRate), spoken], {
      stdout: "ignore",
      stderr: "ignore",
    });
  }
}

// ─── Adapter ─────────────────────────────────────────────────────────────────

const MUTE_FLAG = `${homedir()}/.claude/hooks/.speak-muted`;

export async function speak(payload: HookPayload): Promise<void> {
  appendFileSync(LOG_PATH, JSON.stringify({ ts: new Date().toISOString(), hook: "invoked" }) + "\n");

  const hook = payload.hook_event_name;
  const lastMsg = payload.last_assistant_message ?? "";
  let voiceProfile = resolveVoiceProfile(payload);
  let spoken: string;

  if (hook === "Stop" && !lastMsg) return;

  if (hook === "Stop") {
    const questionText = extractQuestionText(lastMsg, normalizeSpeech);
    if (questionText) {
      voiceProfile = "prompt";
      spoken = questionText;
    } else {
      voiceProfile = "success";
      spoken = extractSpokenSentences(stripMarkdown(lastMsg));
    }
  } else if (hook === "StopFailure") {
    voiceProfile = "error";
    spoken = payload.error_details ?? payload.error ?? "Unknown error";
  } else if (hook === "TaskCompleted") {
    voiceProfile = "success";
    spoken = payload.message ?? "Task completed.";
  } else if (hook === "PreCompact") {
    voiceProfile = "warning";
    spoken = "Context compacting. I may lose some memory of earlier work.";
  } else if (payload.notification_type === "idle_prompt") {
    voiceProfile = "default";
    spoken = `Hi — I'm ${pick(IDLE_VERBS)}.`;
  } else {
    const config = VOICE_PROFILES[voiceProfile];
    const message = (payload.message ?? "I have a notification").slice(0, 120);
    const prefix = config.prefixes.length ? pick(config.prefixes) : "";
    spoken = [pick(GREETINGS), prefix, message].filter(Boolean).join(" — ");
  }

  spoken = normalizeSpeech(spoken);
  const config = VOICE_PROFILES[voiceProfile];
  const runId = `${payload.session_id.slice(0, 8)}-${Date.now()}`;

  Bun.spawn(["pkill", "afplay"], { stdout: "ignore", stderr: "ignore" });

  const piperPath = await findPiper();
  if (piperPath) {
    const onnxPath = `${homedir()}/.local/share/piper-voices/${config.model}.onnx`;
    if (await Bun.file(onnxPath).exists()) {
      const playFile = await speakWithPiper(spoken, config, piperPath, runId);
      logInvocation(payload, voiceProfile, spoken, playFile);
      if (await Bun.file(MUTE_FLAG).exists()) return;
      Bun.spawn(["afplay", playFile], { stdout: "ignore", stderr: "ignore" });
      return;
    }
  }

  logInvocation(payload, voiceProfile, spoken);
  if (await Bun.file(MUTE_FLAG).exists()) return;
  await speakFallback(spoken, config);
}

// ─── Standalone ───────────────────────────────────────────────────────────────

async function main(): Promise<void> {
  const inputData = await Bun.stdin.text();
  if (!inputData.trim()) process.exit(0);

  let payload: HookPayload;
  try {
    payload = JSON.parse(inputData);
  } catch {
    process.exit(1);
  }

  await speak(payload);
  process.exit(0);
}

if (import.meta.main) {
  main().catch(() => process.exit(1));
}
