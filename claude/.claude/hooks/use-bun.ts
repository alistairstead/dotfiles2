#!/usr/bin/env bun

import { writeFileSync, readFileSync, existsSync, mkdirSync } from "fs";
import { dirname, join } from "path";

// TypeScript interfaces
interface ToolInput {
  tool_name?: string;
  tool_input: {
    command?: string;
    cd?: string;
  };
  session_id?: string;
}

interface LogEntry {
  session_id?: string;
  blocked_command: string;
  suggested_command: string;
  timestamp: string;
}

class BunEnforcementHook {
  private readonly logFile: string;

  constructor() {
    // Get the directory where this script is located
    const scriptDir = dirname(new URL(import.meta.url).pathname);
    this.logFile = join(scriptDir, "..", "bun_enforcement.json");

    // Ensure the directory exists
    this.ensureDirectories();
  }

  private ensureDirectories(): void {
    const dir = dirname(this.logFile);
    if (!existsSync(dir)) {
      mkdirSync(dir, { recursive: true });
    }
  }

  private createCommandPatterns() {
    return {
      npm: /\bnpm\s+/g,
      npx: /\bnpx\s+/g,
      yarn: /\byarn\s+/g,
      pnpm: /\bpnpm\s+/g,
    };
  }

  private checkForBlockedCommands(command: string): {
    blocked: string | null;
    suggested: string | null;
  } {
    const patterns = this.createCommandPatterns();

    // Check each pattern and return the first match
    for (const [tool, pattern] of Object.entries(patterns)) {
      if (pattern.test(command)) {
        let suggested: string;

        switch (tool) {
          case "npm":
            suggested = command.replace(/\bnpm\b/g, "bun");
            break;
          case "npx":
            suggested = command.replace(/\bnpx\b/g, "bunx");
            break;
          case "yarn":
            suggested = command.replace(/\byarn\b/g, "bun");
            break;
          case "pnpm":
            suggested = command.replace(/\bpnpm\b/g, "bun");
            break;
          default:
            suggested = command;
        }

        return {
          blocked: command,
          suggested: suggested,
        };
      }
    }

    return { blocked: null, suggested: null };
  }

  private loadExistingLogs(): LogEntry[] {
    if (!existsSync(this.logFile)) {
      return [];
    }

    try {
      const data = readFileSync(this.logFile, "utf8");
      return JSON.parse(data);
    } catch (error) {
      console.error(`Warning: Failed to read existing logs: ${error}`, {
        file: process.stderr,
      });
      return [];
    }
  }

  private saveLogs(logs: LogEntry[]): void {
    try {
      writeFileSync(this.logFile, JSON.stringify(logs, null, 2));
    } catch (error) {
      console.error(`Warning: Failed to save logs: ${error}`, {
        file: process.stderr,
      });
    }
  }

  private logBlockedCommand(
    sessionId: string | undefined,
    blockedCommand: string,
    suggestedCommand: string,
  ): void {
    const logs = this.loadExistingLogs();

    const logEntry: LogEntry = {
      session_id: sessionId,
      blocked_command: blockedCommand,
      suggested_command: suggestedCommand,
      timestamp: new Date().toISOString(),
    };

    logs.push(logEntry);
    this.saveLogs(logs);
  }

  private async readStdin(): Promise<string> {
    try {
      // Set a reasonable timeout for reading stdin
      const timeoutPromise = new Promise<never>((_, reject) => {
        setTimeout(
          () => reject(new Error("Timeout reading from stdin")),
          10000,
        );
      });

      const stdinPromise = Bun.stdin.text();

      return await Promise.race([stdinPromise, timeoutPromise]);
    } catch (error) {
      throw new Error(`Failed to read stdin: ${error}`);
    }
  }

  public async run(): Promise<void> {
    try {
      // Read input from stdin
      const inputData = await this.readStdin();

      if (!inputData.trim()) {
        // No input provided, exit silently
        process.exit(0);
      }

      // Parse JSON input
      let toolInput: ToolInput;
      try {
        toolInput = JSON.parse(inputData);
      } catch (error) {
        console.error(`Error parsing JSON input: ${error}`, {
          file: process.stderr,
        });
        process.exit(1);
      }

      // Extract command from tool input
      const command = toolInput.tool_input?.command;
      if (!command) {
        // No command to check, exit silently
        process.exit(0);
      }

      // Check for blocked commands
      const { blocked, suggested } = this.checkForBlockedCommands(command);

      if (blocked && suggested) {
        // Log the usage attempt
        this.logBlockedCommand(toolInput.session_id, blocked, suggested);

        // Send error message to stderr for Claude to see
        console.error("Error: Use 'bun/bunx' instead of 'npm/npx/yarn/pnpm'");

        // Exit with code 2 to signal Claude to correct the command
        process.exit(2);
      }

      // Command is acceptable, exit successfully
      process.exit(0);
    } catch (error) {
      console.error(`Error in use-bun hook: ${error}`, {
        file: process.stderr,
      });
      process.exit(1);
    }
  }
}

// Main execution
if (import.meta.main) {
  const hook = new BunEnforcementHook();
  hook.run().catch((error) => {
    console.error("Fatal error:", error);
    process.exit(1);
  });
}

export { BunEnforcementHook, type ToolInput, type LogEntry };
