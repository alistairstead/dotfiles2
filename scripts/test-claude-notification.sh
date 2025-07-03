#!/usr/bin/env bash

set -euo pipefail

# Test the Claude notification hook with different scenarios

SCRIPT_DIR="$(dirname "${BASH_SOURCE[0]}")"
HOOK_SCRIPT="$SCRIPT_DIR/claude-notification-hook.sh"

echo "Testing Claude notification hook..."
echo "Hook script: $HOOK_SCRIPT"
echo "Current TMUX: ${TMUX:-not set}"
echo

# Test 1: Basic notification
echo "Test 1: Basic notification"
test_json='{
  "message": "Test notification from Claude Code",
  "session_id": "test-session-123",
  "type": "info"
}'
echo "$test_json" | "$HOOK_SCRIPT"
echo "✓ Basic notification test completed"
echo

# Test 2: Error notification
echo "Test 2: Error notification (should use Basso sound)"
test_json='{
  "message": "An error occurred during processing",
  "session_id": "test-error-456",
  "type": "error"
}'
echo "$test_json" | "$HOOK_SCRIPT"
echo "✓ Error notification test completed"
echo

# Test 3: Warning notification
echo "Test 3: Warning notification (should use Purr sound)"
test_json='{
  "message": "Warning: Some issues were found",
  "session_id": "test-warning-789",
  "type": "warning"
}'
echo "$test_json" | "$HOOK_SCRIPT"
echo "✓ Warning notification test completed"
echo

# Test 4: Success notification
echo "Test 4: Success notification (should use Glass sound)"
test_json='{
  "message": "Task completed successfully!",
  "session_id": "test-success-101",
  "type": "success"
}'
echo "$test_json" | "$HOOK_SCRIPT"
echo "✓ Success notification test completed"
echo

# Test 5: Long message (should be truncated)
echo "Test 5: Long message (should be truncated at 256 chars)"
long_message="This is a very long message that should be truncated because it exceeds the maximum length limit of 256 characters. This is just padding text to make the message longer and longer until it definitely exceeds the limit and gets truncated with ellipsis at the end."
test_json="{
  \"message\": \"$long_message\",
  \"session_id\": \"test-long-102\",
  \"type\": \"info\"
}"
echo "$test_json" | "$HOOK_SCRIPT"
echo "✓ Long message test completed"
echo

# Test 6: No session ID
echo "Test 6: No session ID"
test_json='{
  "message": "Notification without session ID",
  "type": "info"
}'
echo "$test_json" | "$HOOK_SCRIPT"
echo "✓ No session ID test completed"
echo

echo "All notification tests completed!"
echo "Check notifications and log file at ~/.local/log/claude-hooks.log"