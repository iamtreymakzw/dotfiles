#!/bin/zsh

# Redraws the workspace ribbon: the focused workspace is a blue block, workspaces holding
# windows show their apps, empty ones are hidden.

export PATH="/usr/local/bin:/opt/homebrew/bin:$PATH"
source "$CONFIG_DIR/colors.sh"
source "$CONFIG_DIR/icons.sh"

focused="${FOCUSED_WORKSPACE:-$(aerospace list-workspaces --focused 2>/dev/null)}"

typeset -A apps
aerospace list-windows --all --format '%{workspace}|%{app-name}' 2>/dev/null | while IFS='|' read -r ws app; do
  glyph="$(icon_for "$app")"
  [[ "${apps[$ws]}" == *"$glyph"* ]] || apps[$ws]+="${apps[$ws]:+ }$glyph"
done

args=()
for ws in {1..9}; do
  if [[ "$ws" == "$focused" ]]; then
    args+=(--set space.$ws.l drawing=on icon.color=$BG1 background.color=$BLUE
           --set space.$ws drawing=on icon.color=$FG0 label.color=$FG0 background.color=$BLUE label="${apps[$ws]}"
           --set space.$ws.r drawing=on icon.color=$BLUE background.color=$BG1)
  elif [[ -n "${apps[$ws]}" ]]; then
    args+=(--set space.$ws.l drawing=on icon.color=$BG1 background.color=$BG1
           --set space.$ws drawing=on icon.color=$MUTED label.color=$MUTED background.color=$BG1 label="${apps[$ws]}"
           --set space.$ws.r drawing=on icon.color=$BG1 background.color=$BG1)
  else
    args+=(--set space.$ws.l drawing=off --set space.$ws drawing=off --set space.$ws.r drawing=off)
  fi
done

sketchybar "${args[@]}"
