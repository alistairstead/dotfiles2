#!/bin/bash
# Speak Claude Code hook notifications with contextual voice/rate
# Reads hook JSON payload from stdin

INPUT=$(cat)

# Log raw payload for last-invocation inspection
echo "$INPUT" >/tmp/hook-notification-payload.json

# Extract fields
HOOK=$(echo "$INPUT" | jq -r '.hook_event_name // "Notification"')
MESSAGE=$(echo "$INPUT" | jq -r '.message // .tool_input.message // empty')
TYPE=$(echo "$INPUT" | jq -r '.tool_input.type // .notification_type // "info"')
LAST_MSG=$(echo "$INPUT" | jq -r '.last_assistant_message // empty')

# Structured log — one entry per invocation
echo "$INPUT" | jq -c --arg type "$TYPE" --arg msg "$MESSAGE" \
    '{ts: (now | todate), hook: .hook_event_name, type: $type, msg: $msg, last: .last_assistant_message}' \
    >> /tmp/speak-notification.log

# Randomisation helper
pick() {
    local arr=("$@")
    echo "${arr[$((RANDOM % ${#arr[@]}))]}"
}

# Greeting pool
GREETING=$(pick "Hey. . ." "Hi. . ." "Right. . ." "Heads up. . .")

# For Stop events: if last message ends with '?' speak it directly as a question
IS_QUESTION=false
if [ "$HOOK" = "Stop" ] && [ -n "$LAST_MSG" ] && [ "$LAST_MSG" != "null" ]; then
    TRIMMED=$(echo "$LAST_MSG" | sed 's/[[:space:]]*$//')
    if [[ "$TRIMMED" == *"?" ]]; then
        IS_QUESTION=true
    fi
fi

# Override message for events that don't carry one
if [ "$IS_QUESTION" = true ]; then
    # Speak the actual question verbatim — no greeting, no prefix, no truncation
    SPOKEN="$LAST_MSG"
    TYPE="prompt"
elif [ -z "$MESSAGE" ] || [ "$MESSAGE" = "null" ]; then
    case "$HOOK" in
    Stop) MESSAGE=$(
        pick \
            "I've finished." \
            "I'm done." \
            "All wrapped up." \
            "That's done." \
            "Sorted." \
            "I've completed the task."
    ) ;;
    *) MESSAGE="I have a notification." ;;
    esac
fi

# Available downloaded piper voice models in ~/.local/share/piper-voices/:
#
#   en_GB-southern_english_female-low   — British female, southern accent (low quality)
#   en_GB-northern_english_male-medium  — British male, northern accent (medium quality)
#   en_GB-alba-medium                   — British female, Scottish-influenced (medium quality)
#   en_GB-cori-high                     — British female, highest quality GB option
#   en_GB-jenny_dioco-medium            — British female, distinctive character (medium quality)
#   en_GB-semaine-medium                — Multi-speaker GB: speaker 0=Prudence, 1=Spike, 2=Obadiah, 3=Poppy
#   en_US-lessac-high                   — American male, clear/professional (high quality)
#
# Current assignment: Jenny for all event types.

PIPER_DIR="$HOME/.local/share/piper-voices"
case "$TYPE" in
error)
    PIPER_MODEL="en_GB-jenny_dioco-medium"
    PIPER_LENGTH=1.2 PIPER_NOISE=0.9 PIPER_NOISEW=0.9 PIPER_SILENCE=0.4
    SAY_VOICE="Serena (Premium)"
    SAY_RATE=160
    PREFIX=$(pick "I've hit a problem, and need help." "Something went wrong, I don't know how to proceed" "There's an issue, many many issues." "I've run into B.I.G. trouble!")
    ;;
warning)
    PIPER_MODEL="en_GB-jenny_dioco-medium"
    PIPER_LENGTH=1.15 PIPER_NOISE=0.8 PIPER_NOISEW=0.8 PIPER_SILENCE=0.3
    SAY_VOICE="Daniel (Enhanced)"
    SAY_RATE=170
    PREFIX=$(pick "Just so you know," "Quick heads up," "Be aware," "Worth noting,")
    ;;
success)
    PIPER_MODEL="en_GB-jenny_dioco-medium"
    PIPER_LENGTH=1.15 PIPER_NOISE=0.5 PIPER_NOISEW=0.6 PIPER_SILENCE=0.2
    SAY_VOICE="Jamie (Premium)"
    SAY_RATE=180
    PREFIX=$(pick "Done! . ." "Sorted! . ." "All good! . ." "That kinda worked. . . " "Naaiiiiled it! . .")
    ;;
prompt)
    PIPER_MODEL="en_GB-jenny_dioco-medium"
    PIPER_LENGTH=1.15 PIPER_NOISE=0.7 PIPER_NOISEW=0.7 PIPER_SILENCE=0.3
    SAY_VOICE="Serena (Premium)"
    SAY_RATE=160
    PREFIX=$(pick "I need your input." "Over to you!" "I need a decision!" "Quiiiiick, question?")
    ;;
*)
    PIPER_MODEL="en_GB-jenny_dioco-medium"
    PIPER_LENGTH=1.15 PIPER_NOISE=0.667 PIPER_NOISEW=0.8 PIPER_SILENCE=0.2
    SAY_VOICE="Jamie (Premium)"
    SAY_RATE=175
    PREFIX=""
    ;;
esac

# Build spoken text (skip if already set by IS_QUESTION path)
if [ "$IS_QUESTION" != true ]; then
    SHORT=$(echo "$MESSAGE" | cut -c1-120)
    SPOKEN=$(printf '%s\n' "$GREETING" "$PREFIX" "$SHORT" | sed '/^$/d')
fi

# TTS priority: piper (neural) > Swift binary (Siri voices) > say (basic)
PIPER_ONNX="$PIPER_DIR/${PIPER_MODEL}.onnx"
if mise exec pipx:piper-tts -- which piper &>/dev/null && [ -f "$PIPER_ONNX" ]; then
    echo "$SPOKEN" | mise exec pipx:piper-tts -- piper \
        --model "$PIPER_ONNX" \
        --length-scale "$PIPER_LENGTH" \
        --noise-scale "$PIPER_NOISE" \
        --noise-w-scale "$PIPER_NOISEW" \
        --sentence-silence "$PIPER_SILENCE" \
        --output_file /tmp/claude-speak.wav 2>/dev/null && afplay /tmp/claude-speak.wav &
elif [ -x ~/.claude/hooks/speak ]; then
    VOICE_ARG=""
    [ -n "$VOICE" ] && VOICE_ARG="-v $VOICE"
    ~/.claude/hooks/speak $VOICE_ARG -r "$RATE" "$SPOKEN" &
else
    say -v "$SAY_VOICE" -r "$SAY_RATE" "$SPOKEN" &
fi
