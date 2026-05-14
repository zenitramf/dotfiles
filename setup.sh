#!/bin/bash
set -euo pipefail

export XDG_CONFIG_HOME="$HOME/.config"
mkdir -p "$XDG_CONFIG_HOME"

ln -sf "$PWD/nvim" "$XDG_CONFIG_HOME/nvim"
ln -sf "$PWD/.bashrc" "$HOME/.bashrc"

echo "Installing apt packages..."
sudo apt update

if apt-cache show python3.13-venv >/dev/null 2>&1; then
    sudo apt install -y python3.13-venv
else
    echo "python3.13-venv not available; installing python3-venv instead..."
    sudo apt install -y python3-venv
fi

sudo apt install -y fish

mkdir -p "$HOME/.config/fish"
ln -sf "$PWD/config.fish" "$HOME/.config/fish/config.fish"

echo "Installing Fisher..."
fish -c 'curl -sL https://raw.githubusercontent.com/jorgebucaran/fisher/main/functions/fisher.fish | source && fisher install jorgebucaran/fisher'

echo "Installing Tide..."
fish -c 'fisher install IlanCosman/tide@v6'

echo "Configuring Tide..."
fish -c "tide configure --auto \
  --style=Rainbow \
  --prompt_colors='True color' \
  --show_time=No \
  --rainbow_prompt_separators=Angled \
  --powerline_prompt_heads=Sharp \
  --powerline_prompt_tails=Flat \
  --powerline_prompt_style='Two lines, character and frame' \
  --prompt_connection=Solid \
  --powerline_right_prompt_frame=No \
  --prompt_connection_andor_frame_color=Darkest \
  --prompt_spacing=Sparse \
  --icons='Few icons' \
  --transient=No"

FISH_PATH="$(command -v fish)"

if ! grep -qxF "$FISH_PATH" /etc/shells; then
    echo "$FISH_PATH" | sudo tee -a /etc/shells
fi

echo "Setting fish as default shell..."
if command -v chsh >/dev/null 2>&1; then
    chsh -s "$FISH_PATH" || echo "Could not change default shell. This is common in containers/DevPod."
else
    echo "chsh not available; skipping default shell change."
fi

BREW="/home/linuxbrew/.linuxbrew/bin/brew"

if [ ! -x "$BREW" ]; then
    echo "Homebrew not found at $BREW"
    echo "Install Homebrew first or update the BREW path in this script."
    exit 1
fi

packages=(
    fd
    ripgrep
    lazygit
    zoxide
    python
    go
    oxlint
    oxfmt
    prettier
    tree-sitter-cli
)

for package in "${packages[@]}"; do
    echo "Installing $package..."
    "$BREW" install "$package"
done

echo "Installing vite+..."
curl -fsSL https://vite.plus | bash

echo "Installing pi-coding-agent..."
if command -v npm >/dev/null 2>&1; then
    npm install -g @earendil-works/pi-coding-agent
else
    echo "npm not found; skipping pi-coding-agent install."
fi

echo "All packages from the setup script have been installed."
