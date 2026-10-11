#!/bin/zsh

[[ "$SENDER" == "volume_change" ]] && volume="$INFO" || volume="$(osascript -e 'output volume of (get volume settings)')"

if (( volume == 0 )); then icon=$'\U000f075f'
elif (( volume < 50 )); then icon=$''
else icon=$''
fi

sketchybar --set "$NAME" icon="$icon" label="${volume}%"
