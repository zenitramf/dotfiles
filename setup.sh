#!/bin/bash
export XDG_CONFIG_HOME="$HOME"/.config
mkdir -p "$XDG_CONFIG_HOME"

ln -sf "$PWD/nvim" "$XDG_CONFIG_HOME"/nvim

ln -sf "$PWD/.bashrc" "$HOME"/.bashrc

packages=(
    fd
    ripgrep
    starship
    lazygit
    zoxide
    python
    go
    oxlint
    oxfmt
    prettier
    tree-sitter-cli
    rust
)

for package in "${packages[@]}"; do
    echo "Installing $package..."
    /home/linuxbrew/.linuxbrew/bin/brew install "$package"
done

echo "Installing vite+..."
curl -fsSL https://vite.plus | bash

echo "All packages from the setup script have been installed."
