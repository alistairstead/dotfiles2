#!/usr/bin/env bun

import { appendFileSync } from "fs";
import {
  type HookPayload,
  IDLE_VERBS,
  stripMarkdown,
  extractSpokenSentences,
  extractQuestionText,
  pick,
} from "./hooks-shared";

export { type HookPayload };

// ─── Config ───────────────────────────────────────────────────────────────────

type NotificationProfile = "error" | "warning" | "success" | "prompt" | "default";

const SOUNDS: Record<NotificationProfile, string | null> = {
  error: "Basso",
  warning: "Purr",
  success: "Glass",
  prompt: "Ping",
  default: null,
};

const PREFIXES: Record<NotificationProfile, string[]> = {
  error: [
    "I've hit a problem",
    "Something went wrong",
    "There's an issue",
  ],
  warning: ["Just so you know,", "Quick heads up,", "Be aware,"],
  success: ["Done –", "Sorted –", "All good –", "Nailed it –"],
  prompt: ["I need your input.", "Over to you.", "I need a decision."],
  default: [],
};

// ─── Helpers ──────────────────────────────────────────────────────────────────

function resolveProfile(payload: HookPayload): NotificationProfile {
  if (payload.hook_event_name === "StopFailure") return "error";
  if (payload.notification_type === "permission_prompt") return "prompt";
  if (payload.notification_type === "elicitation_dialog") return "prompt";
  if (payload.notification_type === "auth_success") return "success";
  return "default";
}

// ─── Content ──────────────────────────────────────────────────────────────────

interface NotificationContent {
  title: string;
  message: string;
  profile: NotificationProfile;
}

function buildContent(payload: HookPayload): NotificationContent | null {
  const hook = payload.hook_event_name;
  const lastMsg = payload.last_assistant_message ?? "";

  if (hook === "Stop" && !lastMsg) return null;

  if (hook === "Stop") {
    const questionText = extractQuestionText(lastMsg);
    if (questionText) {
      return { title: "Claude — Done", message: questionText, profile: "prompt" };
    }
    return {
      title: "Claude — Done",
      message: extractSpokenSentences(stripMarkdown(lastMsg)),
      profile: "success",
    };
  }

  if (hook === "StopFailure") {
    return {
      title: "Claude — Error",
      message: payload.error_details ?? payload.error ?? "Unknown error",
      profile: "error",
    };
  }

  if (hook === "TaskCompleted") {
    return {
      title: "Claude — Task Complete",
      message: payload.message ?? "Task completed.",
      profile: "success",
    };
  }

  if (hook === "PreCompact") {
    return {
      title: "Claude — Compacting",
      message: "Context compacting. I may lose some memory of earlier work.",
      profile: "warning",
    };
  }

  if (payload.notification_type === "idle_prompt") {
    return {
      title: "Claude — Waiting",
      message: `Hi — I'm ${pick(IDLE_VERBS)}.`,
      profile: "default",
    };
  }

  const profile = resolveProfile(payload);
  const prefixes = PREFIXES[profile];
  const raw = (payload.message ?? "I have a notification").slice(0, 120);
  const prefix = prefixes.length ? pick(prefixes) : "";
  return {
    title: "Claude — Notification",
    message: [prefix, raw].filter(Boolean).join(" — "),
    profile,
  };
}

// ─── Notification ─────────────────────────────────────────────────────────────

async function sendNotification({
  title,
  message,
  profile,
  sessionId,
  hook,
}: {
  title: string;
  message: string;
  profile: NotificationProfile;
  sessionId: string;
  hook: string;
}): Promise<void> {
  const truncated =
    message.length > 256 ? `${message.slice(0, 253)}...` : message;
  const sound = SOUNDS[profile];

  const args = [
    "terminal-notifier",
    "-title", title,
    "-message", truncated,
    "-group", `claude-code-${sessionId}-${hook}`,
  ];
  if (sound) args.push("-sound", sound);

  try {
    const proc = Bun.spawn(args, { stdout: "ignore", stderr: "ignore" });
    const tid = setTimeout(() => proc.kill(), 15000);
    await proc.exited;
    clearTimeout(tid);
  } catch {
    const esc = (s: string) =>
      s.replace(/\\/g, "\\\\").replace(/"/g, '\\"');
    const script = `display notification "${esc(truncated)}" with title "${esc(title)}"`;
    await Bun.spawn(["osascript", "-e", script], {
      stdout: "ignore",
      stderr: "ignore",
    }).exited;
  }
}

// ─── Logging ─────────────────────────────────────────────────────────────────

const LOG_PATH = process.env.CLAUDE_NOTIFICATION_LOG ?? "/tmp/claude-notification.log";

function logNotification(
  payload: HookPayload,
  content: NotificationContent,
): void {
  try {
    const entry = JSON.stringify({
      ts: new Date().toISOString(),
      hook: payload.hook_event_name,
      notification_type: payload.notification_type ?? null,
      profile: content.profile,
      title: content.title,
      message: content.message,
    });
    appendFileSync(LOG_PATH, entry + "\n");
  } catch {
    // ignore log errors
  }
}

// ─── Adapter ─────────────────────────────────────────────────────────────────

export async function notify(payload: HookPayload): Promise<void> {
  const content = buildContent(payload);
  if (!content) return;

  await sendNotification({
    title: content.title,
    message: content.message,
    profile: content.profile,
    sessionId: payload.session_id,
    hook: payload.hook_event_name,
  });

  logNotification(payload, content);
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

  await notify(payload);
  process.exit(0);
}

if (import.meta.main) {
  main().catch(() => process.exit(1));
}
