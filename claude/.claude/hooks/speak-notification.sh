#!/bin/bash
# Speak Claude Code hook notifications with contextual voice/rate
# Reads hook JSON payload from stdin

INPUT=$(cat)

# Log raw payload for debugging (remove after verifying field paths)
echo "$INPUT" > /tmp/hook-notification-payload.json

# Extract fields — try top-level first, fall back to nested
HOOK=$(echo "$INPUT" | jq -r '.hook_event_name // "Notification"')
MESSAGE=$(echo "$INPUT" | jq -r '.message // .tool_input.message // empty')
TYPE=$(echo "$INPUT" | jq -r '.tool_input.type // .notification_type // "info"')

# Randomisation helper
pick() { local arr=("$@"); echo "${arr[$((RANDOM % ${#arr[@]}))]}"; }

# Greeting pool
GREETING=$(pick "Hey." "Hi." "Oi." "Right." "Listen up." "Heads up.")

# Override message for events that don't carry one
if [ -z "$MESSAGE" ] || [ "$MESSAGE" = "null" ]; then
  case "$HOOK" in
    Stop) MESSAGE=$(pick \
      "I've finished." \
      "I'm done." \
      "All wrapped up." \
      "That's done." \
      "Sorted." \
      "I've completed the task." \
    ) ;;
    *) MESSAGE="I have a notification." ;;
  esac
fi

# Piper voice models and contextual prefix by event type
PIPER_DIR="$HOME/.local/share/piper-voices"
case "$TYPE" in
  error)
    PIPER_MODEL="en_GB-southern_english_female-low"
    SAY_VOICE="Serena (Premium)"; SAY_RATE=160
    PREFIX=$(pick "I've hit a problem." "Something went wrong." "There's an issue." "I've run into trouble.")
    ;;
  warning)
    PIPER_MODEL="en_GB-northern_english_male-medium"
    SAY_VOICE="Daniel (Enhanced)"; SAY_RATE=170
    PREFIX=$(pick "Just so you know," "Quick heads up," "Be aware," "Worth noting,")
    ;;
  success)
    PIPER_MODEL="en_GB-alba-medium"
    SAY_VOICE="Jamie (Premium)"; SAY_RATE=180
    PREFIX=$(pick "Done." "Sorted." "All good." "That worked." "Nailed it.")
    ;;
  prompt)
    PIPER_MODEL="en_GB-southern_english_female-low"
    SAY_VOICE="Serena (Premium)"; SAY_RATE=160
    PREFIX=$(pick "I need your input." "Over to you." "I need a decision." "Quick question.")
    ;;
  *)
    PIPER_MODEL="en_GB-alba-medium"
    SAY_VOICE="Jamie (Premium)"; SAY_RATE=175
    PREFIX=""
    ;;
esac

# Truncate — long messages sound terrible spoken
SHORT=$(echo "$MESSAGE" | cut -c1-120)

# Build spoken text
SPOKEN="$GREETING $PREFIX $SHORT"

# TTS priority: piper (neural) > Swift binary (Siri voices) > say (basic)
PIPER_ONNX="$PIPER_DIR/${PIPER_MODEL}.onnx"
if mise exec pipx:piper-tts -- which piper &>/dev/null && [ -f "$PIPER_ONNX" ]; then
  echo "$SPOKEN" | mise exec pipx:piper-tts -- piper \
    --model "$PIPER_ONNX" \
    --output_file /tmp/claude-speak.wav 2>/dev/null && afplay /tmp/claude-speak.wav &
elif [ -x ~/.claude/hooks/speak ]; then
  VOICE_ARG=""
  [ -n "$VOICE" ] && VOICE_ARG="-v $VOICE"
  ~/.claude/hooks/speak $VOICE_ARG -r "$RATE" "$SPOKEN" &
else
  say -v "$SAY_VOICE" -r "$SAY_RATE" "$SPOKEN" &
fi
