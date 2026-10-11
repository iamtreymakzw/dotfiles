#!/usr/bin/env zsh

# Right side of the bar: GitHub counts, then a git block that reads like the Claude Code one.
#   status-right.sh <path> <client-width> <github on|off> <session-chars> <window-name-chars> <windows>

CURRENT_DIR="${0:A:h}"
source "$CURRENT_DIR/../lib/coreutils-compat.sh"
source "$CURRENT_DIR/themes.sh"

cd "$1" 2>/dev/null || exit 0
WIDTH=${2:-200}
GITHUB=${3:-on}

# Columns the session block and window ribbon take, plus the git block's own icon and counters
SESSION_CHROME=6
WINDOW_CHROME=10
GIT_CHROME=12
BRANCH_BUDGET=$(( WIDTH - ${4:-10} - SESSION_CHROME - ${5:-20} - ${6:-3} * WINDOW_CHROME - GIT_CHROME ))

OUT=""
PREV_BG=${THEME[bg0]}
block() {
  local bg=$1 fg=$2 text=$3
  [[ -z "$text" ]] && return
  OUT+="#[fg=${bg},bg=${PREV_BG}]${SEP_L}#[fg=${fg},bg=${bg}] ${text} "
  PREV_BG=$bg
}

[[ "$GITHUB" == "on" ]] && block "${THEME[bg1]}" "${THEME[fg]}" "$("$CURRENT_DIR/github-status.sh" "$PWD")"

block "${THEME[bg2]}" "${THEME[fg]}" "$("$CURRENT_DIR/path-widget.sh" "$PWD")"
"$CURRENT_DIR/git-status.sh" "$PWD" "$BRANCH_BUDGET" | IFS=$'\t' read -r git_bg git_fg git_text
block "$git_bg" "$git_fg" "$git_text"

print -rn -- "$OUT"
