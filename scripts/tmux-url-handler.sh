#!/usr/bin/env bash

set -euo pipefail

# Tmux URL Handler
# Handles tmux:// URLs to focus specific tmux sessions/windows/panes

# Configuration
LOG_FILE="${HOME}/.local/log/claude-hooks.log"

# Logging function
log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] [TMUX] $*" >> "$LOG_FILE" 2>/dev/null || true
}

# Ensure log directory exists
mkdir -p "$(dirname "$LOG_FILE")" 2>/dev/null || true

# Check if URL argument is provided
if [ $# -eq 0 ]; then
    echo "Usage: $0 <tmux://focus/session/window/pane>" >&2
    exit 1
fi

url="$1"
log "Processing URL: $url"

# Parse the URL with more flexible regex patterns
if [[ "$url" =~ ^tmux://focus/([^/]+)(/([^/]+)(/([^/]+))?)?$ ]]; then
    session="${BASH_REMATCH[1]}"
    window="${BASH_REMATCH[3]:-}"
    pane="${BASH_REMATCH[5]:-}"
    
    log "Parsed: session=$session, window=$window, pane=$pane"
    
    # URL decode components (handle %20 spaces, etc.)
    session=$(printf '%b\n' "${session//%/\\x}")
    if [ -n "$window" ]; then
        window=$(printf '%b\n' "${window//%/\\x}")
    fi
    if [ -n "$pane" ]; then
        pane=$(printf '%b\n' "${pane//%/\\x}")
    fi
    
    # Check if tmux server is running
    if ! tmux list-sessions >/dev/null 2>&1; then
        log "ERROR: Tmux server not running"
        echo "Tmux server is not running. Please start tmux first." >&2
        exit 1
    fi
    
    # Validate session exists
    if ! tmux has-session -t "$session" 2>/dev/null; then
        log "ERROR: Session '$session' not found"
        echo "Tmux session '$session' not found" >&2
        # List available sessions
        echo "Available sessions:" >&2
        tmux list-sessions -F "#{session_name}" 2>/dev/null || echo "No sessions found" >&2
        exit 1
    fi
    
    # Build tmux target based on what was provided
    target="$session"
    if [ -n "$window" ]; then
        target="$target:$window"
        if [ -n "$pane" ]; then
            target="$target.$pane"
        fi
    fi
    
    log "Attempting to focus: $target"
    
    # Try to switch to the specific target, with fallbacks
    if [ -n "$pane" ] && [ -n "$window" ]; then
        # Try pane first
        if tmux select-pane -t "$target" 2>/dev/null; then
            log "Successfully focused pane: $target"
        elif tmux select-window -t "$session:$window" 2>/dev/null; then
            log "Focused window (pane not found): $session:$window"
        else
            tmux switch-client -t "$session" 2>/dev/null || tmux attach-session -t "$session" 2>/dev/null
            log "Focused session (window not found): $session"
        fi
    elif [ -n "$window" ]; then
        # Try window
        if tmux select-window -t "$session:$window" 2>/dev/null; then
            log "Successfully focused window: $session:$window"
        else
            tmux switch-client -t "$session" 2>/dev/null || tmux attach-session -t "$session" 2>/dev/null
            log "Focused session (window not found): $session"
        fi
    else
        # Just session
        tmux switch-client -t "$session" 2>/dev/null || tmux attach-session -t "$session" 2>/dev/null
        log "Successfully focused session: $session"
    fi
    
    # Detect and activate terminal application
    terminal_activated=false
    
    # Check common terminal applications
    if [ "$TERM_PROGRAM" = "Apple_Terminal" ]; then
        osascript -e 'tell application "Terminal" to activate' 2>/dev/null && terminal_activated=true
    elif [ "$TERM_PROGRAM" = "iTerm.app" ]; then
        osascript -e 'tell application "iTerm2" to activate' 2>/dev/null && terminal_activated=true
    elif [ "$TERM_PROGRAM" = "WezTerm" ]; then
        osascript -e 'tell application "WezTerm" to activate' 2>/dev/null && terminal_activated=true
    elif pgrep -f kitty >/dev/null 2>&1; then
        osascript -e 'tell application "kitty" to activate' 2>/dev/null && terminal_activated=true
    elif pgrep -f alacritty >/dev/null 2>&1; then
        osascript -e 'tell application "Alacritty" to activate' 2>/dev/null && terminal_activated=true
    elif pgrep -f "Hyper" >/dev/null 2>&1; then
        osascript -e 'tell application "Hyper" to activate' 2>/dev/null && terminal_activated=true
    elif pgrep -f "Tabby" >/dev/null 2>&1; then
        osascript -e 'tell application "Tabby" to activate' 2>/dev/null && terminal_activated=true
    fi
    
    if $terminal_activated; then
        log "Terminal application activated"
    else
        log "WARNING: Could not detect or activate terminal application"
    fi
    
else
    log "ERROR: Invalid URL format: $url"
    echo "Invalid tmux URL format: $url" >&2
    echo "Expected format: tmux://focus/session[/window[/pane]]" >&2
    echo "Examples:" >&2
    echo "  tmux://focus/main" >&2
    echo "  tmux://focus/main/1" >&2
    echo "  tmux://focus/main/1/2" >&2
    exit 1
fi

log "URL handling completed successfully"
exit 0