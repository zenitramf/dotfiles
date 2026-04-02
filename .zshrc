eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"

typeset -U path

path=(
  $HOME/.vite-plus/bin        # 🔥 FIRST (your requirement)
  $HOME/.opencode/bin
  $HOME/.local/bin
  /usr/local/bin
  /snap/bin
  $HOME/linuxbrew/.linuxbrew/bin
  $HOME/.cargo/bin
  $HOME/go/bin
  /opt
  $path
)

# Path to your Oh My Zsh installation.
export ZSH="$HOME/.oh-my-zsh"

plugins=(
  git
  httpie
  gh
  aws
  ssh
  systemd
  ubuntu
  history
  fzf
  eza
  zsh-syntax-highlighting
)

source $ZSH/oh-my-zsh.sh

function y() {
	local tmp="$(mktemp -t "yazi-cwd.XXXXXX")" cwd
	yazi "$@" --cwd-file="$tmp"
	if cwd="$(command cat -- "$tmp")" && [ -n "$cwd" ] && [ "$cwd" != "$PWD" ]; then
		builtin cd -- "$cwd"
	fi
	rm -f -- "$tmp"
}

ranger() {
    local IFS=$'\t\n'
    local tempfile
    tempfile="$(mktemp -t tmp.XXXXXX)"

    local ranger_cmd=(
        command ranger
        --cmd="map Q chain shell echo %d > \"$tempfile\"; quitall"
    )

    "${ranger_cmd[@]}" "$@"

    if [[ -f "$tempfile" ]]; then
        local newdir
        newdir="$(<"$tempfile")"
        if [[ "$newdir" != "$(pwd)" ]]; then
            cd -- "$newdir" || return
        fi
    fi

    rm -f -- "$tempfile" 2>/dev/null
}

xdg-open() {
  if [[ "$1" =~ ^https?:// ]]; then
    explorer.exe "$1"
  else
    explorer.exe "$(wslpath -w "$1")"
  fi
}

eval "$(starship init zsh)"
export NVIM_APPNAME=chad

# --- Yazi Setup --- #
export EDITOR="nvim"

# Alias definitions.
# You may want to put all your additions into a separate file like
# ~/.bash_aliases, instead of adding them here directly.
# See /usr/share/doc/bash-doc/examples in the bash-doc package.

if [ -f ~/.bash_aliases ]; then
  . ~/.bash_aliases
fi


# ---- FZF -----

# -- Use fd instead of fzf --

export FZF_DEFAULT_COMMAND="fd --hidden --strip-cwd-prefix --exclude .git"
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
export FZF_ALT_C_COMMAND="fd --type=d --hidden --strip-cwd-prefix --exclude .git"

# Use fd (https://github.com/sharkdp/fd) for listing path candidates.
# - The first argument to the function ($1) is the base path to start traversal
# - See the source code (completion.{bash,zsh}) for the details.
_fzf_compgen_path() {
  fd --hidden --exclude .git . "$1"
}

# Use fd to generate the list for directory completion
_fzf_compgen_dir() {
  fd --type=d --hidden --exclude .git . "$1"
}


show_file_or_dir_preview="if [ -d \"{}\" ]; then eza --tree --color=always \"{}\" | head -200; else bat -n --color=always --line-range :500 \"{}\"; fi"

export FZF_CTRL_T_OPTS="--preview '$show_file_or_dir_preview'"
export FZF_ALT_C_OPTS="--preview 'eza --tree --color=always {} | head -200'"

# Advanced customization of fzf options via _fzf_comprun function
# - The first argument to the function is the name of the command.
# - You should make sure to pass the rest of the arguments to fzf.
_fzf_comprun() {
  local command=$1
  shift

  case "$command" in
    cd)           fzf --preview 'eza --tree --color=always {} | head -200' "$@" ;;
    export|unset) fzf --preview "eval 'echo \${}'"         "$@" ;;
    ssh)          fzf --preview "ssh -G -T {}| sed -E 's/^([^ ]+) (.+)$/\1: \2/' | bat --language=yaml" "$@" ;;
    *)            fzf --preview "$show_file_or_dir_preview" "$@" ;;
  esac
}

# ---- Eza (better ls) -----

alias ls="eza --icons=always -1"

eval "$(zoxide init --cmd cd zsh)"

# The next line updates PATH for the Google Cloud SDK.
if [ -f '/home/swimlane/google-cloud-sdk/path.zsh.inc' ]; then . '/home/swimlane/google-cloud-sdk/path.zsh.inc'; fi

# The next line enables shell command completion for gcloud.
if [ -f '/home/swimlane/google-cloud-sdk/completion.zsh.inc' ]; then . '/home/swimlane/google-cloud-sdk/completion.zsh.inc'; fi
