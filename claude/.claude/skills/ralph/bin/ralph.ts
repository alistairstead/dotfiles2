#!/usr/bin/env bun

import { spawn } from "bun";
import { existsSync, readFileSync, writeFileSync, mkdirSync } from "fs";
import { resolve, isAbsolute } from "path";
import { parseArgs } from "util";
import * as p from "@clack/prompts";

const COMPLETE_MARKER = "<promise>COMPLETE</promise>";
const PLANS_DIR = ".plans";

const PROMPT_TEMPLATE = `
You are continuing work on a long-running autonomous development task. This is a FRESH context window - you have no memory of previous sessions.

@.plans/prd.json @.plans/progress.txt

1. Find the highest-priority feature to work on and work only on that feature. This should be the one YOU decide has the highest priority - not necessarily the first in the list

2. Before changes, search codebase (don't assume not implemented).

3. Implement the requirements for the selected feature using TDD.

3. Run typecheck and tests: \`bun run typecheck && bun run test\`

4. Update prd.json marking completed work (CAREFULLY!)

**YOU CAN ONLY MODIFY ONE FIELD: "passes"**

After thorough verification, change:
\`\`\`json
"passes": false
\`\`\`
to:
\`\`\`json
"passes": true
\`\`\`

5. Append learnings to .plans/progress.txt for future iterations.

6. Commit changes: \`jj commit -m "description"\`

ONLY WORK ON A SINGLE FEATURE PER ITERATION.

If all features complete, output <promise>COMPLETE</promise>

When you learn something new about how to run commands or patterns in the code make sure you update @CLAUDE.md using a subagent but keep it brief. For example if you run commands multiple times before learning the correct command then that file should be updated.

For any bugs you notice, it's important to resolve them or document them in @prd.json to be resolved using a subagent even if it is unrelated to the current piece of work after documenting it in @prd.json

If tests unrelated to your work fail then it's your job to resolve these tests as part of the increment of change.

Remember: You have unlimited time across many sessions. Focus on quality over speed. Production-ready is the goal.
`;

const PRD_TEMPLATE = [
    {
      category: "ui",
      title: "Feature title",
      description: "What this feature does",
      passes: false,
      acceptance: ["Criteria 1", "Criteria 2"],
    },
];

interface Args {
  maxIterations?: string;
  once?: boolean;
  prompt?: string;
  cwd?: string;
  help?: boolean;
}

interface LoopResult {
  iterations: number;
  exitReason: "complete" | "max_iterations" | "error";
  lastExitCode: number;
}

function printHelp(): void {
  console.log(`
ralph - Ralph Wiggum agentic loop

Runs an autonomous loop invoking Claude repeatedly until completion
or max iterations reached.

Usage:
  ralph --max-iterations <n> --prompt <text|file> [--cwd <dir>]
  ralph --once --prompt <text|file> [--cwd <dir>]
  ralph generate prompt
  ralph generate prd

Options:
  --max-iterations <n>  Maximum loop iterations
  --once                Run single iteration (no loop)
  --prompt <text|file>  Prompt text or path to prompt file
  --cwd <dir>           Working directory (default: current dir)
  --help                Show this help message

The loop exits early if Claude outputs: ${COMPLETE_MARKER}

Examples:
  ralph generate prompt
  ralph generate prd
  ralph --once --prompt "Fix the failing tests"
  ralph --max-iterations 10 --prompt .plans/PROMPT.md
`);
}

function ensurePlansDir(): void {
  const plansPath = resolve(process.cwd(), PLANS_DIR);
  if (!existsSync(plansPath)) {
    mkdirSync(plansPath, { recursive: true });
  }
}

function generatePrompt(): number {
  ensurePlansDir();
  const filePath = resolve(process.cwd(), PLANS_DIR, "PROMPT.md");

  if (existsSync(filePath)) {
    console.error(`Error: ${filePath} already exists`);
    return 1;
  }

  writeFileSync(filePath, PROMPT_TEMPLATE);
  console.log(`Created ${filePath}`);
  return 0;
}

function generatePrd(): number {
  ensurePlansDir();
  const filePath = resolve(process.cwd(), PLANS_DIR, "prd.json");

  if (existsSync(filePath)) {
    console.error(`Error: ${filePath} already exists`);
    return 1;
  }

  writeFileSync(filePath, JSON.stringify(PRD_TEMPLATE, null, 2));
  console.log(`Created ${filePath}`);
  return 0;
}

function resolvePrompt(prompt: string, cwd: string): string {
  const promptPath = isAbsolute(prompt) ? prompt : resolve(cwd, prompt);

  if (existsSync(promptPath)) {
    return readFileSync(promptPath, "utf-8");
  }

  return prompt;
}

async function runOnce(promptContent: string, cwd: string): Promise<number> {
  const proc = spawn(["claude", "--permission-mode", "acceptEdits", "-p", promptContent], {
    cwd,
    stdin: "inherit",
    stdout: "inherit",
    stderr: "inherit",
  });

  return await proc.exited;
}

async function runIteration(
  promptContent: string,
  cwd: string,
): Promise<{ exitCode: number; output: string; complete: boolean }> {
  let output = "";

  const proc = spawn(["claude", "--permission-mode", "acceptEdits", "-p", promptContent], {
    cwd,
    terminal: {
      cols: process.stdout.columns || 80,
      rows: process.stdout.rows || 24,
      data(_terminal, data) {
        const chunk = data.toString();
        output += chunk;
        process.stdout.write(data);
      },
    },
  });

  const exitCode = await proc.exited;
  proc.terminal?.close();
  const complete = output.includes(COMPLETE_MARKER);

  return { exitCode, output, complete };
}

async function main(): Promise<number> {
  const rawArgs = Bun.argv.slice(2);

  // Handle generate subcommand
  if (rawArgs[0] === "generate") {
    const target = rawArgs[1];
    if (target === "prompt") {
      return generatePrompt();
    } else if (target === "prd") {
      return generatePrd();
    } else {
      console.error(`Error: Unknown generate target "${target}"`);
      console.error("Usage: ralph generate [prompt|prd]");
      return 1;
    }
  }

  const { values } = parseArgs({
    args: rawArgs,
    options: {
      "max-iterations": { type: "string", short: "n" },
      once: { type: "boolean" },
      prompt: { type: "string", short: "p" },
      cwd: { type: "string", short: "c" },
      help: { type: "boolean", short: "h" },
    },
    strict: true,
    allowPositionals: false,
  });

  const args: Args = {
    maxIterations: values["max-iterations"],
    once: values.once,
    prompt: values.prompt,
    cwd: values.cwd,
    help: values.help,
  };

  if (args.help) {
    printHelp();
    return 0;
  }

  if (!args.prompt) {
    console.error("Error: --prompt is required");
    printHelp();
    return 1;
  }

  const cwd = args.cwd ? resolve(args.cwd) : process.cwd();
  const promptContent = resolvePrompt(args.prompt, cwd);

  // Single iteration mode
  if (args.once) {
    return runOnce(promptContent, cwd);
  }

  // Loop mode requires --max-iterations
  if (!args.maxIterations) {
    console.error("Error: --max-iterations is required for loop mode (or use --once)");
    printHelp();
    return 1;
  }

  const maxIterations = parseInt(args.maxIterations, 10);
  if (isNaN(maxIterations) || maxIterations < 1) {
    console.error("Error: --max-iterations must be a positive integer");
    return 1;
  }

  // Start rich CLI output
  p.intro("Ralph Wiggum Agent Loop");

  const result: LoopResult = {
    iterations: 0,
    exitReason: "max_iterations",
    lastExitCode: 0,
  };

  for (let i = 1; i <= maxIterations; i++) {
    result.iterations = i;

    p.log.step(`Iteration ${i}/${maxIterations}`);

    try {
      const iterResult = await runIteration(promptContent, cwd);
      result.lastExitCode = iterResult.exitCode;

      if (iterResult.exitCode !== 0) {
        p.log.error(`Iteration ${i} failed (exit code: ${iterResult.exitCode})`);
        result.exitReason = "error";
        break;
      }

      if (iterResult.complete) {
        p.log.success(`Iteration ${i} - COMPLETE marker found`);
        result.exitReason = "complete";
        break;
      }

      p.log.success(`Iteration ${i} completed`);
    } catch (error) {
      p.log.error(`Iteration ${i} error: ${error}`);
      result.exitReason = "error";
      result.lastExitCode = 1;
      break;
    }
  }

  // Summary
  const exitMessages: Record<LoopResult["exitReason"], string> = {
    complete: "Task marked complete by agent",
    max_iterations: `Reached max iterations (${maxIterations})`,
    error: `Error in iteration ${result.iterations}`,
  };

  p.outro(
    `Finished after ${result.iterations} iteration${result.iterations !== 1 ? "s" : ""}\n` +
      `   Exit reason: ${exitMessages[result.exitReason]}`,
  );

  return result.exitReason === "error" ? 1 : 0;
}

// Main execution
if (import.meta.main) {
  main()
    .then((code) => process.exit(code))
    .catch((error) => {
      console.error("Fatal error:", error);
      process.exit(1);
    });
}

export { main, COMPLETE_MARKER };
