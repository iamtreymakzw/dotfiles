#!/usr/bin/env bash
# Install Cursor extensions (same as VS Code, minus Copilot — Cursor has built-in AI)
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
    jdinhlife.gruvbox
    kisstkondoros.vscode-gutter-preview
    miguelsolorio.symbols
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

info "Installing Cursor extensions..."
for ext in "${extensions[@]}"; do
    cursor --install-extension "$ext" --force 2>/dev/null && ok "$ext" || true
done

info "Cursor extensions installed!"
