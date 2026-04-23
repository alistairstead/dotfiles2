import { describe, test, expect, afterAll } from "bun:test";
import { existsSync, readFileSync, unlinkSync } from "fs";
import { tmpdir } from "os";

const SCRIPT = `${import.meta.dir}/notification.ts`;
const LOG = `${tmpdir()}/test-notification-${Date.now()}.log`;

afterAll(() => {
  if (existsSync(LOG)) unlinkSync(LOG);
});

function logEntries(): Record<string, unknown>[] {
  if (!existsSync(LOG)) return [];
  return readFileSync(LOG, "utf8")
    .split("\n")
    .filter(Boolean)
    .map((l) => JSON.parse(l));
}

function lastEntry(): Record<string, unknown> | null {
  const entries = logEntries();
  return entries.length ? entries[entries.length - 1] : null;
}

async function run(payload: object): Promise<number> {
  const proc = Bun.spawn(["bun", SCRIPT], {
    stdin: new Response(JSON.stringify(payload)),
    stdout: "ignore",
    stderr: "ignore",
    env: { ...process.env, CLAUDE_NOTIFICATION_LOG: LOG },
  });
  return proc.exited;
}

const BASE = { session_id: "test-session", transcript_path: "/tmp", cwd: "/tmp" };

describe("notification.ts integration", () => {
  test("Stop with lastMsg exits 0 and logs success entry", async () => {
    const before = logEntries().length;
    const code = await run({
      ...BASE,
      hook_event_name: "Stop",
      last_assistant_message:
        "I've completed the refactor. The shared module now exports all helper functions correctly.",
    });
    expect(code).toBe(0);
    expect(logEntries().length).toBe(before + 1);
    const entry = lastEntry()!;
    expect(entry.hook).toBe("Stop");
    expect(entry.profile).toBe("success");
    expect(entry.title).toBe("Claude — Done");
    expect(typeof entry.message).toBe("string");
  });

  test("Stop with question logs prompt profile", async () => {
    await run({
      ...BASE,
      hook_event_name: "Stop",
      last_assistant_message:
        "I've reviewed the implementation. Should I also update the test suite to cover these changes?",
    });
    const entry = lastEntry()!;
    expect(entry.hook).toBe("Stop");
    expect(entry.profile).toBe("prompt");
    expect(entry.title).toBe("Claude — Done");
    expect((entry.message as string)).toContain("Should I also update");
  });

  test("Stop without lastMsg exits 0 without logging", async () => {
    const before = logEntries().length;
    const code = await run({ ...BASE, hook_event_name: "Stop" });
    expect(code).toBe(0);
    expect(logEntries().length).toBe(before);
  });

  test("StopFailure logs error entry with error_details message", async () => {
    await run({
      ...BASE,
      hook_event_name: "StopFailure",
      error: "rate_limit",
      error_details: "Rate limit exceeded, please wait before retrying.",
    });
    const entry = lastEntry()!;
    expect(entry.hook).toBe("StopFailure");
    expect(entry.profile).toBe("error");
    expect(entry.title).toBe("Claude — Error");
    expect(entry.message).toBe("Rate limit exceeded, please wait before retrying.");
  });

  test("StopFailure falls back to error type when no error_details", async () => {
    await run({
      ...BASE,
      hook_event_name: "StopFailure",
      error: "rate_limit",
    });
    const entry = lastEntry()!;
    expect(entry.message).toBe("rate_limit");
  });

  test("TaskCompleted logs success entry with message", async () => {
    await run({
      ...BASE,
      hook_event_name: "TaskCompleted",
      message: "Build pipeline completed successfully.",
    });
    const entry = lastEntry()!;
    expect(entry.hook).toBe("TaskCompleted");
    expect(entry.profile).toBe("success");
    expect(entry.title).toBe("Claude — Task Complete");
    expect(entry.message).toBe("Build pipeline completed successfully.");
  });

  test("TaskCompleted uses fallback message when none provided", async () => {
    await run({ ...BASE, hook_event_name: "TaskCompleted" });
    const entry = lastEntry()!;
    expect(entry.message).toBe("Task completed.");
  });

  test("PreCompact logs warning entry", async () => {
    await run({ ...BASE, hook_event_name: "PreCompact" });
    const entry = lastEntry()!;
    expect(entry.hook).toBe("PreCompact");
    expect(entry.profile).toBe("warning");
    expect(entry.title).toBe("Claude — Compacting");
    expect(entry.message).toContain("compacting");
  });

  test("Notification idle_prompt logs default profile", async () => {
    await run({
      ...BASE,
      hook_event_name: "Notification",
      notification_type: "idle_prompt",
    });
    const entry = lastEntry()!;
    expect(entry.hook).toBe("Notification");
    expect(entry.profile).toBe("default");
    expect(entry.title).toBe("Claude — Waiting");
    expect(entry.message).toMatch(/^Hi — I'm \w+\.$/);
  });

  test("Notification permission_prompt logs prompt profile", async () => {
    await run({
      ...BASE,
      hook_event_name: "Notification",
      notification_type: "permission_prompt",
      message: "Allow write to /etc/hosts?",
    });
    const entry = lastEntry()!;
    expect(entry.profile).toBe("prompt");
    expect(entry.title).toBe("Claude — Notification");
  });

  test("Notification auth_success logs success profile", async () => {
    await run({
      ...BASE,
      hook_event_name: "Notification",
      notification_type: "auth_success",
      message: "Authentication successful.",
    });
    const entry = lastEntry()!;
    expect(entry.profile).toBe("success");
  });

  test("empty stdin exits 0 without logging", async () => {
    const before = logEntries().length;
    const proc = Bun.spawn(["bun", SCRIPT], {
      stdin: new Response(""),
      stdout: "ignore",
      stderr: "ignore",
      env: { ...process.env, CLAUDE_NOTIFICATION_LOG: LOG },
    });
    const code = await proc.exited;
    expect(code).toBe(0);
    expect(logEntries().length).toBe(before);
  });

  test("invalid JSON exits 1 without logging", async () => {
    const before = logEntries().length;
    const proc = Bun.spawn(["bun", SCRIPT], {
      stdin: new Response("not json"),
      stdout: "ignore",
      stderr: "ignore",
      env: { ...process.env, CLAUDE_NOTIFICATION_LOG: LOG },
    });
    const code = await proc.exited;
    expect(code).toBe(1);
    expect(logEntries().length).toBe(before);
  });
});
