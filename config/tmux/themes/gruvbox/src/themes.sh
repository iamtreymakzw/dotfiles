#!/usr/bin/env zsh

# Gruvbox, hard contrast. Same hex values as ~/.claude/statusline-command.sh and nvim's lualine theme.
SELECTED_THEME="$(tmux show-option -gv @gruvbox-tmux_theme 2>/dev/null)"

typeset -A THEME

case $SELECTED_THEME in
"light")
  THEME=(
    [bg0]="#f9f5d7" [bg1]="#ebdbb2" [bg2]="#d5c4a1" [bg3]="#bdae93"
    [gray]="#928374" [muted]="#7c6f64" [fg]="#3c3836" [fg0]="#282828"
    [on_accent]="#f9f5d7" [on_bright]="#f9f5d7"
    [red]="#cc241d" [green]="#98971a" [yellow]="#d79921" [blue]="#458588"
    [purple]="#b16286" [aqua]="#689d6a" [orange]="#d65d0e"
    [bred]="#9d0006" [bgreen]="#79740e" [byellow]="#b57614" [bblue]="#076678"
    [bpurple]="#8f3f71" [baqua]="#427b58" [borange]="#af3a03"
  )
  ;;
*)
  THEME=(
    [bg0]="#1d2021" [bg1]="#3c3836" [bg2]="#504945" [bg3]="#665c54"
    [gray]="#928374" [muted]="#a89984" [fg]="#ebdbb2" [fg0]="#fbf1c7"
    [on_accent]="#fbf1c7" [on_bright]="#1d2021"
    [red]="#cc241d" [green]="#98971a" [yellow]="#d79921" [blue]="#458588"
    [purple]="#b16286" [aqua]="#689d6a" [orange]="#d65d0e"
    [bred]="#fb4934" [bgreen]="#b8bb26" [byellow]="#fabd2f" [bblue]="#83a598"
    [bpurple]="#d3869b" [baqua]="#8ec07c" [borange]="#fe8019"
  )
  ;;
esac

# Powerline caps, as used by the Claude Code status row
SEP=$'\ue0b0'
SEP_L=$'\ue0b2'

RESET="#[fg=${THEME[fg]},bg=${THEME[bg0]},nobold,noitalics,nounderscore,nodim]"
