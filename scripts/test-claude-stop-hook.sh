#!/usr/bin/env bash

set -euo pipefail

# Test the Claude stop hook with different scenarios

SCRIPT_DIR="$(dirname "${BASH_SOURCE[0]}")"
HOOK_SCRIPT="$SCRIPT_DIR/claude-stop-hook.sh"

echo "Testing Claude stop hook..."
echo "Hook script: $HOOK_SCRIPT"
echo

# Create a temporary transcript file for testing
temp_transcript=$(mktemp)
echo "Sample transcript content for testing" > "$temp_transcript"
echo "This file will be deleted after testing" >> "$temp_transcript"

# Test 1: Normal stop with transcript
echo "Test 1: Normal stop with transcript file"
echo "This will show a dialog with 4 options including 'Show Transcript'"
test_json="{
  \"session_id\": \"test-session-456\",
  \"transcript_path\": \"$temp_transcript\",
  \"summary\": \"Test completed: Processed 5 files, made 3 edits\",
  \"type\": \"stop\"
}"

echo "$test_json" | "$HOOK_SCRIPT"
exit_code=$?

echo "Hook exited with code: $exit_code"
case $exit_code in
    0)
        echo "✓ Success - Output would be shown in transcript mode"
        ;;
    2)
        echo "✓ Blocking error - Error message would be sent back to Claude"
        ;;
    3)
        echo "✓ Non-blocking error - Error shown to user, execution continues"
        ;;
    *)
        echo "? Unknown exit code - execution continues"
        ;;
esac
echo

# Test 2: Stop without transcript
echo "Test 2: Stop without transcript file"
echo "This will show a dialog with 3 options (no 'Show Transcript')"
test_json='{
  "session_id": "test-no-transcript-789",
  "summary": "Test completed without transcript file",
  "type": "stop"
}'

echo "$test_json" | "$HOOK_SCRIPT"
exit_code=$?

echo "Hook exited with code: $exit_code"
case $exit_code in
    0)
        echo "✓ Success - Normal completion"
        ;;
    2)
        echo "✓ Blocking error - User requested blocking"
        ;;
    3)
        echo "✓ Non-blocking error - User flagged issue"
        ;;
    *)
        echo "? Unknown exit code"
        ;;
esac
echo

# Test 3: Stop with long summary
echo "Test 3: Stop with long summary (tests text escaping)"
long_summary="This is a very long summary with special characters: quotes \"test\" and apostrophes 'test' and other symbols @#$%^&*()_+-={}[]|\\:;\"'<>?,./"
test_json="{
  \"session_id\": \"test-long-summary-101\",
  \"summary\": \"$long_summary\",
  \"type\": \"stop\"
}"

echo "$test_json" | "$HOOK_SCRIPT"
exit_code=$?

echo "Hook exited with code: $exit_code"
echo "✓ Long summary test completed"
echo

# Clean up
rm -f "$temp_transcript"

echo "All stop hook tests completed!"
echo "Check log file at ~/.local/log/claude-hooks.log for detailed logging"