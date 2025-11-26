#!/usr/bin/env bun

import { existsSync, mkdirSync, readFileSync, writeFileSync } from "fs";
import { dirname } from "path";

// =============================================================================
// CONFIGURATION BLOCK - Easily modify restrictions here
// =============================================================================

interface RestrictionRule {
	condition: (input: any) => boolean;
	message: string;
}

const TOOL_RESTRICTIONS: Record<string, RestrictionRule[]> = {
	// File operation restrictions
	fileOperations: [
		{
			condition: (input: any) => {
				const filePath = input.file_path || input.abs_path;
				return filePath && filePath.includes("/node_modules/");
			},
			message: "Avoid modifying files in node_modules directory",
		},
		{
			condition: (input: any) => {
				const filePath = input.file_path || input.abs_path;
				return (
					filePath &&
					filePath.endsWith(".lock") &&
					!filePath.includes("bun.lockb")
				);
			},
			message:
				"Use bun.lockb instead of other lock files (package-lock.json, yarn.lock, pnpm-lock.yaml)",
		},
	],

	// Add bash command restrictions for tools that use commands
	bashCommands: [
		{
			condition: (input: any) => {
				const command = input.command;
				return command && /^grep\b(?!.*\|)/.test(command);
			},
			message:
				"Use 'rg' (ripgrep) instead of 'grep' for better performance and features",
		},
		{
			condition: (input: any) => {
				const command = input.command;
				return command && /^find\s+\S+\s+-name\b/.test(command);
			},
			message:
				"Use 'rg --files | rg pattern' or 'rg --files -g pattern' instead of 'find -name' for better performance",
		},
		{
			condition: (input: any) => {
				const command = input.command;
				return command && /\b(npm|npx|yarn|pnpm)\s+/.test(command);
			},
			message: "Use 'bun/bunx' instead of 'npm/npx/yarn/pnpm'",
		},
		{
			condition: (input: any) => {
				const command = input.command;
				return command && /\bbun\s+test\b/.test(command);
			},
			message: "Use 'bun run test' to run tests with vitest",
		},
	],
};

// =============================================================================
// END CONFIGURATION BLOCK
// =============================================================================

interface HookInput {
	session_id: string;
	transcript_path: string;
	cwd: string;
	hook_event_name: string;
	tool_name: string;
	tool_input: {
		[key: string]: any;
	};
}

interface LogEntry {
	session_id: string;
	tool_name: string;
	restriction_message: string;
	tool_input: any;
	timestamp: string;
}

class PreUseToolHook {
	private readonly logFile: string;

	constructor() {
		this.logFile = "/tmp/claude_pre_use_tool.json";
		this.ensureDirectories();
	}

	private ensureDirectories(): void {
		const dir = dirname(this.logFile);
		if (!existsSync(dir)) {
			mkdirSync(dir, { recursive: true });
		}
	}

	private checkRestrictions(toolInput: any): string | null {
		// Check all restriction categories
		for (const [category, rules] of Object.entries(TOOL_RESTRICTIONS)) {
			for (const rule of rules) {
				if (rule.condition(toolInput)) {
					return rule.message;
				}
			}
		}
		return null;
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

	private logRestriction(
		sessionId: string,
		toolName: string,
		message: string,
		toolInput: any,
	): void {
		const logs = this.loadExistingLogs();

		const logEntry: LogEntry = {
			session_id: sessionId,
			tool_name: toolName,
			restriction_message: message,
			tool_input: toolInput,
			timestamp: new Date().toISOString(),
		};

		logs.push(logEntry);
		this.saveLogs(logs);
	}

	public async run(): Promise<void> {
		try {
			// Read input from stdin
			const inputData = await Bun.stdin.text();

			if (!inputData.trim()) {
				process.exit(0);
			}

			// Parse JSON input
			const hookInput: HookInput = JSON.parse(inputData);

			// Check for restrictions
			const restrictionMessage = this.checkRestrictions(hookInput.tool_input);

			if (restrictionMessage) {
				// Log the restriction
				this.logRestriction(
					hookInput.session_id,
					hookInput.tool_name,
					restrictionMessage,
					hookInput.tool_input,
				);

				// Send error message to stderr for Claude to see
				console.error(`Error: ${restrictionMessage}`);

				// Exit with code 2 to signal Claude to correct the action
				process.exit(2);
			}

			// Action is acceptable, exit successfully
			process.exit(0);
		} catch (error) {
			console.error(`Error in pre-use-tool hook: ${error}`, {
				file: process.stderr,
			});
			process.exit(1);
		}
	}
}

// Main execution
if (import.meta.main) {
	const hook = new PreUseToolHook();
	hook.run().catch((error) => {
		console.error("Fatal error:", error);
		process.exit(1);
	});
}
