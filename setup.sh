#!/bin/bash
set -euo pipefail

export XDG_CONFIG_HOME="$HOME/.config"
mkdir -p "$XDG_CONFIG_HOME"

ln -sf "$PWD/.config/minvm" "$XDG_CONFIG_HOME/nvim"
ln -sf "$PWD/.bashrc" "$HOME/.bashrc"

git clone https://github.com/tmuxpack/tpack ~/.tmux/plugins/tpm
ln -sf "$PWD/.config/tmux" "$XDG_CONFIG_HOME/tmux"

echo "Installing apt packages..."
sudo apt update

echo "installing python3-venv..."
sudo apt install -y python3-venv
sudo apt install -y clang

echo "Installing mise..."
if ! command -v mise >/dev/null 2>&1; then
    curl https://mise.run | sh
fi

echo "Installing Homebrew"
if ! command -v brew >/dev/null 2>&1; then
  echo "Installing Homebrew..."
  NONINTERACTIVE=1 /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi

# Evaluate Homebrew shell environment immediately for this script session.
if [[ -x /opt/homebrew/bin/brew ]]; then
  # Apple Silicon Macs
  eval "$(/opt/homebrew/bin/brew shellenv)"
elif [[ -x /home/linuxbrew/.linuxbrew/bin/brew ]]; then
  # Linuxbrew
  eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
else
  echo "Homebrew installed, but brew binary was not found in a known location." >&2
  exit 1
fi

echo "Current Brew Version is.."
brew --version

echo "Installing Brew Packages"
brew install \
  fd \
  neovim \
  ripgrep \
  lazygit \
  starship \
  zoxide \
  go \
  uv \
  oxlint \
  prettier \
  just \
  fzf \
  eza \
  infisical \
  tmux \
  tree-sitter-cli \
  zsh \
  stow


export PATH="$HOME/.local/bin:$PATH"

echo "Installing vite+..."
curl -fsSL https://vite.plus | bash

echo "Installing npm global packages..."
if command -v npm >/dev/null 2>&1; then
    npm install -g --ignore-scripts @earendil-works/pi-coding-agent
    pi install npm:pi-mcp-extension
else
    echo "npm not found; skipping npm global packages."
fi


echo "All packages from the setup script have been installed."

git config --global user.name "zenitramf"
git config --global user.email "francisco@zenitram.dev"

echo "Updating default shell"

BREW_ZSH="$(brew --prefix)/bin/zsh"

if [[ ! -x "$BREW_ZSH" ]]; then
  echo "zsh was installed, but $BREW_ZSH is not executable." >&2
  exit 1
fi

if ! grep -qxF "$BREW_ZSH" /etc/shells; then
  echo "Adding $BREW_ZSH to /etc/shells..."
  echo "$BREW_ZSH" | sudo tee -a /etc/shells >/dev/null
fi

CURRENT_SHELL="$(dscl . -read "/Users/$USER" UserShell 2>/dev/null | awk '{print $2}' || true)"

if [[ "$CURRENT_SHELL" != "$BREW_ZSH" ]]; then
  echo "Changing default shell to $BREW_ZSH..."
  chsh -s "$BREW_ZSH"
fi

echo "Default shell is now set to: $BREW_ZSH"

echo "........"

echo "removing default .bashrc"
rm ~/.bashrc

echo "Attempting to run stow on dotfiles"
DOTFILES_DIR="$HOME/dotfiles"

if [[ -d "$DOTFILES_DIR" ]]; then
  echo "Dotfiles directory already exists. Running stow..."
else
  echo "Cloning dotfiles..."
  git clone git@github.com:zenitramf/dotfiles.git "$DOTFILES_DIR"
fi

cd "$DOTFILES_DIR"
STOW_OUTPUT="$(stow --simulate --verbose . 2>&1 || true)"

echo "$STOW_OUTPUT"

CONFLICTS="$(
  echo "$STOW_OUTPUT" \
    | sed -nE "s/.*existing target is neither a link nor a directory: (.*)/\1/p"
)"

if [[ -n "$CONFLICTS" ]]; then
  echo "Removing conflicting files outside dotfiles directory..."

  while IFS= read -r conflict; do
    [[ -z "$conflict" ]] && continue

    TARGET="$HOME/$conflict"

    if [[ "$TARGET" == "$DOTFILES_DIR"* ]]; then
      echo "Skipping unsafe path inside dotfiles directory: $TARGET"
      continue
    fi

    if [[ -e "$TARGET" || -L "$TARGET" ]]; then
      echo "Removing $TARGET"
      rm -rf "$TARGET"
    fi
  done <<< "$CONFLICTS"
fi

echo "Running stow..."
stow .


echo "Installing Devpod"
if ! command -v devpod >/dev/null 2>&1; then
    curl -L -o devpod "https://github.com/loft-sh/devpod/releases/latest/download/devpod-linux-amd64" && sudo install -c -m 0755 devpod /usr/local/bin && rm -f devpod

else
    echo "Devpod is already installed."
fi

echo "complete initial setup"
