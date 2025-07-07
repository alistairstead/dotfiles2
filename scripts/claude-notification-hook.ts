#!/usr/bin/env bun

import { spawn } from "bun";
import { readFileSync, writeFileSync, mkdirSync, existsSync } from "fs";
import { dirname, join } from "path";
import { homedir } from "os";

// TypeScript interfaces
interface ClaudeNotification {
  message: string;
  session_id?: string;
  type?: "info" | "warning" | "error" | "success" | "prompt";
  prompt_type?: "choice" | "input" | "confirm";
  choices?: string[];
  callback_url?: string;
  expires_at?: string;
  metadata?: Record<string, unknown>;
}

interface NotificationConfig {
  notification_timeout: number;
  max_message_length: number;
  default_sound: string;
  log_level: "debug" | "info" | "warn" | "error";
  response_timeout: number;
}

interface NotificationResponse {
  action?: string;
  input?: string;
  timestamp: string;
  session_id: string;
}

class ClaudeNotificationHandler {
  private readonly logFile: string;
  private readonly configFile: string;
  private readonly responseDir: string;
  private readonly config: NotificationConfig;

  constructor() {
    this.logFile = join(homedir(), ".local", "log", "claude-hooks.log");
    this.configFile = join(homedir(), ".config", "claude-hooks", "config.json");
    this.responseDir = join(homedir(), ".local", "claude-responses");

    // Ensure directories exist
    this.ensureDirectories();

    // Load configuration
    this.config = this.loadConfig();

    this.log("info", "Hook started");
  }

  private ensureDirectories(): void {
    const dirs = [
      dirname(this.logFile),
      dirname(this.configFile),
      this.responseDir,
    ];

    dirs.forEach((dir) => {
      if (!existsSync(dir)) {
        mkdirSync(dir, { recursive: true });
      }
    });
  }

  private loadConfig(): NotificationConfig {
    const defaultConfig: NotificationConfig = {
      notification_timeout: 10,
      max_message_length: 256,
      default_sound: "default",
      log_level: "info",
      response_timeout: 30,
    };

    if (!existsSync(this.configFile)) {
      // Create default config file
      writeFileSync(this.configFile, JSON.stringify(defaultConfig, null, 2));
      return defaultConfig;
    }

    try {
      const configData = readFileSync(this.configFile, "utf8");
      return { ...defaultConfig, ...JSON.parse(configData) };
    } catch (error) {
      this.log("warn", `Failed to load config: ${error}. Using defaults.`);
      return defaultConfig;
    }
  }

  private log(level: string, message: string): void {
    const timestamp = new Date()
      .toISOString()
      .replace("T", " ")
      .substring(0, 19);
    const logEntry = `[${timestamp}] [NOTIFICATION] [${level.toUpperCase()}] ${message}\n`;

    try {
      writeFileSync(this.logFile, logEntry, { flag: "a" });
    } catch (error) {
      // Silently fail if logging fails
    }

    // Also log to console for debugging
    if (Bun.env.NODE_ENV === "development") {
      console.error(logEntry.trim());
    }
  }

  private async validateDependencies(): Promise<void> {
    try {
      // Use Bun's spawn to check for terminal-notifier
      const proc = spawn(["which", "terminal-notifier"], {
        stdout: "pipe",
        stderr: "pipe",
      });
      
      const exitCode = await proc.exited;

      if (exitCode !== 0) {
        const message =
          "terminal-notifier is required but not installed. Please install it with: brew install terminal-notifier";
        this.log("error", message);
        console.error(message);
        process.exit(1);
      }
    } catch (error) {
      const message =
        `Failed to validate dependencies: ${error}. Ensure terminal-notifier is installed.`;
      this.log("error", message);
      console.error(message);
      process.exit(1);
    }
  }

  private sanitizeInput(input: string): string {
    // Remove control characters and escape shell metacharacters
    return input
      .replace(/[\x00-\x1F\x7F]/g, '') // Remove control characters
      .replace(/[`$]/g, '\\$&') // Escape shell metacharacters
      .trim();
  }

  private truncateMessage(message: string): string {
    if (message.length > this.config.max_message_length) {
      return message.substring(0, this.config.max_message_length) + "...";
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

    return soundMap[type] || this.config.default_sound;
  }

  private async sendNotificationWithActions(
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
      // terminal-notifier supports up to 3 actions, so limit choices
      const limitedChoices = choices.slice(0, 3);
      args.push("-actions", limitedChoices.join(","));

      // Enable reply field for additional input
      if (choices.length > 3) {
        args.push("-reply");
      }
    }

    try {
      this.log("debug", `Sending notification with args: ${args.join(" ")}`);

      // Use Bun's spawn for better process control
      const proc = spawn(args, {
        stdout: "pipe",
        stderr: "pipe",
      });

      // Set up timeout - use response_timeout for interactive notifications
      const timeoutDuration = choices && choices.length > 0 
        ? this.config.response_timeout 
        : this.config.notification_timeout;
      const timeoutId = setTimeout(() => {
        proc.kill();
      }, timeoutDuration * 1000);

      const exitCode = await proc.exited;
      clearTimeout(timeoutId);

      if (exitCode === 0) {
        this.log("info", "Notification sent successfully");

        // Read response from stdout if available
        const stdout = await new Response(proc.stdout).text();
        if (stdout?.trim()) {
          this.log("debug", `User response: ${stdout.trim()}`);
          // terminal-notifier returns "@actionClicked" when an action is clicked
          // Extract the actual action name
          const actionMatch = stdout.trim().match(/@ACTIONCLICKED@(.+)/);
          if (actionMatch) {
            return actionMatch[1];
          }
          return stdout.trim();
        }
      } else {
        const stderr = await new Response(proc.stderr).text();
        throw new Error(`terminal-notifier exited with code ${exitCode}: ${stderr}`);
      }

      return null;
    } catch (error) {
      this.log("error", `Failed to send notification: ${error}`);

      // Fallback to basic macOS notification using Bun's spawn
      try {
        // Properly escape message and title for AppleScript
        const escapedMessage = message.replace(/\\/g, '\\\\').replace(/"/g, '\\"');
        const escapedTitle = title.replace(/\\/g, '\\\\').replace(/"/g, '\\"');
        const fallbackScript = `display notification "${escapedMessage}" with title "${escapedTitle}"`;
        const fallbackProc = spawn(["osascript", "-e", fallbackScript]);
        await fallbackProc.exited;
        this.log("info", "Fallback notification sent");
      } catch (fallbackError) {
        this.log("error", `Fallback notification failed: ${fallbackError}`);
        throw new Error("All notification methods failed");
      }

      return null;
    }
  }

  private async saveResponse(
    sessionId: string,
    response: string,
  ): Promise<void> {
    const responseData: NotificationResponse = {
      action: response,
      timestamp: new Date().toISOString(),
      session_id: sessionId,
    };

    const responseFile = join(this.responseDir, `${sessionId}.json`);

    try {
      writeFileSync(responseFile, JSON.stringify(responseData, null, 2));
      this.log("info", `Response saved for session ${sessionId}`);
    } catch (error) {
      this.log("error", `Failed to save response: ${error}`);
    }
  }


  private async readStdin(): Promise<string> {
    // Use Bun's native stdin reading for better performance
    try {
      const timeoutPromise = new Promise<never>((_, reject) => {
        setTimeout(() => reject(new Error("Timeout reading from stdin")), 30000);
      });
      
      const stdinPromise = Bun.stdin.text();
      
      return await Promise.race([stdinPromise, timeoutPromise]);
    } catch (error) {
      throw new Error(`Failed to read stdin: ${error}`);
    }
  }

  public async handleNotification(): Promise<void> {
    try {
      // Validate dependencies
      await this.validateDependencies();

      // Read input from stdin using Bun's efficient I/O
      const inputData = await this.readStdin();

      if (!inputData.trim()) {
        this.log("error", "No input provided");
        console.error("No input provided");
        process.exit(1);
      }

      // Parse and validate JSON
      let notification: ClaudeNotification;
      try {
        notification = JSON.parse(inputData);
      } catch (error) {
        this.log("error", `Invalid JSON input: ${error}`);
        console.error("Invalid JSON input");
        process.exit(1);
      }

      // Extract and sanitize notification details
      const message = this.truncateMessage(
        this.sanitizeInput(notification.message || "Claude Code notification"),
      );
      const sessionId = this.sanitizeInput(
        notification.session_id || "default",
      );
      const notificationType = notification.type || "info";
      const choices = notification.choices?.map((choice) =>
        this.sanitizeInput(choice),
      );

      // Build notification title
      const title = notification.session_id
        ? `Claude Code [${sessionId}]`
        : "Claude Code";

      // Get appropriate sound
      const sound = this.getNotificationSound(notificationType);

      this.log(
        "info",
        `Processing notification: type=${notificationType}, session=${sessionId}, hasChoices=${!!choices?.length}`,
      );

      // Send notification with potential interactive elements
      const response = await this.sendNotificationWithActions(
        title,
        message,
        sound,
        sessionId,
        choices,
      );

      // Handle response for prompt-type notifications
      if (notification.type === "prompt" && response) {
        await this.saveResponse(sessionId, response);

        // If there's a callback URL, send the response
        if (notification.callback_url) {
          // Validate callback URL before making request
          try {
            const url = new URL(notification.callback_url);
            if (!['http:', 'https:'].includes(url.protocol)) {
              throw new Error('Invalid protocol - only http/https allowed');
            }
            
            this.log(
              "info",
              `Response ready for callback: ${notification.callback_url}`,
            );

            await fetch(notification.callback_url, {
              method: "POST",
              headers: { "Content-Type": "application/json" },
              body: JSON.stringify({
                session_id: sessionId,
                response: response,
                timestamp: new Date().toISOString(),
              }),
            });
            this.log("info", "Response sent to callback URL");
          } catch (callbackError) {
            this.log("error", `Callback failed: ${callbackError}`);
          }
        }
      }

      this.log("info", "Hook completed successfully");
      process.exit(0);
    } catch (error) {
      this.log("error", `Hook failed: ${error}`);
      console.error(`Notification hook failed: ${error}`);
      process.exit(1);
    }
  }
}

// Main execution
if (import.meta.main) {
  const handler = new ClaudeNotificationHandler();
  handler.handleNotification().catch((error) => {
    console.error("Fatal error:", error);
    process.exit(1);
  });
}

export {
  ClaudeNotificationHandler,
  type ClaudeNotification,
  type NotificationConfig,
};
