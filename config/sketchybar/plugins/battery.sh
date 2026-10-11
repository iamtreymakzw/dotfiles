#!/bin/zsh

source "$CONFIG_DIR/colors.sh"
source "$CONFIG_DIR/icons.sh"

LOW=20
power="$(pmset -g batt)"
percent="$(print -r -- "$power" | grep -Eo '[0-9]+%' | head -1 | tr -d '%')"
[[ -n "$percent" ]] || exit 0

# Five steps from empty to full
levels=($'' $'' $'' $'' $'')
icon=${levels[$(( percent * 4 / 100 + 1 ))]}
color=$FG
(( percent <= LOW )) && color=$RED
if [[ "$power" == *"AC Power"* ]]; then
  icon=$ICON_BOLT
  color=$FG
fi

sketchybar --set "$NAME" icon="$icon" icon.color=$color label="${percent}%"
