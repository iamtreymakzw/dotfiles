#!/usr/bin/env bash
# Install VS Code extensions
set -euo pipefail

info() { printf "\033[0;34m[info]\033[0m %s\n" "$1"; }
ok()   { printf "\033[0;32m[ok]\033[0m   %s\n" "$1"; }

extensions=(
    aaron-bond.better-comments
    albert.tabout
    biomejs.biome
    bradlc.vscode-tailwindcss
    dbaeumer.vscode-eslint
    eamodio.gitlens
    esbenp.prettier-vscode
    github.copilot
    github.copilot-chat
    jdinhlife.gruvbox
    kisstkondoros.vscode-gutter-preview
    mechatroner.rainbow-csv
    miguelsolorio.symbols
    ms-vsliveshare.vsliveshare
    prisma.prisma
    rafamel.subtle-brackets
    sirtori.indenticator
    sonarsource.sonarlint-vscode
    streetsidesoftware.code-spell-checker
    usernamehw.errorlens
    vscodevim.vim
    wayou.vscode-todo-highlight
    yoavbls.pretty-ts-errors
)

info "Installing VS Code extensions..."
for ext in "${extensions[@]}"; do
    code --install-extension "$ext" --force 2>/dev/null && ok "$ext" || true
done

info "VS Code extensions installed!"
