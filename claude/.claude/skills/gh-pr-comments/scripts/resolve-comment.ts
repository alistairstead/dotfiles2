#!/usr/bin/env bun
import { z } from "zod";

const ArgsSchema = z.object({
  threadId: z.string().min(1, "Thread ID is required"),
});

const RESOLVE_MUTATION = `
mutation($threadId: ID!) {
  resolveReviewThread(input: {threadId: $threadId}) {
    thread { isResolved }
  }
}`;

async function exec(cmd: string[]): Promise<{ stdout: string; exitCode: number }> {
  const proc = Bun.spawn(cmd, { stdout: "pipe", stderr: "pipe" });
  const stdout = await new Response(proc.stdout).text();
  const exitCode = await proc.exited;
  return { stdout: stdout.trim(), exitCode };
}

async function resolveThread(threadId: string): Promise<boolean> {
  const { stdout, exitCode } = await exec([
    "gh", "api", "graphql",
    "-f", `query=${RESOLVE_MUTATION}`,
    "-f", `threadId=${threadId}`,
  ]);

  if (exitCode !== 0) {
    console.error("GraphQL mutation failed");
    return false;
  }

  const data = JSON.parse(stdout);
  return data.data?.resolveReviewThread?.thread?.isResolved === true;
}

function parseArgs(): { threadId: string } {
  const argv = process.argv.slice(2);

  let threadId: string | undefined;

  for (let i = 0; i < argv.length; i++) {
    const arg = argv[i];
    if (arg === "--thread-id" && argv[i + 1]) {
      threadId = argv[++i];
    } else if (!arg.startsWith("-")) {
      threadId = arg;
    }
  }

  return ArgsSchema.parse({ threadId });
}

async function main() {
  const args = parseArgs();
  const resolved = await resolveThread(args.threadId);
  console.log(JSON.stringify({ resolved }));
  process.exit(resolved ? 0 : 1);
}

main().catch((err) => {
  console.error(err.message);
  process.exit(1);
});
