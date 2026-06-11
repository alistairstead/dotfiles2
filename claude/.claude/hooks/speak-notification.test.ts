import { describe, test, expect, afterAll } from "bun:test";
import { existsSync, readFileSync, unlinkSync } from "fs";
import { tmpdir } from "os";

const SCRIPT = `${import.meta.dir}/speak-notification.ts`;
const LOG = `${tmpdir()}/test-speak-notification-${Date.now()}.log`;

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

async function run(payload: object, env: Record<string, string> = {}): Promise<number> {
  const proc = Bun.spawn(["bun", SCRIPT], {
    stdin: new Response(JSON.stringify(payload)),
    stdout: "ignore",
    stderr: "ignore",
    // Dead voxcpm URL by default: connection refused is instant, keeps tests
    // off the real daemon (which takes seconds per synthesis).
    env: { ...process.env, CLAUDE_SPEAK_LOG: LOG, CLAUDE_VOXCPM_URL: "http://127.0.0.1:1", ...env },
  });
  return proc.exited;
}

const BASE = { session_id: "test-session", transcript_path: "/tmp", cwd: "/tmp" };

describe("speak-notification.ts integration", () => {
  test("Stop with lastMsg exits 0 and logs success voice profile", async () => {
    const before = logEntries().length;
    await run({
      ...BASE,
      hook_event_name: "Stop",
      last_assistant_message:
        "I've completed the refactor. The shared module now exports all helper functions correctly.",
    });
    const entries = logEntries();
    expect(entries.length).toBeGreaterThan(before);
    const entry = lastEntry()!;
    expect(entry.hook).toBe("Stop");
    expect(entry.voice_profile).toBe("success");
    expect(typeof entry.spoken).toBe("string");
    expect((entry.spoken as string).length).toBeGreaterThan(0);
  });

  test("Stop with question logs prompt voice profile", async () => {
    await run({
      ...BASE,
      hook_event_name: "Stop",
      last_assistant_message:
        "I've reviewed the implementation. Should I also update the test suite to cover these changes?",
    });
    const entry = lastEntry()!;
    expect(entry.hook).toBe("Stop");
    expect(entry.voice_profile).toBe("prompt");
  });

  test("Stop without lastMsg exits 0 without logging a message entry", async () => {
    const before = logEntries().length;
    const code = await run({ ...BASE, hook_event_name: "Stop" });
    expect(code).toBe(0);
    // only the "invoked" entry is logged, no message entry
    const after = logEntries();
    const newEntries = after.slice(before);
    expect(newEntries.every((e) => e.hook === "invoked")).toBe(true);
  });

  test("StopFailure logs error voice profile with error_details", async () => {
    await run({
      ...BASE,
      hook_event_name: "StopFailure",
      error: "rate_limit",
      error_details: "Rate limit exceeded, please wait before retrying.",
    });
    const entry = lastEntry()!;
    expect(entry.hook).toBe("StopFailure");
    expect(entry.voice_profile).toBe("error");
    expect(entry.spoken).toContain("Rate limit exceeded");
  });

  test("TaskCompleted logs success voice profile", async () => {
    await run({
      ...BASE,
      hook_event_name: "TaskCompleted",
      message: "Build pipeline completed successfully.",
    });
    const entry = lastEntry()!;
    expect(entry.hook).toBe("TaskCompleted");
    expect(entry.voice_profile).toBe("success");
    expect(entry.spoken).toContain("Build pipeline completed");
  });

  test("PreCompact logs warning voice profile", async () => {
    await run({ ...BASE, hook_event_name: "PreCompact" });
    const entry = lastEntry()!;
    expect(entry.hook).toBe("PreCompact");
    expect(entry.voice_profile).toBe("warning");
    expect(entry.spoken).toContain("compacting");
  });

  test("Notification idle_prompt logs default voice profile", async () => {
    await run({
      ...BASE,
      hook_event_name: "Notification",
      notification_type: "idle_prompt",
    });
    const entry = lastEntry()!;
    expect(entry.hook).toBe("Notification");
    expect(entry.voice_profile).toBe("default");
    expect(entry.spoken).toMatch(/^Hi EM_DASH_PAUSE I'm \w+\.$/);
  });

  test("Notification permission_prompt logs prompt voice profile", async () => {
    await run({
      ...BASE,
      hook_event_name: "Notification",
      notification_type: "permission_prompt",
      message: "Allow write to /etc/hosts?",
    });
    const entry = lastEntry()!;
    expect(entry.voice_profile).toBe("prompt");
  });

  test("down voxcpm daemon falls back to piper or say", async () => {
    await run({
      ...BASE,
      hook_event_name: "TaskCompleted",
      message: "Fallback check.",
    });
    const entry = lastEntry()!;
    expect(["piper", "fallback"]).toContain(entry.engine as string);
  });

  test("voxcpm daemon is used when healthy", async () => {
    // Minimal valid mono 16-bit 8kHz wav: RIFF header + 8 zero samples.
    const wavPath = `${tmpdir()}/test-voxcpm-${Date.now()}.wav`;
    const header = Buffer.alloc(44 + 16);
    header.write("RIFF", 0);
    header.writeUInt32LE(36 + 16, 4);
    header.write("WAVE", 8);
    header.write("fmt ", 12);
    header.writeUInt32LE(16, 16);
    header.writeUInt16LE(1, 20); // PCM
    header.writeUInt16LE(1, 22); // mono
    header.writeUInt32LE(8000, 24); // sample rate
    header.writeUInt32LE(16000, 28); // byte rate
    header.writeUInt16LE(2, 32); // block align
    header.writeUInt16LE(16, 34); // bits per sample
    header.write("data", 36);
    header.writeUInt32LE(16, 40);
    await Bun.write(wavPath, header);

    const server = Bun.serve({
      port: 0,
      fetch(req) {
        const url = new URL(req.url);
        if (url.pathname === "/health") {
          return Response.json({ status: "ok", model_loaded: true });
        }
        if (url.pathname === "/speak") {
          return Response.json({ wav_path: wavPath, elapsed_ms: 5 });
        }
        return new Response("not found", { status: 404 });
      },
    });
    try {
      await run(
        {
          ...BASE,
          hook_event_name: "TaskCompleted",
          message: "VoxCPM happy path.",
        },
        { CLAUDE_VOXCPM_URL: `http://127.0.0.1:${server.port}` },
      );
      const entry = lastEntry()!;
      expect(entry.engine).toBe("voxcpm");
      expect(typeof entry.audio_file).toBe("string");
    } finally {
      server.stop(true);
      if (existsSync(wavPath)) unlinkSync(wavPath);
    }
  });

  test("empty stdin exits 0 without logging", async () => {
    const before = logEntries().length;
    const proc = Bun.spawn(["bun", SCRIPT], {
      stdin: new Response(""),
      stdout: "ignore",
      stderr: "ignore",
      env: { ...process.env, CLAUDE_SPEAK_LOG: LOG },
    });
    const code = await proc.exited;
    expect(code).toBe(0);
    // invoked entry is still logged before stdin read
    expect(logEntries().length).toBeGreaterThanOrEqual(before);
  });
});
