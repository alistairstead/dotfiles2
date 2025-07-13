#!/usr/bin/env bun

import { writeFileSync, readFileSync, existsSync, mkdirSync } from "fs";
import { dirname, join } from "path";

// TypeScript interfaces
interface ToolInput {
  tool_name?: string;
  tool_input: {
    command?: string;
    description?: string;
    [key: string]: unknown;
  };
  session_id?: string;
}

interface LogEntry {
  timestamp: string;
  session_id?: string;
  tool_name?: string;
  command?: string;
  description?: string;
}

class ToolUseLogger {
  private readonly logFile: string;

  constructor() {
    // Get the directory where this script is located
    const scriptDir = dirname(new URL(import.meta.url).pathname);
    this.logFile = join(scriptDir, "..", "bash_commands.json");

    // Ensure the directory exists
    this.ensureDirectories();
  }

  private ensureDirectories(): void {
    const dir = dirname(this.logFile);
    if (!existsSync(dir)) {
      mkdirSync(dir, { recursive: true });
    }
  }

  private loadExistingLogs(): LogEntry[] {
    if (!existsSync(this.logFile)) {
      return [];
    }

    try {
      const data = readFileSync(this.logFile, "utf8");
      return JSON.parse(data);
    } catch (error) {
      console.error(`Warning: Failed to read existing logs: ${error}`);
      return [];
    }
  }

  private saveLogs(logs: LogEntry[]): void {
    try {
      writeFileSync(this.logFile, JSON.stringify(logs, null, 2));
    } catch (error) {
      console.error(`Error writing to log file: ${error}`);
      throw error;
    }
  }

  private createLogEntry(input: ToolInput): LogEntry {
    return {
      timestamp: new Date().toISOString(),
      session_id: input.session_id,
      tool_name: input.tool_name,
      command: input.tool_input?.command,
      description: input.tool_input?.description,
    };
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
        console.error("No input provided");
        process.exit(1);
      }

      // Parse JSON input
      let toolInput: ToolInput;
      try {
        toolInput = JSON.parse(inputData);
      } catch (error) {
        console.error(`Error parsing JSON input: ${error}`);
        process.exit(1);
      }

      // Create log entry
      const logEntry = this.createLogEntry(toolInput);

      // Load existing logs
      const logs = this.loadExistingLogs();

      // Append new log entry
      logs.push(logEntry);

      // Save back to file
      this.saveLogs(logs);

      console.log(`Tool input logged to ${this.logFile}`);
      process.exit(0);
    } catch (error) {
      console.error(`Error: ${error}`);
      process.exit(1);
    }
  }
}

// Main execution
if (import.meta.main) {
  const logger = new ToolUseLogger();
  logger.run().catch((error) => {
    console.error("Fatal error:", error);
    process.exit(1);
  });
}

export { ToolUseLogger, type ToolInput, type LogEntry };
