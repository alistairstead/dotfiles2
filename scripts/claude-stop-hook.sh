#!/usr/bin/env bash

set -euo pipefail

# Claude Code Stop Hook
# Shows notification when Claude finishes and allows user to provide exit codes

# Configuration
LOG_FILE="${HOME}/.local/log/claude-hooks.log"
DIALOG_TIMEOUT=60
APPLESCRIPT_TIMEOUT=90

# Logging function
log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] [STOP] $*" >> "$LOG_FILE" 2>/dev/null || true
}

# Ensure log directory exists
mkdir -p "$(dirname "$LOG_FILE")" 2>/dev/null || true

log "Stop hook started"

# Validate dependencies
if ! command -v jq >/dev/null 2>&1; then
    log "ERROR: jq not found"
    echo "jq is required but not installed. Please install it with: brew install jq" >&2
    exit 1
fi

# Read and validate JSON input from stdin
if ! input=$(timeout 30 cat 2>/dev/null); then
    log "ERROR: Failed to read input or timeout"
    echo "Failed to read input from stdin" >&2
    exit 1
fi

if [ -z "$input" ]; then
    log "ERROR: Empty input"
    echo "No input provided" >&2
    exit 1
fi

# Validate JSON format
if ! echo "$input" | jq empty 2>/dev/null; then
    log "ERROR: Invalid JSON input"
    echo "Invalid JSON input" >&2
    exit 1
fi

# Extract details from JSON with validation
session_id=$(echo "$input" | jq -r '.session_id // ""' 2>/dev/null || echo "")
transcript_path=$(echo "$input" | jq -r '.transcript_path // ""' 2>/dev/null || echo "")
summary=$(echo "$input" | jq -r '.summary // "Claude Code has finished responding"' 2>/dev/null || echo "Claude Code has finished responding")

# Sanitize session_id
session_id=$(echo "$session_id" | tr -cd '[:alnum:]-_')

# Validate transcript path if provided
if [ -n "$transcript_path" ] && [ ! -f "$transcript_path" ]; then
    log "WARNING: Transcript path does not exist: $transcript_path"
    transcript_path=""
fi

# Build notification title
title="Claude Code Complete"
if [ -n "$session_id" ]; then
    title="$title [$session_id]"
fi

log "Showing dialog: session=$session_id, transcript=$transcript_path"

# Escape special characters for AppleScript
summary_escaped=$(echo "$summary" | sed 's/"/\\"/g' | sed "s/'/\\'/g")
title_escaped=$(echo "$title" | sed 's/"/\\"/g')

# Build dialog text with transcript option
dialog_text="$summary_escaped

Choose an action:"
button_list='"Continue", "Block", "Show Error"'

if [ -n "$transcript_path" ]; then
    dialog_text="$dialog_text
• Continue - Show output in transcript mode
• Block - Send error back to Claude and block stoppage  
• Show Error - Display error but continue normally
• Show Transcript - Open transcript file"
    button_list='"Continue", "Block", "Show Error", "Show Transcript"'
else
    dialog_text="$dialog_text
• Continue - Show output in transcript mode
• Block - Send error back to Claude and block stoppage
• Show Error - Display error but continue normally"
fi

# Send notification with actions using AppleScript with timeout
response=$(timeout "$APPLESCRIPT_TIMEOUT" osascript <<EOF 2>/dev/null || echo "timeout"
set dialogText to "$dialog_text"
set buttonList to {$button_list}

try
    tell application "System Events"
        activate
        set userChoice to button returned of (display dialog dialogText buttons buttonList default button "Continue" with title "$title_escaped" giving up after $DIALOG_TIMEOUT)
    end tell
    return userChoice
on error
    return "timeout"
end try
EOF
)

log "User response: $response"

# Handle user response
case "$response" in
    "Continue")
        log "User selected: Continue"
        echo "User selected: Continue - Claude session completed successfully"
        exit 0
        ;;
    "Block")
        log "User selected: Block"
        >&2 echo "User requested to block: Please review the session and address any issues"
        exit 2
        ;;
    "Show Error")
        log "User selected: Show Error"
        >&2 echo "User flagged issue: Session completed with warnings"
        exit 3
        ;;
    "Show Transcript")
        log "User selected: Show Transcript"
        if [ -n "$transcript_path" ] && [ -f "$transcript_path" ]; then
            open "$transcript_path" 2>/dev/null || true
        fi
        echo "User selected: Show Transcript - opening transcript file"
        exit 0
        ;;
    "timeout"|"")
        log "Dialog timeout or no response"
        echo "No user input received (timeout) - continuing normally"
        exit 0
        ;;
    *)
        log "Unknown response: $response"
        echo "Unknown user response - continuing normally"
        exit 0
        ;;
esac