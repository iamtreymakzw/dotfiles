#!/bin/zsh

source "$CONFIG_DIR/icons.sh"

[[ "$SENDER" == "front_app_switched" ]] || exit 0
sketchybar --set "$NAME" icon="$(icon_for "$INFO")" label="$INFO"
