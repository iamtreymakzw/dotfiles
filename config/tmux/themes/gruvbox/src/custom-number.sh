#!/usr/bin/env zsh

# Imports
ROOT_DIR="${0:A:h}/.."
. "${ROOT_DIR}/lib/coreutils-compat.sh"

format_none="0123456789"
format_digital="🯰🯱🯲🯳🯴🯵🯶🯷🯸🯹"
format_fsquare="󰎡󰎤󰎧󰎪󰎭󰎱󰎳󰎶󰎹󰎼"
format_hsquare="󰎣󰎦󰎩󰎬󰎮󰎰󰎵󰎸󰎻󰎾"
format_dsquare="󰎢󰎥󰎨󰎫󰎲󰎯󰎴󰎷󰎺󰎽"
format_roman=" 󱂈󱂉󱂊󱂋󱂌󱂍󱂎󱂏󱂐"
format_super="⁰¹²³⁴⁵⁶⁷⁸⁹"
format_sub="₀₁₂₃₄₅₆₇₈₉"

ID=$1
FORMAT=${2:-none}

# Get the format string
format="${(P)$(echo format_${FORMAT})}"
if [[ -z "$format" ]]; then
  echo "Invalid format: $FORMAT"
  exit 1
fi

# If format is roman numerals, only handle IDs of 1 digit
if [[ "$FORMAT" = "roman" ]] && [[ ${#ID} -gt 1 ]]; then
  echo -n "$ID"
else
  for (( i = 1; i <= ${#ID}; i++ )); do
    DIGIT=${ID:$((i-1)):1}
    echo -n "${format:$DIGIT:1}"
  done
fi
