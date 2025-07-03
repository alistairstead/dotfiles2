#!/usr/bin/env bash

set -euo pipefail

# Claude Code Notification Hook
# Triggers macOS notification with enhanced error handling and features

# Configuration
SCRIPT_DIR="$(dirname "${BASH_SOURCE[0]}")"
LOG_FILE="${HOME}/.local/log/claude-hooks.log"
NOTIFICATION_TIMEOUT=10
MAX_MESSAGE_LENGTH=256

# Logging function
log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] [NOTIFICATION] $*" >> "$LOG_FILE" 2>/dev/null || true
}

# Ensure log directory exists
mkdir -p "$(dirname "$LOG_FILE")" 2>/dev/null || true

log "Hook started"

# Validate dependencies
if ! command -v jq >/dev/null 2>&1; then
    log "ERROR: jq not found"
    echo "jq is required but not installed. Please install it with: brew install jq" >&2
    exit 1
fi

if ! command -v terminal-notifier >/dev/null 2>&1; then
    log "ERROR: terminal-notifier not found"
    echo "terminal-notifier not found. Please install it with: brew install terminal-notifier" >&2
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

# Extract notification details from JSON with validation
message=$(echo "$input" | jq -r '.message // "Claude Code notification"' 2>/dev/null || echo "Claude Code notification")
session_id=$(echo "$input" | jq -r '.session_id // ""' 2>/dev/null || echo "")
notification_type=$(echo "$input" | jq -r '.type // "info"' 2>/dev/null || echo "info")

# Sanitize session_id (remove potentially harmful characters)
session_id=$(echo "$session_id" | tr -cd '[:alnum:]-_')

# Truncate message if too long
if [ ${#message} -gt $MAX_MESSAGE_LENGTH ]; then
    message="${message:0:$MAX_MESSAGE_LENGTH}..."
fi

# Build notification title
title="Claude Code"
if [ -n "$session_id" ]; then
    title="$title [$session_id]"
fi

# Choose sound based on notification type
case "$notification_type" in
    "error")
        sound="Basso"
        ;;
    "warning")
        sound="Purr"
        ;;
    "success")
        sound="Glass"
        ;;
    *)
        sound="default"
        ;;
esac

log "Sending notification: type=$notification_type, session=$session_id"

# Send notification with timeout
if timeout "$NOTIFICATION_TIMEOUT" terminal-notifier \
    -title "$title" \
    -message "$message" \
    -sound "$sound" \
    -group "claude-code-${session_id:-default}" \
    -timeout 30 \
    2>/dev/null; then
    log "Notification sent successfully"
else
    log "ERROR: Failed to send notification"
    echo "Failed to send notification" >&2
    exit 1
fi

log "Hook completed successfully"
exit 0