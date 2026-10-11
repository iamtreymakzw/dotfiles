#!/bin/zsh

# The accent block turns orange and names the mode while AeroSpace is in anything but its main mode,
# the same signal the tmux session block gives while the prefix is held.

export PATH="/usr/local/bin:/opt/homebrew/bin:$PATH"
source "$CONFIG_DIR/colors.sh"

mode="$(aerospace list-modes --current 2>/dev/null)"

if [[ -z "$mode" || "$mode" == "main" ]]; then
  sketchybar --set mode background.color=$YELLOW label.drawing=off \
             --set mode.cap icon.color=$YELLOW
else
  sketchybar --set mode background.color=$ORANGE label="${mode:u}" label.drawing=on \
             --set mode.cap icon.color=$ORANGE
fi
