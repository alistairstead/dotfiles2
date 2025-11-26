#!/usr/bin/env bun

// =============================================================================
// CONFIGURATION BLOCK - Easily modify post-tool actions here
// =============================================================================

type ActionCondition = (filePath: string) => boolean;

interface FollowUpAction {
	name: string;
	command: string;
	condition: ActionCondition;
}

const POST_TOOL_ACTIONS: FollowUpAction[] = [
	{
		name: "typecheck",
		command: "bunx tsc --noEmit",
		condition: (filePath: string) =>
			/\.(ts|tsx)$/.test(filePath) && !filePath.includes("node_modules"),
	},
	{
		name: "format",
		command: "bunx biome check --write",
		condition: (filePath: string) =>
			/\.(ts|tsx|js|jsx|json)$/.test(filePath) &&
			!filePath.includes("node_modules"),
	},
];

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
		file_path?: string;
		abs_path?: string;
		[key: string]: any;
	};
	tool_response: {
		filePath?: string;
		success?: boolean;
		[key: string]: any;
	};
}

async function main() {
	try {
		// Read input from stdin
		const inputData = await Bun.stdin.text();

		if (!inputData.trim()) {
			process.exit(0);
		}

		// Parse JSON input
		const hookInput: HookInput = JSON.parse(inputData);

		// Extract file path from various possible locations
		const filePath =
			hookInput.tool_input?.file_path ||
			hookInput.tool_input?.abs_path ||
			hookInput.tool_response?.filePath;

		if (!filePath) {
			process.exit(0);
		}

		// Find matching actions for this file
		const commands: string[] = [];

		for (const action of POST_TOOL_ACTIONS) {
			if (action.condition(filePath)) {
				commands.push(action.command);
			}
		}

		// Output commands for Claude to execute
		if (commands.length > 0) {
			// Join multiple commands with &&
			console.log(commands.join(" && "));
		}

		process.exit(0);
	} catch (error) {
		// Fail silently - don't block Claude
		process.exit(0);
	}
}

main();
