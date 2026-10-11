#!/usr/bin/env zsh

# Git block for the bar. Prints "<bg>\t<fg>\t<text>", or nothing outside a repo.
#   git-status.sh <path> <max-branch-chars>

CURRENT_DIR="${0:A:h}"
source "$CURRENT_DIR/../lib/coreutils-compat.sh"
source "$CURRENT_DIR/themes.sh"

cd "$1" 2>/dev/null || exit 0
MAX_BRANCH=${2:-200}
FETCH_INTERVAL=300
MIN_BRANCH=12

git --no-optional-locks rev-parse --git-dir >/dev/null 2>&1 || exit 0

# Keep ahead/behind honest without blocking the bar
FETCH_HEAD="$(git rev-parse --git-common-dir 2>/dev/null)/FETCH_HEAD"
if [[ -f "$FETCH_HEAD" ]]; then
  LAST_FETCH=$(stat -f %m "$FETCH_HEAD" 2>/dev/null || stat -c %Y "$FETCH_HEAD" 2>/dev/null || echo 0)
  if (( $(date +%s) - LAST_FETCH > FETCH_INTERVAL )); then
    touch "$FETCH_HEAD"
    git fetch --quiet origin >/dev/null 2>&1 &!
  fi
fi

STATUS="$(git --no-optional-locks status --porcelain=v2 --branch 2>/dev/null)"
BRANCH=$(print -r -- "$STATUS" | awk '/^# branch.head/{print $3}')
[[ "$BRANCH" == "(detached)" ]] && BRANCH=$(git rev-parse --short HEAD 2>/dev/null)
[[ -z "$BRANCH" ]] && exit 0

read -r AHEAD BEHIND < <(print -r -- "$STATUS" | awk '/^# branch.ab/{gsub(/[+-]/,""); print $3, $4}')
AHEAD=${AHEAD:-0}; BEHIND=${BEHIND:-0}
STAGED=$(print -r -- "$STATUS" | awk '/^[12] /{ if (substr($2,1,1)!=".") c++ } END{print c+0}')
MODIFIED=$(print -r -- "$STATUS" | awk '/^[12] /{ if (substr($2,2,1)!=".") c++ } END{print c+0}')
UNTRACKED=$(print -r -- "$STATUS" | grep -c '^? ')
CONFLICTS=$(print -r -- "$STATUS" | grep -c '^u ')

# Only shorten the branch when the terminal is too narrow to hold it
(( MAX_BRANCH < MIN_BRANCH )) && MAX_BRANCH=$MIN_BRANCH
(( ${#BRANCH} > MAX_BRANCH )) && BRANCH="${BRANCH[1,MAX_BRANCH-1]}…"

ICON_BRANCH=$'\ue0a0'
TEXT="${ICON_BRANCH} ${BRANCH}"
(( AHEAD > 0 ))     && TEXT+=" ↑${AHEAD}"
(( BEHIND > 0 ))    && TEXT+=" ↓${BEHIND}"
(( STAGED > 0 ))    && TEXT+=" +${STAGED}"
(( MODIFIED > 0 ))  && TEXT+=" ~${MODIFIED}"
(( UNTRACKED > 0 )) && TEXT+=" ?${UNTRACKED}"
(( CONFLICTS > 0 )) && TEXT+=" !${CONFLICTS}"

# Same meaning as the Claude Code row: green clean, orange dirty, red conflicted
BG=${THEME[green]}
(( STAGED + MODIFIED + UNTRACKED > 0 )) && BG=${THEME[orange]}
(( CONFLICTS > 0 )) && BG=${THEME[red]}

print -r -- "${BG}"$'\t'"${THEME[bg0]}"$'\t'"${TEXT}"
