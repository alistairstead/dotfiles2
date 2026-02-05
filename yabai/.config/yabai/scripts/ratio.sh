#!/bin/bash
YABAI=/opt/homebrew/bin/yabai

if [[ "$1" == "reset" ]]; then
    $YABAI -m window --ratio abs:0.5
    exit 0
fi

# Get focused window's display width
WIDTH=$($YABAI -m query --displays --display | jq '.frame.w')

if (($(echo "$WIDTH > 1600" | bc -l))); then
    $YABAI -m window --ratio abs:0.68
else
    $YABAI -m window --ratio abs:0.6
fi
