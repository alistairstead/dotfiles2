#!/usr/bin/env bash
# @raycast.schemaVersion 1
# @raycast.title Toggle Claude Speech
# @raycast.mode compact
# @raycast.packageName Claude
# @raycast.icon 🔊
# @raycast.description Toggle the mute flag for the Claude speak-notification hook.

exec "$HOME/.local/bin/claude-speak-toggle"
