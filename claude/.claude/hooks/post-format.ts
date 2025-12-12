#!/usr/bin/env bun

const projectDir = process.env.CLAUDE_PROJECT_DIR;

// Validate environment
if (!projectDir) {
  console.error("[post-format] CLAUDE_PROJECT_DIR not set");
  process.exit(1); // Non-blocking error - let Claude continue
}

try {
  // if projectDir does not contain biome.jsonc return early
  if (!fs.existsSync(path.join(projectDir, "biome.jsonc"))) {
    console.log(
      JSON.stringify({
        decision: "block",
        hookSpecificOutput: {
          additionalContext: `biome.jsonc not found`,
          hookEventName: "PostToolUse",
        },
        reason: "biome.jsonc not found",
      })
    );
    process.exit(0); // Exit 0 for JSON to be processed
  }

  const proc = Bun.spawnSync(["bun", "run", "lint"], {
    cwd: projectDir,
    stderr: "pipe",
    stdout: "pipe",
  });

  const stderr = proc.stderr?.toString() ?? "";
  const stdout = proc.stdout?.toString() ?? "";

  // Ultracite exits 0 even with errors, so parse output for "Found X errors"
  const hasErrors =
    proc.exitCode !== 0 || /Found \d+ error/.test(stdout + stderr);

  if (hasErrors) {
    // Exit 0 with JSON to provide blocking feedback to Claude
    // Note: keys must be sorted alphabetically for ultracite
    console.log(
      JSON.stringify({
        decision: "block",
        hookSpecificOutput: {
          additionalContext: `Lint errors found:\n\n${stdout}${stderr}`,
          hookEventName: "PostToolUse",
        },
        reason: "Code linting failed. Please review and fix the issues.",
      })
    );
    process.exit(0); // Exit 0 for JSON to be processed
  }

  // Success
  process.exit(0);
} catch (error) {
  // Log error for debugging (visible in verbose mode)
  console.error(`[post-format] Hook failed: ${error}`);
  process.exit(1); // Non-blocking - don't break Claude on hook bugs
}
