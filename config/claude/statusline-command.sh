#!/bin/bash
# Claude Code status line: single powerline row, gruvbox dark hard palette.
#   model | dir | branch +ahead -behind staged/modified/untracked | repo link | ctx bar | session | cost | rate limits
# Set STATUSLINE_ASCII=1 to drop Nerd Font glyphs.

input=$(cat)
# Width: the narrower of Claude Code's COLUMNS and the live tmux pane (COLUMNS lags a pane resize), else a safe default.
cols=${COLUMNS:-0}
[ "$cols" -gt 0 ] 2>/dev/null || cols=0
pane_cols=""
[ -n "$TMUX_PANE" ] && pane_cols=$(tmux display -p -t "$TMUX_PANE" '#{pane_width}' 2>/dev/null)
if [ "${pane_cols:-0}" -gt 0 ] 2>/dev/null && { [ "$cols" -eq 0 ] || [ "$pane_cols" -lt "$cols" ]; }; then cols=$pane_cols; fi
[ "$cols" -gt 0 ] || cols=120

# ---------- gruvbox dark hard, as <hex>:<256-colour fallback> ----------
# Same hex values as ~/.config/tmux/themes/gruvbox/src/themes.sh and nvim's lualine theme.
G_BG0=1d2021:235; G_BG1=3c3836:237; G_BG2=504945:239; G_BG3=665c54:241; G_FG=ebdbb2:223; G_FG0=fbf1c7:229; G_GRAY=928374:245
G_RED=cc241d:124; G_RED_B=fb4934:167; G_GREEN=98971a:106; G_GREEN_B=b8bb26:142; G_YELLOW=d79921:172; G_YELLOW_B=fabd2f:214
G_BLUE=458588:66; G_BLUE_B=83a598:109; G_PURPLE=b16286:132; G_PURPLE_B=d3869b:175; G_AQUA=689d6a:72; G_AQUA_B=8ec07c:108
G_ORANGE=d65d0e:166; G_ORANGE_B=fe8019:208

# Under tmux Claude Code squashes 24-bit colour to 256 unless CLAUDE_CODE_TMUX_TRUECOLOR is set,
# so hand it the hand-picked 256 values there rather than let it guess.
TRUECOLOR=0
case "${COLORTERM:-}" in truecolor|24bit) TRUECOLOR=1 ;; esac
[ -n "$TMUX" ] && [ -z "$CLAUDE_CODE_TMUX_TRUECOLOR" ] && TRUECOLOR=0
[ -n "$STATUSLINE_TRUECOLOR" ] && TRUECOLOR=$STATUSLINE_TRUECOLOR

# ---------- helpers ----------
jqr() { printf '%s' "$input" | jq -r "$1"; }

if [ -n "$STATUSLINE_ASCII" ]; then
  SEP=""; SEP_L=""; I_MODEL="AI"; I_DIR=""; I_BRANCH="br"; I_GH="gh"; I_GL="gl"; I_BB="bb"; I_GIT="git"
  I_TREE="wt"; I_AGENT="agent"; I_CTX="ctx"; I_SESS="sess"; I_COST="$"; I_LIMIT="lim"
  BATT=("[    ]" "[=   ]" "[==  ]" "[=== ]" "[====]")
else
  SEP=$''; SEP_L=$''; I_MODEL=$''; I_DIR=$''; I_BRANCH=$''; I_GH=$''; I_GL=$''
  I_BB=$''; I_GIT=$''; I_TREE=$''; I_AGENT=$''; I_CTX=$''; I_SESS=$''
  I_COST=$''; I_LIMIT=$''
  # nf-md battery glyphs, empty -> full (remaining charge)
  BATT=(󰂎 󰁺 󰁻 󰁼 󰁽 󰁾
        󰁿 󰂀 󰂁 󰂂 󰁹)
fi

RESET=$'\033[0m'
# paint <38|48> <hex:idx>
paint() {
  local hex=${2%%:*}
  if [ "$TRUECOLOR" = 1 ]; then printf '\033[%s;2;%d;%d;%dm' "$1" "0x${hex:0:2}" "0x${hex:2:2}" "0x${hex:4:2}"
  else printf '\033[%s;5;%sm' "$1" "${2##*:}"; fi
}
fg() { paint 38 "$1"; }
bg() { paint 48 "$1"; }

line=""; prev_bg=""
seg() {
  local b=$1 f=$2 t=$3
  [ -z "$t" ] && return
  [ -n "$prev_bg" ] && line+="$(bg "$b")$(fg "$prev_bg")${SEP}"
  line+="$(bg "$b")$(fg "$f") ${t} "
  prev_bg=$b
}
flush() {
  [ -z "$prev_bg" ] && return
  printf '%s%s%s%s' "$line" "$RESET" "$(fg "$prev_bg")${SEP}" "$RESET"
}
# Right-aligned group: seg_r <bg> <fg> <text>, caps point left.
rline=""; rprev_bg=""
seg_r() {
  local b=$1 f=$2 t=$3
  [ -z "$t" ] && return
  if [ -z "$rprev_bg" ]; then rline+="${RESET}$(fg "$b")${SEP_L}"; else rline+="$(bg "$rprev_bg")$(fg "$b")${SEP_L}"; fi
  rline+="$(bg "$b")$(fg "$f") ${t} "
  rprev_bg=$b
}
flush_r() { [ -n "$rprev_bg" ] && printf '%s%s' "$rline" "$RESET"; }
# vis <string>: printable width, ignoring SGR colours and OSC 8 links
vis() { printf '%s' "$1" | perl -CS -pe 's/\e\[[0-9;]*m//g; s/\e\]8;;[^\e]*\e\\//g' | perl -CS -ne '$n+=length; END{print $n+0}'; }
link() { printf '\033]8;;%s\033\\%s\033]8;;\033\\' "$1" "$2"; }

# ellipsize <string> <max>: shorten only when it cannot fit, and say so with an ellipsis
ellipsize() {
  local s=$1 max=$2
  [ "$max" -lt 2 ] && max=2
  if [ "${#s}" -gt "$max" ]; then printf '%s…' "${s:0:$((max - 1))}"; else printf '%s' "$s"; fi
}

fmt_k() { awk -v n="$1" 'BEGIN{ if (n>=1000) printf "%.0fk", n/1000; else printf "%d", n }'; }
fmt_reset() { date -r "$1" '+%H:%M' 2>/dev/null; }

# ---------- input ----------
model=$(jqr '.model.display_name // empty')
dir=$(jqr '.workspace.current_dir // .cwd // empty')
session_id=$(jqr '.session_id // empty')
session_name=$(jqr '.session_name // empty')
worktree=$(jqr '.worktree.name // empty')
agent=$(jqr '.agent.name // empty')
used=$(jqr '.context_window.used_percentage // empty')
ctx_size=$(jqr '.context_window.context_window_size // empty')
cost=$(jqr '.cost.total_cost_usd // empty')
added=$(jqr '.cost.total_lines_added // empty')
removed=$(jqr '.cost.total_lines_removed // empty')
five_pct=$(jqr '.rate_limits.five_hour.used_percentage // empty')
five_reset=$(jqr '.rate_limits.five_hour.resets_at // empty')
week_pct=$(jqr '.rate_limits.seven_day.used_percentage // empty')

# ---------- git ----------
branch=""; ahead=0; behind=0; staged=0; modified=0; untracked=0; conflicts=0
repo_label=""; repo_url=""; branch_url=""; host_icon=$I_GIT
read_git() {
  local status
  git -C "$dir" --no-optional-locks rev-parse --git-dir >/dev/null 2>&1 || return
  status=$(git -C "$dir" --no-optional-locks status --porcelain=v2 --branch 2>/dev/null)
  branch=$(printf '%s\n' "$status" | awk '/^# branch.head/{print $3}')
  [ "$branch" = "(detached)" ] && branch=$(git -C "$dir" rev-parse --short HEAD 2>/dev/null)
  read -r ahead behind < <(printf '%s\n' "$status" | awk '/^# branch.ab/{gsub(/[+-]/,""); print $3, $4}')
  ahead=${ahead:-0}; behind=${behind:-0}
  staged=$(printf '%s\n' "$status" | awk '/^[12] /{ if (substr($2,1,1)!=".") c++ } END{print c+0}')
  modified=$(printf '%s\n' "$status" | awk '/^[12] /{ if (substr($2,2,1)!=".") c++ } END{print c+0}')
  untracked=$(printf '%s\n' "$status" | grep -c '^? ')
  conflicts=$(printf '%s\n' "$status" | grep -c '^u ')
  return 0
}
read_remote() {
  local url host path
  url=$(git -C "$dir" remote get-url origin 2>/dev/null) || return
  [ -z "$url" ] && return
  url=${url%.git}
  case "$url" in
    git@*:*)   host=${url#git@}; path=${host#*:}; host=${host%%:*} ;;
    ssh://*)   host=${url#ssh://}; host=${host#*@}; path=${host#*/}; host=${host%%/*} ;;
    http*://*) host=${url#*://}; host=${host#*@}; path=${host#*/}; host=${host%%/*} ;;
    *) return ;;
  esac
  repo_url="https://${host}/${path}"
  repo_label=${path##*/}
  case "$host" in
    *github*)    host_icon=$I_GH; branch_url="${repo_url}/tree/${branch}" ;;
    *gitlab*)    host_icon=$I_GL; branch_url="${repo_url}/-/tree/${branch}" ;;
    *bitbucket*) host_icon=$I_BB; branch_url="${repo_url}/branch/${branch}" ;;
    *)           branch_url=$repo_url ;;
  esac
}
[ -n "$dir" ] && read_git && [ -n "$branch" ] && read_remote

git_text=""
if [ -n "$branch" ]; then
  git_text="${I_BRANCH} ${branch}"
  [ "$ahead" -gt 0 ]     && git_text+=" ↑${ahead}"
  [ "$behind" -gt 0 ]    && git_text+=" ↓${behind}"
  [ "$staged" -gt 0 ]    && git_text+=" +${staged}"
  [ "$modified" -gt 0 ]  && git_text+=" ~${modified}"
  [ "$untracked" -gt 0 ] && git_text+=" ?${untracked}"
  [ "$conflicts" -gt 0 ] && git_text+=" !${conflicts}"
fi
git_bg=$G_GREEN
[ "$((staged + modified + untracked))" -gt 0 ] && git_bg=$G_ORANGE
[ "$conflicts" -gt 0 ] && git_bg=$G_RED

# ---------- meters ----------
# level_color <pct>: green under WARN, yellow under CRIT, red above
WARN=60; CRIT=85
level_color() {
  local p=$1
  if [ "$p" -ge "$CRIT" ]; then printf '%s' "$G_RED_B"
  elif [ "$p" -ge "$WARN" ]; then printf '%s' "$G_YELLOW_B"
  else printf '%s' "$G_GREEN_B"; fi
}
# battery <used_pct> <text_fg>: one glyph that fills with usage, coloured by level
battery() {
  local used=$1 txt=$2 idx n
  [ "$used" -gt 100 ] && used=100
  n=${#BATT[@]}
  idx=$(( used * (n - 1) / 100 ))
  printf '%s%s%s' "$(fg "$(level_color "$used")")" "${BATT[$idx]}" "$(fg "$txt")"
}

# ---------- detail tiers ----------
# level 4: everything   3: session name shortened   2: no token counts / reset time / session name
#       1: no repo link, session   0: no worktree, agent, git counts
build_ctx() {
  local level=$1 pct
  ctx_text=""
  [ -z "$used" ] && return
  pct=$(printf '%.0f' "$used")
  ctx_text="$(battery "$pct" "$G_FG") ${pct}%"
  [ -n "$ctx_size" ] && [ "$level" -ge 3 ] && \
    ctx_text+=" $(fmt_k "$(awk -v p="$used" -v s="$ctx_size" 'BEGIN{printf "%d", p*s/100}')")/$(fmt_k "$ctx_size")"
}
build_sess() {
  local level=$1
  sess_text=""
  [ "$level" -lt 2 ] && return
  if [ -n "$session_name" ] && [ "$level" -ge 4 ]; then sess_text="${I_SESS} ${session_name}"
  elif [ -n "$session_name" ] && [ "$level" -ge 3 ]; then sess_text="${I_SESS} $(ellipsize "$session_name" 24)"
  elif [ -n "$session_id" ]; then sess_text="${I_SESS} ${session_id:0:8}"
  fi
}
build_limits() {
  local level=$1
  limit_text=""
  if [ -n "$five_i" ]; then
    limit_text="$(battery "$five_i" "$G_FG0") 5h ${five_i}%"
    [ -n "$five_reset" ] && [ "$level" -ge 3 ] && limit_text+=" ⟳$(fmt_reset "$five_reset")"
  fi
  if [ -n "$week_i" ]; then
    [ -n "$limit_text" ] && limit_text+="  "
    limit_text+="$(battery "$week_i" "$G_FG0") 7d ${week_i}%"
  fi
}
build_row() {
  local level=$1
  line=""; prev_bg=""; rline=""; rprev_bg=""
  build_ctx "$level"; build_sess "$level"; build_limits "$level"
  seg "$G_PURPLE" "$G_FG0" "${I_MODEL} ${model}"
  [ -z "$hide_dir" ] && seg "$G_BLUE"   "$G_FG0" "${I_DIR} $(basename "${dir:-?}")"
  if [ "$level" -ge 1 ]; then seg "$git_bg" "$G_BG0" "$git_text"; else seg "$git_bg" "$G_BG0" "${branch:+${I_BRANCH} ${short_branch:-$branch}}"; fi
  [ -n "$repo_label" ] && [ "$level" -ge 2 ] && seg "$G_BG1" "$G_FG" "${host_icon} $(link "$branch_url" "$repo_label")"
  [ -n "$worktree" ] && [ "$level" -ge 1 ] && seg "$G_AQUA"     "$G_BG0" "${I_TREE} ${worktree}"
  [ -n "$agent" ]    && [ "$level" -ge 1 ] && seg "$G_PURPLE_B" "$G_BG0" "${I_AGENT} ${agent}"
  seg "$ctx_bg" "$G_FG" "$ctx_text"
  seg "$G_BG3"  "$G_FG" "$sess_text"
  left=$(flush)
  [ -z "$hide_limits" ] && seg_r "$limit_bg" "$G_FG0" "$limit_text"
  seg_r "$G_RED_B"  "$G_BG0" "$cost_text"
  right=$(flush_r)
}

# ---------- shared inputs for the tiers ----------
ctx_bg=$G_BG2
five_i=""; week_i=""; over_limit=0
[ -n "$five_pct" ] && five_i=$(printf '%.0f' "$five_pct")
[ -n "$week_pct" ] && week_i=$(printf '%.0f' "$week_pct")
{ [ -n "$five_i" ] && [ "$five_i" -ge 100 ]; } || { [ -n "$week_i" ] && [ "$week_i" -ge 100 ]; } && over_limit=1
limit_bg=$G_BG1; [ "$over_limit" -eq 1 ] && limit_bg=$G_RED
# Cost is API-equivalent spend. Only relevant once plan limits are exhausted (overage).
cost_text=""
[ -n "$cost" ] && [ "$over_limit" -eq 1 ] && cost_text="${I_COST}$(printf '%.2f' "$cost")"

# ---------- fit and print ----------
# Claude Code adds its own spacing around the row; STATUSLINE_MARGIN widens the reserve if the right edge clips.
MARGIN=${STATUSLINE_MARGIN:-4}
short_branch=""; hide_dir=""; hide_limits=""
fit() { build_row "$1"; gap=$(( cols - $(vis "$left") - $(vis "$right") - MARGIN )); }
for level in 4 3 2 1 0; do
  fit "$level"
  [ "$gap" -ge 1 ] && break
done
# Narrow panes (Claude docked beside the editor): give up the folder, then the plan limits,
# then shorten the branch, rather than let the row clip.
if [ "$gap" -lt 1 ]; then hide_dir=1; fit 0; fi
if [ "$gap" -lt 1 ]; then hide_dir=""; hide_limits=1; fit 0; fi
if [ "$gap" -lt 1 ]; then hide_dir=1; fit 0; fi
if [ "$gap" -lt 1 ] && [ -n "$branch" ]; then
  short_branch=$(ellipsize "$branch" $(( ${#branch} + gap - 1 )))
  fit 0
fi
[ "$gap" -lt 1 ] && gap=1
if [ -n "$right" ]; then
  printf '%s%*s%s\n' "$left" "$gap" "" "$right"
else
  printf '%s\n' "$left"
fi
