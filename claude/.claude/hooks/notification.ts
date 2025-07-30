#!/usr/bin/env bun

import { spawn } from "bun";
import { writeFileSync, readFileSync, existsSync, mkdirSync } from "fs";
import { dirname, join } from "path";

// TypeScript interfaces
interface ToolInput {
  tool_name?: string;
  tool_input: {
    message?: string;
    type?: "info" | "warning" | "error" | "success" | "prompt";
    choices?: string[];
    callback_url?: string;
    [key: string]: unknown;
  };
  session_id?: string;
}

interface NotificationEntry {
  timestamp: string;
  session_id?: string;
  message: string;
  type: string;
  response?: string;
}

class NotificationHandler {
  private readonly logFile: string;

  constructor() {
    // Use /tmp for log files
    this.logFile = "/tmp/claude_notifications.json";

    // Ensure the directory exists
    this.ensureDirectories();
  }

  private ensureDirectories(): void {
    const dir = dirname(this.logFile);
    if (!existsSync(dir)) {
      mkdirSync(dir, { recursive: true });
    }
  }

  private async validateDependencies(): Promise<void> {
    try {
      const proc = spawn(["which", "terminal-notifier"], {
        stdout: "pipe",
        stderr: "pipe",
      });

      const exitCode = await proc.exited;

      if (exitCode !== 0) {
        console.error(
          "terminal-notifier is required but not installed. Please install it with: brew install terminal-notifier",
        );
        process.exit(1);
      }
    } catch (error) {
      console.error(
        `Failed to validate dependencies: ${error}. Ensure terminal-notifier is installed.`,
      );
      process.exit(1);
    }
  }

  private sanitizeInput(input: string): string {
    return input
      .replace(/[\x00-\x1F\x7F]/g, "") // Remove control characters
      .replace(/[`$]/g, "\\$&") // Escape shell metacharacters
      .trim();
  }

  private truncateMessage(message: string): string {
    const maxLength = 256;
    if (message.length > maxLength) {
      return message.substring(0, maxLength) + "...";
    }
    return message;
  }

  private getNotificationSound(type: string): string {
    const soundMap: Record<string, string> = {
      error: "Basso",
      warning: "Purr",
      success: "Glass",
      prompt: "Ping",
    };
    return soundMap[type] || "default";
  }

  private async sendNotification(
    title: string,
    message: string,
    sound: string,
    sessionId: string,
    choices?: string[],
  ): Promise<string | null> {
    const args = [
      "terminal-notifier",
      "-title",
      title,
      "-message",
      message,
      "-sound",
      sound,
      "-group",
      `claude-code-${sessionId}`,
      "-timeout",
      "30",
    ];

    // Add interactive elements for prompts
    if (choices && choices.length > 0) {
      const limitedChoices = choices.slice(0, 3);
      args.push("-actions", limitedChoices.join(","));
    }

    try {
      const proc = spawn(args, {
        stdout: "pipe",
        stderr: "pipe",
      });

      const timeoutId = setTimeout(() => {
        proc.kill();
      }, 30000);

      const exitCode = await proc.exited;
      clearTimeout(timeoutId);

      if (exitCode === 0) {
        const stdout = await new Response(proc.stdout).text();
        if (stdout?.trim()) {
          const actionMatch = stdout.trim().match(/@ACTIONCLICKED@(.+)/);
          if (actionMatch) {
            return actionMatch[1];
          }
          return stdout.trim();
        }
      } else {
        const stderr = await new Response(proc.stderr).text();
        throw new Error(
          `terminal-notifier exited with code ${exitCode}: ${stderr}`,
        );
      }

      return null;
    } catch (error) {
      // Fallback to basic macOS notification
      try {
        const escapedMessage = message
          .replace(/\\/g, "\\\\")
          .replace(/"/g, '\\"');
        const escapedTitle = title.replace(/\\/g, "\\\\").replace(/"/g, '\\"');
        const fallbackScript = `display notification "${escapedMessage}" with title "${escapedTitle}"`;
        const fallbackProc = spawn(["osascript", "-e", fallbackScript]);
        await fallbackProc.exited;
      } catch (fallbackError) {
        throw new Error("All notification methods failed");
      }

      return null;
    }
  }

  private loadExistingLogs(): NotificationEntry[] {
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

  private saveLogs(logs: NotificationEntry[]): void {
    try {
      writeFileSync(this.logFile, JSON.stringify(logs, null, 2));
    } catch (error) {
      console.error(`Error writing to log file: ${error}`);
      throw error;
    }
  }

  private logNotification(
    sessionId: string | undefined,
    message: string,
    type: string,
    response?: string,
  ): void {
    const logs = this.loadExistingLogs();

    const logEntry: NotificationEntry = {
      timestamp: new Date().toISOString(),
      session_id: sessionId,
      message: message,
      type: type,
      response: response,
    };

    logs.push(logEntry);
    this.saveLogs(logs);
  }

  private async readStdin(): Promise<string> {
    try {
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
      // Validate dependencies
      await this.validateDependencies();

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

      // Extract notification details
      const message = this.truncateMessage(
        this.sanitizeInput(
          toolInput.tool_input?.message || "Claude Code notification",
        ),
      );
      const sessionId = this.sanitizeInput(toolInput.session_id || "default");
      const notificationType = toolInput.tool_input?.type || "info";
      const choices = toolInput.tool_input?.choices?.map((choice) =>
        this.sanitizeInput(choice),
      );

      // Build notification title
      const title = toolInput.session_id
        ? `Claude Code [${sessionId}]`
        : "Claude Code";

      // Get appropriate sound
      const sound = this.getNotificationSound(notificationType);

      // Send notification
      const response = await this.sendNotification(
        title,
        message,
        sound,
        sessionId,
        choices,
      );

      // Log the notification
      this.logNotification(
        toolInput.session_id,
        message,
        notificationType,
        response || undefined,
      );

      // Handle callback if provided
      if (toolInput.tool_input?.callback_url && response) {
        try {
          const url = new URL(toolInput.tool_input.callback_url);
          if (!["http:", "https:"].includes(url.protocol)) {
            throw new Error("Invalid protocol - only http/https allowed");
          }

          await fetch(toolInput.tool_input.callback_url, {
            method: "POST",
            headers: { "Content-Type": "application/json" },
            body: JSON.stringify({
              session_id: sessionId,
              response: response,
              timestamp: new Date().toISOString(),
            }),
          });
        } catch (callbackError) {
          console.error(`Callback failed: ${callbackError}`);
        }
      }

      console.log(`Notification sent for session ${sessionId}`);
      process.exit(0);
    } catch (error) {
      console.error(`Error in notification hook: ${error}`);
      process.exit(1);
    }
  }
}

// Main execution
if (import.meta.main) {
  const handler = new NotificationHandler();
  handler.run().catch((error) => {
    console.error("Fatal error:", error);
    process.exit(1);
  });
}

export { NotificationHandler, type ToolInput, type NotificationEntry };
