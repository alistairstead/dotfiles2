#!/usr/bin/env bun

import { appendFileSync } from "fs";
import { homedir } from "os";

// ─── Types ────────────────────────────────────────────────────────────────────

type HookEventName =
  | "SessionStart"
  | "UserPromptSubmit"
  | "UserPromptExpansion"
  | "PreToolUse"
  | "PermissionRequest"
  | "PermissionDenied"
  | "PostToolUse"
  | "PostToolUseFailure"
  | "Notification"
  | "SubagentStart"
  | "SubagentStop"
  | "TaskCreated"
  | "TaskCompleted"
  | "Stop"
  | "StopFailure"
  | "TeammateIdle"
  | "InstructionsLoaded"
  | "ConfigChange"
  | "CwdChanged"
  | "FileChanged"
  | "WorktreeCreate"
  | "WorktreeRemove"
  | "PreCompact"
  | "PostCompact"
  | "Elicitation"
  | "ElicitationResult"
  | "SessionEnd";

type NotificationType =
  | "permission_prompt" // → prompt voice
  | "idle_prompt" // → default voice
  | "auth_success" // → success voice
  | "elicitation_dialog"; // → prompt voice

type StopFailureError =
  | "rate_limit"
  | "authentication_failed"
  | "billing_error"
  | "invalid_request"
  | "server_error"
  | "max_output_tokens"
  | "unknown";

interface HookPayload {
  hook_event_name: HookEventName;
  session_id: string;
  transcript_path: string;
  cwd: string;
  permission_mode?: string;
  // Notification-specific
  notification_type?: NotificationType;
  message?: string;
  title?: string;
  // Stop-specific
  stop_hook_active?: boolean;
  last_assistant_message?: string;
  // StopFailure-specific
  error?: StopFailureError;
  error_details?: string;
}

type VoiceProfile = "error" | "warning" | "success" | "prompt" | "default";

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
      "I've run into B.I.G. trouble!",
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
      "Done! . .",
      "Sorted! . .",
      "All good! . .",
      "That kinda worked. . .",
      "Naaiiiiled it! . .",
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
      "Over to you!",
      "I need a decision!",
      "Quiiiiick, question?",
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

function pick<T>(arr: T[]): T {
  return arr[Math.floor(Math.random() * arr.length)];
}

const GREETINGS = ["Hey!\n\n", "Hi!\n\n", "Right then!\n\n", "Heads up!\n\n"];


function resolveVoiceProfile(payload: HookPayload): VoiceProfile {
  if (payload.hook_event_name === "StopFailure") return "error";
  if (payload.notification_type === "permission_prompt") return "prompt";
  if (payload.notification_type === "elicitation_dialog") return "prompt";
  if (payload.notification_type === "auth_success") return "success";
  return "default";
}

const SPEECH_REPLACEMENTS: [RegExp, string][] = [
  [/```[\s\S]*?```/g, ""],         // fenced code blocks
  [/===?/g, "equals"],
  [/!=/g, "not equal to"],
  [/=>/g, "to"],
  [/->/g, "to"],
  [/<-/g, "from"],
  [/>=/g, "greater than or equal to"],
  [/<=/g, "less than or equal to"],
  [/&&/g, "and"],
  [/\|\|/g, "or"],
  [/~/g, "approximately"],
  [/%/g, "percent"],
  [/\|/g, ""],
];

function stripMarkdown(text: string): string {
  return text
    .replace(/^#{1,6}\s+/gm, "")
    .replace(/\*\*([^*]+)\*\*/g, "$1")
    .replace(/\*([^*]+)\*/g, "$1")
    .replace(/`[^`]+`/g, "")
    .replace(/^\s*[-*+]\s+/gm, "")
    .trim();
}

function normalizeSpeech(text: string): string {
  let result = text;
  for (const [pattern, replacement] of SPEECH_REPLACEMENTS) {
    result = result.replace(pattern, replacement);
  }
  result = stripMarkdown(result);
  // remove remaining non-speech characters
  result = result.replace(/[^\w\s.,!?;:'"()\-\n]/g, "");
  return result.replace(/\s{2,}/g, " ").trim();
}

// ─── Text extraction ─────────────────────────────────────────────────────────

function truncateToSentences(text: string, maxChars = 300): string {
  const sentences = text.match(/[^.!?]+[.!?]+/g) ?? [text];
  let result = "";
  for (const s of sentences.slice(0, 3)) {
    if ((result + s).length > maxChars) break;
    result += s;
  }
  return result.trim() || text.slice(0, maxChars);
}

// ─── Question extraction ──────────────────────────────────────────────────────

function extractQuestionText(msg: string): string | null {
  const lines = msg.split("\n");
  const questionLines = lines.filter((l) => l.trimEnd().endsWith("?"));
  if (questionLines.length === 0) return null;

  const spoken = questionLines.join(" ").trim();
  if (spoken.length < 80) {
    const paragraphs = msg.split(/\n\n+/);
    const preceding = paragraphs.at(-2)?.trim() ?? "";
    const context = preceding ? normalizeSpeech(preceding) : "";
    return context ? `${context} ${spoken}` : spoken;
  }
  return spoken;
}

// ─── Logging ─────────────────────────────────────────────────────────────────

function logInvocation(
  payload: HookPayload,
  voiceProfile: VoiceProfile,
  spoken: string,
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
    });
    appendFileSync("/tmp/speak-notification.log", entry + "\n");
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

async function speakWithPiper(
  spoken: string,
  config: VoiceConfig,
  piperPath: string,
): Promise<void> {
  const home = homedir();
  const onnxPath = `${home}/.local/share/piper-voices/${config.model}.onnx`;

  const args = [
    piperPath,
    "--model",
    onnxPath,
    "--length-scale",
    String(config.lengthScale),
    "--noise-scale",
    String(config.noiseScale),
    "--noise-w-scale",
    String(config.noiseWScale),
    "--sentence-silence",
    String(config.sentenceSilence),
    "--output_file",
    "/tmp/claude-speak.wav",
  ];
  if (config.speaker !== undefined) {
    args.push("--speaker", String(config.speaker));
  }

  const piperProc = Bun.spawn(args, {
    stdin: new Response(spoken),
    stdout: "ignore",
    stderr: "ignore",
  });
  await piperProc.exited;

  // Normalize to -1dB to prevent clipping artifacts
  const soxProc = Bun.spawn(
    ["sox", "/tmp/claude-speak.wav", "/tmp/claude-speak-norm.wav", "gain", "-n", "-1"],
    { stdout: "ignore", stderr: "ignore" },
  );
  await soxProc.exited;
  const normalized = await Bun.file("/tmp/claude-speak-norm.wav").exists();
  const playFile = normalized ? "/tmp/claude-speak-norm.wav" : "/tmp/claude-speak.wav";

  // Fire and forget — don't block hook exit on playback
  Bun.spawn(["afplay", playFile], {
    stdout: "ignore",
    stderr: "ignore",
  });
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

// ─── Main ────────────────────────────────────────────────────────────────────

const MUTE_FLAG = `${homedir()}/.claude/hooks/.speak-muted`;

async function main(): Promise<void> {
  appendFileSync("/tmp/speak-notification.log", JSON.stringify({ ts: new Date().toISOString(), hook: "invoked" }) + "\n");
  if (await Bun.file(MUTE_FLAG).exists()) process.exit(0);
  const inputData = await Bun.stdin.text();
  if (!inputData.trim()) process.exit(0);

  let payload: HookPayload;
  try {
    payload = JSON.parse(inputData);
  } catch {
    process.exit(1);
  }

  const hook = payload.hook_event_name;
  const lastMsg = payload.last_assistant_message ?? "";
  let voiceProfile = resolveVoiceProfile(payload);
  let spoken: string;

  if (hook === "Stop" && lastMsg) {
    const questionText = extractQuestionText(lastMsg);
    if (questionText) {
      voiceProfile = "prompt";
      spoken = questionText;
    } else {
      voiceProfile = "success";
      spoken = truncateToSentences(stripMarkdown(lastMsg));
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
  } else {
    const config = VOICE_PROFILES[voiceProfile];
    const message = (payload.message ?? "I have a notification").slice(0, 120);
    const prefix = config.prefixes.length ? pick(config.prefixes) : "";
    spoken = [pick(GREETINGS), prefix, message].filter(Boolean).join("\n");
  }

  spoken = normalizeSpeech(spoken);
  const config = VOICE_PROFILES[voiceProfile];
  logInvocation(payload, voiceProfile, spoken);

  Bun.spawn(["pkill", "afplay"], { stdout: "ignore", stderr: "ignore" });

  const piperPath = await findPiper();
  if (piperPath) {
    const onnxPath = `${homedir()}/.local/share/piper-voices/${config.model}.onnx`;
    if (await Bun.file(onnxPath).exists()) {
      await speakWithPiper(spoken, config, piperPath);
      process.exit(0);
    }
  }

  await speakFallback(spoken, config);
  process.exit(0);
}

main().catch(() => process.exit(1));
