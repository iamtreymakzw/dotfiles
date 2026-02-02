#!/usr/bin/env bash
# Bootstrap a fresh macOS machine from scratch
# Usage: git clone <your-dotfiles-repo> ~/dotfiles && cd ~/dotfiles && ./install.sh
set -euo pipefail

DOTFILES="$HOME/dotfiles"

info()    { printf "\n\033[0;34m[info]\033[0m %s\n" "$1"; }
ok()      { printf "\033[0;32m[ok]\033[0m   %s\n" "$1"; }
warn()    { printf "\033[0;33m[warn]\033[0m %s\n" "$1"; }
header()  { printf "\n\033[1;35m==> %s\033[0m\n" "$1"; }

# -------------------------------------------------------------------
# 1. Xcode Command Line Tools
# -------------------------------------------------------------------
header "Xcode Command Line Tools"
if xcode-select -p &>/dev/null; then
    ok "Already installed"
else
    info "Installing Xcode Command Line Tools..."
    xcode-select --install
    echo "Press any key after the installation completes..."
    read -n 1 -s
fi

# -------------------------------------------------------------------
# 2. Rosetta 2 (for Intel-only apps on Apple Silicon)
# -------------------------------------------------------------------
header "Rosetta 2"
if [[ "$(uname -m)" == "arm64" ]]; then
    if /usr/bin/pgrep oahd &>/dev/null; then
        ok "Already installed"
    else
        info "Installing Rosetta 2..."
        /usr/sbin/softwareupdate --install-rosetta --agree-to-license
    fi
else
    ok "Not needed (Intel Mac)"
fi

# -------------------------------------------------------------------
# 3. Homebrew
# -------------------------------------------------------------------
header "Homebrew"
if command -v brew &>/dev/null; then
    ok "Already installed"
    info "Updating Homebrew..."
    brew update
else
    info "Installing Homebrew..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

    # Add Homebrew to PATH for Apple Silicon
    if [[ "$(uname -m)" == "arm64" ]]; then
        eval "$(/opt/homebrew/bin/brew shellenv)"
        echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> "$HOME/.zprofile"
    fi
fi

# -------------------------------------------------------------------
# 4. Install Brewfile (CLI tools, casks, fonts)
# -------------------------------------------------------------------
header "Brew Bundle (apps & tools)"
info "Installing from Brewfile..."
brew bundle --file="$DOTFILES/Brewfile"

# -------------------------------------------------------------------
# 5. Create common directories
# -------------------------------------------------------------------
header "Directory structure"
mkdir -p "$HOME/Developer"
mkdir -p "$HOME/Screenshots"
mkdir -p "$HOME/.config"
mkdir -p "$HOME/.config/tmux/plugins"
mkdir -p "$HOME/.config/tmux/themes"
mkdir -p "$HOME/.config/ghostty"
mkdir -p "$HOME/.config/zed"
mkdir -p "$HOME/.config/git"
ok "Directories created"

# -------------------------------------------------------------------
# 6. Symlinks
# -------------------------------------------------------------------
header "Symlinks"
bash "$DOTFILES/scripts/symlinks.sh"

# -------------------------------------------------------------------
# 7. Node.js via NVM
# -------------------------------------------------------------------
header "Node.js (via NVM)"
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
if command -v nvm &>/dev/null; then
    info "Installing latest LTS Node..."
    nvm install --lts
    nvm use --lts
    nvm alias default node
    ok "Node $(node -v) installed"
else
    warn "NVM not found - you may need to restart your shell and run: nvm install --lts"
fi

# -------------------------------------------------------------------
# 8. Global npm packages
# -------------------------------------------------------------------
header "Global npm packages"
npm_globals=(
    typescript
    commitizen
    cz-conventional-changelog
)
info "Installing global npm packages..."
for pkg in "${npm_globals[@]}"; do
    npm install -g "$pkg" 2>/dev/null && ok "$pkg" || warn "Failed: $pkg"
done

# -------------------------------------------------------------------
# 9. Bun
# -------------------------------------------------------------------
header "Bun"
if command -v bun &>/dev/null; then
    ok "Already installed ($(bun --version))"
else
    info "Installing Bun..."
    curl -fsSL https://bun.sh/install | bash
    ok "Bun installed"
fi

# -------------------------------------------------------------------
# 10. Tmux Plugin Manager
# -------------------------------------------------------------------
header "Tmux Plugin Manager"
TPM_DIR="$HOME/.tmux/plugins/tpm"
if [ -d "$TPM_DIR" ]; then
    ok "Already installed"
else
    info "Cloning TPM..."
    git clone https://github.com/tmux-plugins/tpm "$TPM_DIR"
    ok "TPM installed (run prefix + I in tmux to install plugins)"
fi

# -------------------------------------------------------------------
# 11. Tmux Gruvbox theme
# -------------------------------------------------------------------
header "Tmux Gruvbox Theme"
TMUX_THEME_DIR="$HOME/.config/tmux/themes/gruvbox"
if [ -d "$TMUX_THEME_DIR" ]; then
    ok "Already installed"
else
    info "Cloning tmux gruvbox theme..."
    mkdir -p "$HOME/.config/tmux/themes"
    git clone https://github.com/egel/tmux-gruvbox "$TMUX_THEME_DIR"
    ok "Gruvbox theme installed"
fi

# -------------------------------------------------------------------
# 12. VS Code extensions
# -------------------------------------------------------------------
header "VS Code Extensions"
if command -v code &>/dev/null; then
    bash "$DOTFILES/scripts/vscode-extensions.sh"
else
    warn "VS Code CLI (code) not found. Install VS Code first, then run: bash $DOTFILES/scripts/vscode-extensions.sh"
fi

# -------------------------------------------------------------------
# 13. Cursor extensions
# -------------------------------------------------------------------
header "Cursor Extensions"
if command -v cursor &>/dev/null; then
    bash "$DOTFILES/scripts/cursor-extensions.sh"
else
    warn "Cursor CLI not found. Install Cursor first, then run: bash $DOTFILES/scripts/cursor-extensions.sh"
fi

# -------------------------------------------------------------------
# 14. macOS defaults
# -------------------------------------------------------------------
header "macOS System Defaults"
read -p "Apply macOS defaults (keyboard speed, Finder, Dock, etc.)? [y/N] " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    bash "$DOTFILES/scripts/macos-defaults.sh"
fi

# -------------------------------------------------------------------
# 15. SSH key
# -------------------------------------------------------------------
header "SSH Key"
if [ -f "$HOME/.ssh/id_ed25519" ]; then
    ok "SSH key already exists"
else
    info "Generating a new SSH key..."
    read -p "Enter your work email for the SSH key: " ssh_email
    ssh-keygen -t ed25519 -C "$ssh_email" -f "$HOME/.ssh/id_ed25519"
    eval "$(ssh-agent -s)"
    ssh-add --apple-use-keychain "$HOME/.ssh/id_ed25519"

    # Create SSH config for keychain persistence
    mkdir -p "$HOME/.ssh"
    if ! grep -q "AddKeysToAgent" "$HOME/.ssh/config" 2>/dev/null; then
        cat >> "$HOME/.ssh/config" <<'SSHEOF'
Host *
    AddKeysToAgent yes
    UseKeychain yes
    IdentityFile ~/.ssh/id_ed25519
SSHEOF
    fi

    pbcopy < "$HOME/.ssh/id_ed25519.pub"
    ok "SSH key generated and public key copied to clipboard"
    echo ""
    info "Add the key to your GitLab instance:"
    info "  Go to: https://GITLAB_HOST/-/user_settings/ssh_keys"
    info "  (public key is already in your clipboard)"
fi

# -------------------------------------------------------------------
# 16. GitLab CLI auth
# -------------------------------------------------------------------
header "GitLab CLI (glab)"
if command -v glab &>/dev/null; then
    info "Authenticate glab with your GitLab instance:"
    info "  Run: glab auth login --hostname GITLAB_HOST"
    info "  (you can do this after the setup finishes)"
else
    warn "glab not found -- install it via: brew install glab"
fi

# -------------------------------------------------------------------
# Done
# -------------------------------------------------------------------
header "Setup Complete!"
echo ""
echo "  Placeholders to fill in:"
echo "  - WORK_EMAIL  in ~/.gitconfig"
echo "  - GITLAB_HOST in ~/.ssh/config and glab auth"
echo ""
echo "  Next steps:"
echo "  1. Restart your terminal (or run: source ~/.zshrc)"
echo "  2. Fill in placeholders: git config --global user.email 'you@company.com'"
echo "  3. Authenticate GitLab: glab auth login --hostname gitlab.yourcompany.com"
echo "  4. Open tmux and press prefix + I to install tmux plugins"
echo "  5. Open Neovim - Lazy.nvim will auto-install plugins"
echo "  6. Sign into your apps (Slack, Chrome, Zoom, etc.)"
echo "  7. Sign into Google services in Chrome (Gmail, Calendar, Drive, Meet)"
echo ""
