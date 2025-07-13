# Claude Hooks

This directory contains hooks for Claude Code that enforce and enhance the development workflow.

## use-bun.ts

A TypeScript hook that enforces the use of Bun instead of other package managers (npm, yarn, pnpm, npx).

### Features

- **Real-time Command Interception**: Automatically detects and blocks npm/yarn/pnpm/npx commands
- **Intelligent Suggestions**: Provides corrected commands using bun/bunx equivalents
- **Comprehensive Logging**: Tracks all blocked commands with timestamps and session IDs
- **Error Reporting**: Returns appropriate exit codes to signal Claude to correct commands
- **Zero Dependencies**: Runs directly with Bun, no compilation needed

### Command Mappings

| Blocked Command        | Suggested Replacement   |
| ---------------------- | ----------------------- |
| `npm install`          | `bun install`           |
| `npm run build`        | `bun run build`         |
| `npx create-react-app` | `bunx create-react-app` |
| `yarn add lodash`      | `bun add lodash`        |
| `pnpm install`         | `bun install`           |

### Usage

The hook is automatically executed by Claude Code when the `terminal` tool is used. It:

1. Reads JSON input from stdin containing the terminal command
2. Checks if the command contains blocked package manager calls
3. If blocked: logs the attempt and exits with code 2 (signals correction needed)
4. If allowed: exits with code 0 (command proceeds)

### Input Format

```json
{
  "tool_input": {
    "command": "npm install express",
    "cd": "/path/to/project"
  },
  "session_id": "unique-session-id"
}
```

### Output

**Blocked Command:**

- Exit code: 2
- stderr: "Error: Use 'bun/bunx' instead of 'npm/npx/yarn/pnpm'"
- Log entry created in `bun_enforcement.json`

**Allowed Command:**

- Exit code: 0
- No output

### Log File

Blocked commands are logged to `bun_enforcement.json` with the following structure:

```json
[
  {
    "session_id": "test-session",
    "blocked_command": "npm install express",
    "suggested_command": "bun install express",
    "timestamp": "2025-07-13T15:34:12.508Z"
  }
]
```

### Testing

Test the hook manually:

```bash
# Test blocked command
echo '{"tool_input": {"command": "npm install express"}}' | ./use-bun.ts

# Test allowed command
echo '{"tool_input": {"command": "bun install express"}}' | ./use-bun.ts

# Test empty input
echo '' | ./use-bun.ts
```

### Installation

The hook is automatically executable when checked out. If needed:

```bash
chmod +x use-bun.ts
```

## log-tool-use.ts

A TypeScript hook that logs all tool usage for debugging and audit purposes.

### Features

- **Comprehensive Logging**: Records all tool invocations with timestamps
- **Session Tracking**: Associates logs with Claude session IDs
- **JSON Format**: Structured logging for easy parsing and analysis
- **Zero Dependencies**: Runs directly with Bun, no compilation needed
- **Error Resilience**: Handles malformed input gracefully

### Usage

The hook automatically logs tool usage when executed by Claude Code. It captures:

- Tool name (e.g., "terminal", "edit_file", "read_file")
- Command executed
- Description/parameters
- Session ID
- Timestamp

### Input Format

```json
{
  "tool_name": "terminal",
  "tool_input": {
    "command": "ls -la",
    "description": "List directory contents",
    "cd": "/path/to/directory"
  },
  "session_id": "unique-session-id"
}
```

### Output

**Successful Logging:**

- Exit code: 0
- stdout: "Tool input logged to /path/to/bash_commands.json"

**Error Cases:**

- Exit code: 1
- stderr: Error message

### Log File Structure

Tool usage is logged to `bash_commands.json` with the following structure:

```json
[
  {
    "timestamp": "2025-07-13T16:46:24.127Z",
    "session_id": "test-session-123",
    "tool_name": "terminal",
    "command": "ls -la",
    "description": "List directory contents"
  },
  {
    "timestamp": "2025-07-13T16:46:31.988Z",
    "session_id": "test-session-456",
    "tool_name": "edit_file",
    "command": "edit",
    "description": "Modify configuration"
  }
]
```

### Installation

The hook is automatically executable when checked out. If needed:

```bash
chmod +x log-tool-use.ts
```

## ts-lint.ts

A TypeScript hook that automatically runs ESLint on TypeScript/JavaScript files to catch code quality issues and style violations.

### Features

- **Automatic File Detection**: Only processes TypeScript/JavaScript files (.ts, .tsx, .js, .jsx)
- **ESLint Integration**: Uses bunx/npx to run ESLint with fallback support
- **Error Logging**: Records all linting errors with timestamps and session tracking
- **Smart Fallbacks**: Gracefully handles missing ESLint configuration or unavailable tools
- **Zero Dependencies**: Runs directly with Bun, no compilation needed
- **Timeout Protection**: Prevents hanging on long-running linting processes

### Usage

The hook automatically runs when Claude Code processes files. It:

1. Reads JSON input containing file path information
2. Checks if the file is a TypeScript/JavaScript file
3. Verifies the file exists
4. Runs ESLint to check for errors and style violations
5. If errors found: logs them and exits with code 2 (signals correction needed)
6. If no errors: exits with code 0 (file is clean)

### Supported File Types

- `.ts` - TypeScript files
- `.tsx` - TypeScript React files
- `.js` - JavaScript files
- `.jsx` - JavaScript React files

### Input Format

```json
{
  "tool_input": {
    "file_path": "src/components/MyComponent.tsx"
  },
  "session_id": "unique-session-id"
}
```

### Output

**Clean File:**

- Exit code: 0
- No output

**File with Errors:**

- Exit code: 2
- stderr: "ESLint errors found in {file_path}:"
- stderr: ESLint error details
- Log entry created in `eslint_errors.json`

**Skipped (non-TS/JS file, missing file, etc.):**

- Exit code: 0
- stdout: Debug info showing tool_input

### Error Log Structure

Linting errors are logged to `eslint_errors.json`:

```json
[
  {
    "file_path": "src/components/Component.tsx",
    "errors": "1:1 error 'React' is not defined react/jsx-no-undef\n2:5 warning Missing semicolon semi",
    "session_id": "test-session",
    "timestamp": "2025-07-13T16:51:07.876Z"
  }
]
```

### ESLint Configuration

The hook uses your project's ESLint configuration. Ensure you have:

- `eslint.config.js` (ESLint v9+) or `.eslintrc.*` files
- ESLint installed via npm/bun in your project
- Appropriate TypeScript and React plugins if needed

### Requirements

- Bun runtime (installed via your Nix configuration)
- ESLint available via bunx/npx in your project
- Execute permission on the script file

### Installation

The hook is automatically executable when checked out. If needed:

```bash
chmod +x ts-lint.ts
```

## notification.ts

A TypeScript hook that sends macOS notifications for Claude Code events and user interactions.

### Features

- **macOS Integration**: Uses terminal-notifier for rich notifications with sound and actions
- **Interactive Prompts**: Supports choice-based notifications with user responses
- **Fallback Support**: Falls back to AppleScript notifications if terminal-notifier fails
- **Comprehensive Logging**: Records all notifications with timestamps and responses
- **Callback Support**: Can send user responses to specified callback URLs
- **Zero Dependencies**: Runs directly with Bun, no compilation needed
- **Input Sanitization**: Protects against shell injection and control characters

### Usage

The hook processes notification requests from Claude Code and displays them to the user via macOS notifications.

### Supported Notification Types

- `info` - General information (default sound)
- `warning` - Warning messages (Purr sound)
- `error` - Error notifications (Basso sound)
- `success` - Success confirmations (Glass sound)
- `prompt` - Interactive prompts (Ping sound)

### Input Format

```json
{
  "tool_input": {
    "message": "Your notification message here",
    "type": "info",
    "choices": ["Yes", "No", "Cancel"],
    "callback_url": "https://example.com/callback"
  },
  "session_id": "unique-session-id"
}
```

### Output

**Successful Notification:**

- Exit code: 0
- stdout: "Notification sent for session {session_id}"
- Log entry created in `notifications.json`

**Error Cases:**

- Exit code: 1
- stderr: Error message

### Notification Log Structure

All notifications are logged to `notifications.json`:

```json
[
  {
    "timestamp": "2025-07-13T17:00:11.685Z",
    "session_id": "test-session",
    "message": "Test notification",
    "type": "info",
    "response": "Yes"
  }
]
```

### Interactive Features

For prompt-type notifications:

- Supports up to 3 action buttons
- Captures user responses
- Can send responses to callback URLs
- Logs user interactions for debugging

### Testing

Test the hook manually:

```bash
# Test basic notification
echo '{"tool_input": {"message": "Hello World", "type": "info"}}' | ./notification.ts

# Test interactive prompt
echo '{"tool_input": {"message": "Choose option", "type": "prompt", "choices": ["Yes", "No"]}}' | ./notification.ts

# Test error handling
echo '' | ./notification.ts
```

### Dependencies

- **terminal-notifier**: Primary notification system
  ```bash
  brew install terminal-notifier
  ```
- **AppleScript**: Fallback notification system (built into macOS)

### Requirements

- Bun runtime (installed via your Nix configuration)
- terminal-notifier (recommended) or macOS with AppleScript support
- Execute permission on the script file

### Installation

The hook is automatically executable when checked out. If needed:

```bash
chmod +x notification.ts
```
