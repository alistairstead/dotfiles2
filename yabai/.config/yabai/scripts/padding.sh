#!/bin/bash
YABAI=/opt/homebrew/bin/yabai

# Get focused display width
WIDTH=$($YABAI -m query --displays --display | jq '.frame.w')

if (($(echo "$WIDTH > 1600" | bc -l))); then
    PADDING=10
    GAP=10
else
    PADDING=5
    GAP=5
fi

$YABAI -m config top_padding $PADDING
$YABAI -m config bottom_padding $PADDING
$YABAI -m config left_padding $PADDING
$YABAI -m config right_padding $PADDING
$YABAI -m config window_gap $GAP
