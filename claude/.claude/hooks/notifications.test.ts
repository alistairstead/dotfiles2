import { describe, test, expect, afterAll } from "bun:test";
import { existsSync, readFileSync, unlinkSync } from "fs";
import { tmpdir } from "os";

const SCRIPT = `${import.meta.dir}/notifications.ts`;
const SPEAK_LOG = `${tmpdir()}/test-notifications-speak-${Date.now()}.log`;
const NOTIFY_LOG = `${tmpdir()}/test-notifications-notify-${Date.now()}.log`;

afterAll(() => {
  for (const f of [SPEAK_LOG, NOTIFY_LOG]) {
    if (existsSync(f)) unlinkSync(f);
  }
});

function entries(log: string): Record<string, unknown>[] {
  if (!existsSync(log)) return [];
  return readFileSync(log, "utf8")
    .split("\n")
    .filter(Boolean)
    .map((l) => JSON.parse(l));
}

function last(log: string): Record<string, unknown> | null {
  const e = entries(log);
  return e.length ? e[e.length - 1] : null;
}

async function run(payload: object): Promise<number> {
  const proc = Bun.spawn(["bun", SCRIPT], {
    stdin: new Response(JSON.stringify(payload)),
    stdout: "ignore",
    stderr: "ignore",
    env: {
      ...process.env,
      CLAUDE_SPEAK_LOG: SPEAK_LOG,
      CLAUDE_NOTIFICATION_LOG: NOTIFY_LOG,
    },
  });
  return proc.exited;
}

const BASE = { session_id: "test-session", transcript_path: "/tmp", cwd: "/tmp" };

describe("notifications.ts controller", () => {
  test("dispatches Stop to both adapters", async () => {
    const speakBefore = entries(SPEAK_LOG).length;
    const notifyBefore = entries(NOTIFY_LOG).length;

    const code = await run({
      ...BASE,
      hook_event_name: "Stop",
      last_assistant_message:
        "I've completed the refactor. The controller now dispatches to both adapters in parallel.",
    });

    expect(code).toBe(0);
    expect(entries(SPEAK_LOG).length).toBeGreaterThan(speakBefore);
    expect(entries(NOTIFY_LOG).length).toBe(notifyBefore + 1);

    const speakEntry = last(SPEAK_LOG)!;
    expect(speakEntry.hook).toBe("Stop");
    expect(speakEntry.voice_profile).toBe("success");

    const notifyEntry = last(NOTIFY_LOG)!;
    expect(notifyEntry.hook).toBe("Stop");
    expect(notifyEntry.profile).toBe("success");
    expect(notifyEntry.title).toBe("Claude — Done");
  });

  test("dispatches StopFailure to both adapters", async () => {
    await run({
      ...BASE,
      hook_event_name: "StopFailure",
      error: "rate_limit",
      error_details: "Rate limit exceeded.",
    });

    expect(last(SPEAK_LOG)!.voice_profile).toBe("error");
    expect(last(NOTIFY_LOG)!.profile).toBe("error");
    expect(last(NOTIFY_LOG)!.title).toBe("Claude — Error");
  });

  test("dispatches TaskCompleted to both adapters", async () => {
    await run({
      ...BASE,
      hook_event_name: "TaskCompleted",
      message: "All tasks complete.",
    });

    expect(last(SPEAK_LOG)!.voice_profile).toBe("success");
    expect(last(NOTIFY_LOG)!.profile).toBe("success");
    expect(last(NOTIFY_LOG)!.title).toBe("Claude — Task Complete");
  });

  test("dispatches PreCompact to both adapters", async () => {
    await run({ ...BASE, hook_event_name: "PreCompact" });

    expect(last(SPEAK_LOG)!.voice_profile).toBe("warning");
    expect(last(NOTIFY_LOG)!.profile).toBe("warning");
    expect(last(NOTIFY_LOG)!.title).toBe("Claude — Compacting");
  });

  test("dispatches Notification idle_prompt to both adapters", async () => {
    await run({
      ...BASE,
      hook_event_name: "Notification",
      notification_type: "idle_prompt",
    });

    expect(last(SPEAK_LOG)!.voice_profile).toBe("default");
    expect(last(NOTIFY_LOG)!.profile).toBe("default");
    expect(last(NOTIFY_LOG)!.title).toBe("Claude — Waiting");
  });

  test("Stop without lastMsg: speak skips, notify skips, exits 0", async () => {
    const speakBefore = entries(SPEAK_LOG).length;
    const notifyBefore = entries(NOTIFY_LOG).length;

    const code = await run({ ...BASE, hook_event_name: "Stop" });

    expect(code).toBe(0);
    // speak logs "invoked" but no message entry; notify logs nothing
    const newSpeak = entries(SPEAK_LOG).slice(speakBefore);
    expect(newSpeak.every((e) => e.hook === "invoked")).toBe(true);
    expect(entries(NOTIFY_LOG).length).toBe(notifyBefore);
  });

  test("empty stdin exits 0 without dispatching", async () => {
    const speakBefore = entries(SPEAK_LOG).length;
    const notifyBefore = entries(NOTIFY_LOG).length;

    const proc = Bun.spawn(["bun", SCRIPT], {
      stdin: new Response(""),
      stdout: "ignore",
      stderr: "ignore",
      env: {
        ...process.env,
        CLAUDE_SPEAK_LOG: SPEAK_LOG,
        CLAUDE_NOTIFICATION_LOG: NOTIFY_LOG,
      },
    });
    expect(await proc.exited).toBe(0);
    expect(entries(SPEAK_LOG).length).toBe(speakBefore);
    expect(entries(NOTIFY_LOG).length).toBe(notifyBefore);
  });
});
