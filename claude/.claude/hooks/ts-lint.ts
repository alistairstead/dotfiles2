#!/usr/bin/env bun

import { spawn } from "bun";
import { writeFileSync, readFileSync, existsSync, mkdirSync } from "fs";
import { dirname, join } from "path";

// TypeScript interfaces
interface ToolInput {
  tool_name?: string;
  tool_input: {
    file_path?: string;
    [key: string]: unknown;
  };
  session_id?: string;
}

interface ErrorEntry {
  file_path: string;
  errors: string;
  session_id?: string;
  timestamp: string;
}

class TypeScriptLintHook {
  private readonly logFile: string;

  constructor() {
    // Get the directory where this script is located
    const scriptDir = dirname(new URL(import.meta.url).pathname);
    this.logFile = join(scriptDir, "..", "eslint_errors.json");

    // Ensure the directory exists
    this.ensureDirectories();
  }

  private ensureDirectories(): void {
    const dir = dirname(this.logFile);
    if (!existsSync(dir)) {
      mkdirSync(dir, { recursive: true });
    }
  }

  private isTypeScriptFile(filePath: string): boolean {
    const tsExtensions = [".ts", ".tsx", ".js", ".jsx"];
    return tsExtensions.some((ext) => filePath.endsWith(ext));
  }

  private async fileExists(filePath: string): Promise<boolean> {
    try {
      const file = Bun.file(filePath);
      return await file.exists();
    } catch {
      return false;
    }
  }

  private loadExistingErrors(): ErrorEntry[] {
    if (!existsSync(this.logFile)) {
      return [];
    }

    try {
      const data = readFileSync(this.logFile, "utf8");
      return JSON.parse(data);
    } catch (error) {
      console.error(`Warning: Failed to read existing errors: ${error}`);
      return [];
    }
  }

  private saveErrors(errors: ErrorEntry[]): void {
    try {
      writeFileSync(this.logFile, JSON.stringify(errors, null, 2));
    } catch (error) {
      console.error(`Error writing to error log file: ${error}`);
      throw error;
    }
  }

  private logError(
    filePath: string,
    errorOutput: string,
    sessionId?: string,
  ): void {
    const errors = this.loadExistingErrors();

    const errorEntry: ErrorEntry = {
      file_path: filePath,
      errors: errorOutput,
      session_id: sessionId,
      timestamp: new Date().toISOString(),
    };

    errors.push(errorEntry);
    this.saveErrors(errors);
  }

  private async runESLint(filePath: string): Promise<{
    success: boolean;
    output: string;
  }> {
    try {
      // Use Bun's spawn to run ESLint - prefer bunx over npx
      const proc = spawn(["bunx", "eslint", filePath, "--format", "compact"], {
        stdout: "pipe",
        stderr: "pipe",
      });

      // Set timeout for ESLint execution
      const timeoutId = setTimeout(() => {
        proc.kill();
      }, 30000); // 30 second timeout

      const exitCode = await proc.exited;
      clearTimeout(timeoutId);

      const stdout = await new Response(proc.stdout).text();
      const stderr = await new Response(proc.stderr).text();

      if (exitCode !== 0 && (stdout || stderr)) {
        return {
          success: false,
          output: stdout || stderr,
        };
      }

      return {
        success: true,
        output: "",
      };
    } catch (error) {
      if (error instanceof Error && error.message.includes("timeout")) {
        throw new Error("ESLint check timed out");
      }

      // If bunx eslint fails, try npx as fallback
      try {
        const proc = spawn(["npx", "eslint", filePath, "--format", "compact"], {
          stdout: "pipe",
          stderr: "pipe",
        });

        const timeoutId = setTimeout(() => {
          proc.kill();
        }, 30000);

        const exitCode = await proc.exited;
        clearTimeout(timeoutId);

        const stdout = await new Response(proc.stdout).text();
        const stderr = await new Response(proc.stderr).text();

        if (exitCode !== 0 && (stdout || stderr)) {
          return {
            success: false,
            output: stdout || stderr,
          };
        }

        return {
          success: true,
          output: "",
        };
      } catch (fallbackError) {
        // ESLint not available, return success to skip check
        return {
          success: true,
          output: "",
        };
      }
    }
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
        console.error(`Error parsing JSON input: ${error}`);
        process.exit(1);
      }

      // Debug output (matching original behavior)
      console.log(toolInput.tool_input);

      // Get file path from tool input
      const filePath = toolInput.tool_input?.file_path;
      if (!filePath) {
        // No file path to check, exit silently
        process.exit(0);
      }

      // Only check TypeScript/JavaScript files
      if (!this.isTypeScriptFile(filePath)) {
        // Not a TS/JS file, exit silently
        process.exit(0);
      }

      // Check if file exists
      if (!(await this.fileExists(filePath))) {
        // File doesn't exist, exit silently
        process.exit(0);
      }

      // Run ESLint check
      try {
        const { success, output } = await this.runESLint(filePath);

        if (!success && output) {
          // Log the error for debugging
          this.logError(filePath, output, toolInput.session_id);

          // Send error message to stderr for Claude to see
          console.error(`ESLint errors found in ${filePath}:`);
          console.error(output);

          // Exit with code 2 to signal Claude to correct
          process.exit(2);
        }

        // No errors found, exit successfully
        process.exit(0);
      } catch (error) {
        if (error instanceof Error && error.message.includes("timeout")) {
          console.error("ESLint check timed out");
          process.exit(0);
        }
        throw error;
      }
    } catch (error) {
      console.error(`Error in eslint hook: ${error}`);
      process.exit(1);
    }
  }
}

// Main execution
if (import.meta.main) {
  const hook = new TypeScriptLintHook();
  hook.run().catch((error) => {
    console.error("Fatal error:", error);
    process.exit(1);
  });
}

export { TypeScriptLintHook, type ToolInput, type ErrorEntry };
