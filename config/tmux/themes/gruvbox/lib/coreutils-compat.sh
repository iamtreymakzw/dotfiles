#!/usr/bin/env zsh

# Compatibility functions for macOS
if [[ "$(uname)" == "Darwin" ]]; then
  HOMEBREW_PREFIX="$(brew --prefix 2>/dev/null)"
  if [[ -n "$HOMEBREW_PREFIX" ]]; then
    # Use GNU coreutils if available
    if [[ -d "$HOMEBREW_PREFIX/opt/coreutils" ]]; then
      export PATH="$HOMEBREW_PREFIX/opt/coreutils/libexec/gnubin:$PATH"
    fi
    # Use GNU awk if available
    if [[ -d "$HOMEBREW_PREFIX/opt/gawk" ]]; then
      export PATH="$HOMEBREW_PREFIX/opt/gawk/libexec/gnubin:$PATH"
    fi
    # Use GNU sed if available
    if [[ -d "$HOMEBREW_PREFIX/opt/gsed" ]]; then
      export PATH="$HOMEBREW_PREFIX/opt/gsed/libexec/gnubin:$PATH"
    fi
    # Use Homebrew bc if available
    if [[ -d "$HOMEBREW_PREFIX/opt/bc" ]]; then
      export PATH="$HOMEBREW_PREFIX/opt/bc/bin:$PATH"
    fi
  fi
fi
