#!/usr/bin/env bash
# Creates symlinks from dotfiles repo to their expected locations
set -euo pipefail

DOTFILES="$HOME/dotfiles"

info() { printf "\033[0;34m[info]\033[0m %s\n" "$1"; }
ok()   { printf "\033[0;32m[ok]\033[0m   %s\n" "$1"; }
warn() { printf "\033[0;33m[warn]\033[0m %s\n" "$1"; }

link_file() {
    local src="$1"
    local dest="$2"

    if [ -L "$dest" ]; then
        rm "$dest"
    elif [ -f "$dest" ] || [ -d "$dest" ]; then
        warn "Backing up existing $dest to ${dest}.bak"
        mv "$dest" "${dest}.bak"
    fi

    mkdir -p "$(dirname "$dest")"
    ln -s "$src" "$dest"
    ok "Linked $src -> $dest"
}

info "Setting up symlinks..."

# Shell
link_file "$DOTFILES/.zshrc"     "$HOME/.zshrc"
link_file "$DOTFILES/.zprofile"  "$HOME/.zprofile"
link_file "$DOTFILES/.czrc"      "$HOME/.czrc"

# Git
link_file "$DOTFILES/config/git/.gitconfig" "$HOME/.gitconfig"
link_file "$DOTFILES/config/git/ignore"     "$HOME/.config/git/ignore"

# Ghostty
link_file "$DOTFILES/config/ghostty/config" "$HOME/.config/ghostty/config"

# Neovim (link entire directory)
link_file "$DOTFILES/config/nvim" "$HOME/.config/nvim"

# Tmux
link_file "$DOTFILES/config/tmux/tmux.conf" "$HOME/.config/tmux/tmux.conf"

# Starship
link_file "$DOTFILES/config/starship/starship.toml" "$HOME/.config/starship.toml"

# Zed
link_file "$DOTFILES/config/zed/settings.json" "$HOME/.config/zed/settings.json"
link_file "$DOTFILES/config/zed/keymap.json"   "$HOME/.config/zed/keymap.json"

# VS Code
VSCODE_USER="$HOME/Library/Application Support/Code/User"
mkdir -p "$VSCODE_USER"
link_file "$DOTFILES/config/vscode/settings.json"    "$VSCODE_USER/settings.json"
link_file "$DOTFILES/config/vscode/keybindings.json"  "$VSCODE_USER/keybindings.json"

# Cursor
CURSOR_USER="$HOME/Library/Application Support/Cursor/User"
mkdir -p "$CURSOR_USER"
link_file "$DOTFILES/config/cursor/settings.json"    "$CURSOR_USER/settings.json"
link_file "$DOTFILES/config/cursor/keybindings.json"  "$CURSOR_USER/keybindings.json"

info "Symlinks complete!"
