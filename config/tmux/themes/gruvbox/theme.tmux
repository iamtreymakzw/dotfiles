#!/usr/bin/env zsh

# Powerline status bar in the same grammar as the Claude Code status row:
# accent block, quiet blocks, empty middle, right-aligned blocks.

CURRENT_DIR="${0:A:h}"

source "$CURRENT_DIR/lib/coreutils-compat.sh"

SCRIPTS_PATH="$CURRENT_DIR/src"

source $SCRIPTS_PATH/themes.sh

tmux set -g status-left-length 150
tmux set -g status-right-length 250

#+--- Chrome outside the bar ---+
tmux set -g mode-style "fg=${THEME[fg0]},bg=${THEME[bg2]}"
tmux set -g copy-mode-match-style "fg=${THEME[on_bright]},bg=${THEME[yellow]}"
tmux set -g copy-mode-current-match-style "fg=${THEME[on_bright]},bg=${THEME[borange]}"

tmux set -g message-style "fg=${THEME[on_bright]},bg=${THEME[yellow]}"
tmux set -g message-command-style "fg=${THEME[fg]},bg=${THEME[bg1]}"

tmux set -g pane-border-style "fg=${THEME[bg1]}"
tmux set -g pane-active-border-style "fg=${THEME[gray]}"
tmux set -g pane-border-status off

tmux set -g popup-style "fg=${THEME[fg]},bg=${THEME[bg0]}"
tmux set -g popup-border-style "fg=${THEME[gray]}"
tmux set -g popup-border-lines rounded
tmux set -g menu-style "fg=${THEME[fg]},bg=${THEME[bg0]}"
tmux set -g menu-selected-style "fg=${THEME[on_accent]},bg=${THEME[blue]}"
tmux set -g menu-border-style "fg=${THEME[gray]}"
tmux set -g clock-mode-colour "${THEME[yellow]}"

tmux set -g status-style "fg=${THEME[fg]},bg=${THEME[bg0]}"

TMUX_VARS="$(tmux show -g)"

default_window_id_style="none"
default_pane_id_style="super"
default_github_status="on"
default_session_bg="on"
default_window_center="off"

window_id_style="$(echo "$TMUX_VARS" | grep '@gruvbox-tmux_window_id_style' | cut -d" " -f2)"
pane_id_style="$(echo "$TMUX_VARS" | grep '@gruvbox-tmux_pane_id_style' | cut -d" " -f2)"
github_status_enabled="$(echo "$TMUX_VARS" | grep '@gruvbox-tmux_github_status' | cut -d" " -f2)"
session_bg_enabled="$(echo "$TMUX_VARS" | grep '@gruvbox-tmux_session_bg' | cut -d" " -f2)"
window_center_enabled="$(echo "$TMUX_VARS" | grep '@gruvbox-tmux_window_center' | cut -d" " -f2)"
window_id_style="${window_id_style:-$default_window_id_style}"
pane_id_style="${pane_id_style:-$default_pane_id_style}"
github_status_enabled="${github_status_enabled:-$default_github_status}"
session_bg_enabled="${session_bg_enabled:-$default_session_bg}"
window_center_enabled="${window_center_enabled:-$default_window_center}"

# Plain digits by default: the segmented "digital" style is not in most fonts, JetBrains Mono included
if [[ "$window_id_style" == "none" ]]; then
    window_number="#I"
else
    window_number="#($SCRIPTS_PATH/custom-number.sh #I $window_id_style)"
fi
custom_pane="#($SCRIPTS_PATH/custom-number.sh #P $pane_id_style)"

ICON_PREFIX=$'\U000f0820'
ICON_IDLE=$'\U000f0902'
ICON_ZOOM=$'\U000f0293'
ICON_LAST=$'\U000f006f'
ICON_EDIT=$'\ue7c5'
ICON_CLAUDE=$'\U000f06a9'
ICON_SHELL=$'\uf120'

#+--- Bars LEFT ---+
# Session block; turns orange while the prefix is held
if [[ "$session_bg_enabled" == "on" ]]; then
    session_bg="#{?client_prefix,#[bg=${THEME[borange]}],#[bg=${THEME[yellow]}]}"
    session_cap="#{?client_prefix,#[fg=${THEME[borange]}],#[fg=${THEME[yellow]}]}"
    tmux set -g status-left "#[fg=${THEME[on_bright]},bold]${session_bg} #{?client_prefix,${ICON_PREFIX},${ICON_IDLE}} #S #[bg=${THEME[bg1]},nobold]${session_cap}${SEP}"
else
    tmux set -g status-left "#[fg=${THEME[fg]},bg=${THEME[bg1]},bold] #{?client_prefix,${ICON_PREFIX},${ICON_IDLE}} #S "
fi

#+--- Windows ---+
# A bg1 ribbon; the focused window is a blue block. Pane number only shows when the window is split.
# The icon follows the window's name: editor, Claude, or a terminal for anything else.
window_icon="#{?#{==:#W,edit},${ICON_EDIT},#{?#{==:#W,claude},${ICON_CLAUDE},${ICON_SHELL}}}"
window_flags="#{?window_zoomed_flag, ${ICON_ZOOM},#{?#{e|>:#{window_panes},1}, $custom_pane,}}#{?window_last_flag, ${ICON_LAST},}"
ribbon_end="#{?window_end_flag,#[fg=${THEME[bg1]} bg=${THEME[bg0]}]${SEP},}"

tmux set -g window-status-current-format "#[fg=${THEME[bg1]},bg=${THEME[blue]}]${SEP}#[fg=${THEME[on_accent]},bold] ${window_icon} $window_number #W#[nobold]${window_flags} #[fg=${THEME[blue]},bg=${THEME[bg1]}]${SEP}${ribbon_end}"
tmux set -g window-status-format "#[fg=${THEME[bg1]},bg=${THEME[bg1]}]${SEP}#[fg=${THEME[muted]}] ${window_icon} $window_number #W${window_flags} #[fg=${THEME[bg1]}]${SEP}${ribbon_end}"
tmux set -g window-status-separator ""
tmux set -g window-status-activity-style "fg=${THEME[byellow]}"
tmux set -g window-status-bell-style "fg=${THEME[bred]}"

#+--- Bars RIGHT ---+
# Session and window names, so the branch only shortens when the bar truly runs out of room
left_chars="#{n:session_name} #{n:#{W:#W}} #{session_windows}"
tmux set -g status-right "#($SCRIPTS_PATH/status-right.sh #{q:pane_current_path} #{client_width} ${github_status_enabled} ${left_chars})"

#+--- Window Position ---+
if [[ "$window_center_enabled" == "on" ]]; then
    tmux set -g status-justify centre
else
    tmux set -g status-justify left
fi
