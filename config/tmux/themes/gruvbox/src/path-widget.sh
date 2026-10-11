#!/usr/bin/env zsh

# Imports
ROOT_DIR="${0:A:h}/.."
. "${ROOT_DIR}/lib/coreutils-compat.sh"

# get value from tmux config
SHOW_PATH=$(tmux show-option -gv @gruvbox-tmux_show_path 2>/dev/null)
PATH_FORMAT=$(tmux show-option -gv @gruvbox-tmux_path_format 2>/dev/null) # full | relative

# check if not enabled
if [[ "${SHOW_PATH}" != "1" ]]; then
  exit 0
fi

current_path="${1}"
default_path_format="relative"
PATH_FORMAT="${PATH_FORMAT:-$default_path_format}"

# check user requested format
if [[ ${PATH_FORMAT} == "relative" ]]; then
  current_path="${current_path/#$HOME/~}"
fi

ICON_DIR=$'\uf07c'
print -rn -- "${ICON_DIR} ${current_path}"
