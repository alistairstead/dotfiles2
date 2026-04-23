// Shared types and helpers for Claude Code notification hooks

// ─── Types ────────────────────────────────────────────────────────────────────

export type HookEventName =
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

export type NotificationType =
  | "permission_prompt" // → prompt profile
  | "idle_prompt" // → default profile
  | "auth_success" // → success profile
  | "elicitation_dialog"; // → prompt profile

export type StopFailureError =
  | "rate_limit"
  | "authentication_failed"
  | "billing_error"
  | "invalid_request"
  | "server_error"
  | "max_output_tokens"
  | "unknown";

export interface HookPayload {
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

// ─── Helpers ──────────────────────────────────────────────────────────────────

export function pick<T>(arr: T[]): T {
  return arr[Math.floor(Math.random() * arr.length)];
}

export const IDLE_VERBS = [
  "waiting", "idle", "pondering", "musing", "contemplating",
  "daydreaming", "reflecting", "cogitating", "noodling",
];

export function stripMarkdown(text: string): string {
  return text
    .replace(/^#{1,6}\s+/gm, "")
    .replace(/\*\*([^*]+)\*\*/g, "$1")
    .replace(/\*([^*]+)\*/g, "$1")
    .replace(/`([^`]+)`/g, (_, c) =>
      /^([a-z]{8}\s+)?[0-9a-f]{7,40}$/.test(c.trim()) ? "" : c,
    )
    .replace(/^\s*[-*+]\s+/gm, "")
    .trim();
}

export const SPEECH_REPLACEMENTS: [RegExp, string][] = [
  [/```[\s\S]*?```/g, ""],         // fenced code blocks
  [/—/g, "EM_DASH_PAUSE"],          // em dash → placeholder for sox silence splice
  [/–/g, ", "],                     // en dash → short pause
  [/===?/g, "equals"],
  [/!=/g, "not equal to"],
  [/=>/g, "to"],
  [/->/g, "to"],
  [/<-/g, "from"],
  [/>=/g, "greater than or equal to"],
  [/<=/g, "less than or equal to"],
  [/&&/g, "and"],
  [/\|\|/g, "or"],
  [/#(\d+)/g, "number $1"],
  [/(\w+)\/(\w+)/g, "$1 of $2"],
  [/~/g, "approximately"],
  [/%/g, "percent"],
  [/\|/g, ""],
];

export function normalizeSpeech(text: string): string {
  let result = text;
  for (const [pattern, replacement] of SPEECH_REPLACEMENTS) {
    result = result.replace(pattern, replacement);
  }
  result = stripMarkdown(result);
  result = result.replace(/\n+/g, " ");
  result = result.replace(/[^\w\s.,!?;:'"()\-]/g, "");
  return result.replace(/\s{2,}/g, " ").trim();
}

// ─── Text extraction ──────────────────────────────────────────────────────────

export const SPOKEN_MIN_WORDS = 13;
export const SPOKEN_MAX_WORDS = 17;

export function wordCount(text: string): number {
  return text.split(/\s+/).filter((s) => /\w/.test(s)).length;
}

export function inRange(n: number): boolean {
  return n >= SPOKEN_MIN_WORDS && n <= SPOKEN_MAX_WORDS;
}

const DECIMAL_PLACEHOLDER = "\x00";

function splitIntoSentences(text: string): string[] {
  const safe = text.replace(/(?<=\d)\.(?=\d)/g, DECIMAL_PLACEHOLDER);
  const byPunct = safe.match(/[^.!?]+[.!?]+/g);
  if (byPunct && byPunct.length > 1) {
    return byPunct.map((s) => s.replace(/\x00/g, ".").trim());
  }
  const byLine = text.split(/\n+/).map((s) => s.trim()).filter(Boolean);
  if (byLine.length > 1) return byLine;
  return [text];
}

export function extractSpokenSentences(text: string): string {
  const sentences = splitIntoSentences(text);
  const first = sentences[0];
  if (first.trimEnd().endsWith(":")) {
    return `${first.trimEnd().slice(0, -1)}, see screen for details`;
  }
  if (inRange(wordCount(first))) return first;
  if (sentences.length >= 2) {
    const combined = `${first} ${sentences[1]}`;
    if (inRange(wordCount(combined))) return combined;
  }
  return first;
}

// ─── Question extraction ──────────────────────────────────────────────────────

export function extractQuestionText(
  msg: string,
  normalize: (t: string) => string = stripMarkdown,
): string | null {
  const lines = msg.split("\n");
  const questionLines = lines.filter((l) => l.trimEnd().endsWith("?"));
  if (questionLines.length === 0) return null;

  const spoken = questionLines.join(" ").trim();
  if (spoken.length < 80) {
    const clean = normalize(msg);
    const paragraphs = clean.split(/\n\n+/);
    const preceding = paragraphs.at(-2)?.trim() ?? "";
    const firstSentence =
      preceding.match(/^[^.!?]+[.!?]/)?.[0]?.trim() ?? preceding;
    const context = firstSentence.slice(0, 100);
    return context ? `${context} ${spoken}` : spoken;
  }
  return spoken;
}
