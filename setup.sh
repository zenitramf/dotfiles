#!/bin/bash
set -euo pipefail

export XDG_CONFIG_HOME="$HOME/.config"
mkdir -p "$XDG_CONFIG_HOME"

ln -sf "$PWD/.config/minvm" "$XDG_CONFIG_HOME/nvim"
ln -sf "$PWD/.bashrc" "$HOME/.bashrc"

echo "Installing apt packages..."
sudo apt update

if apt-cache show python3.13-venv >/dev/null 2>&1; then
    sudo apt install -y python3.13-venv
else
    echo "python3.13-venv not available; installing python3-venv instead..."
    sudo apt install -y python3-venv
fi

echo "Installing mise..."
if ! command -v mise >/dev/null 2>&1; then
    curl https://mise.run | sh
fi

export PATH="$HOME/.local/bin:$PATH"

echo "Installing vite+..."
curl -fsSL https://vite.plus | bash

echo "Installing npm global packages..."
if command -v npm >/dev/null 2>&1; then
    npm install -g tree-sitter-cli
    npm install -g @earendil-works/pi-coding-agent
else
    echo "npm not found; skipping npm global packages."
fi

echo "Installing tools with mise..."
mise use --global \
    fd@latest \
    neovim@latest \
    ripgrep@latest \
    lazygit@latest \
    starship@latest \
    zoxide@latest \
    go@latest \
    uv@latest \
    oxlint@latest \
    oxfmt@latest \
    prettier@latest \
    lazygit@latest \
    just@latest \
    fzf@latest \
    eza@latest \
    infisical@latest

echo "All packages from the setup script have been installed."

git config --global user.name "zenitramf"
git config --global user.email "francisco@zenitram.dev"
