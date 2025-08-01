setopt NO_BEEP
export LIBGL_ALWAYS_INDIRECT=1

# if [ -z "$TMUX" ]; then
#     tmux attach-session -t default || tmux new-session -s default
# fi

eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"


# Automatically start or attach to Zellij session
# if [[ -z $ZELLIJ && $- == *i* ]]; then
#   zellij attach --create default
# fi

# echo 'eval "$(zellij setup --generate-auto-start zsh)"' >> ~/.zshrc

if [ -z "$DBUS_SESSION_BUS_ADDRESS" ]; then
    eval "$(dbus-launch --sh-syntax)"
fi
# If you come from bash you might have to change your $PATH.
# export PATH=$HOME/bin:$HOME/.local/bin:/usr/local/bin:$PATH

export PATH=$HOME/.cargo/bin:$PATH
export PATH=$HOME/go/bin:$PATH
export PATH="/opt:$PATH"

# Path to your Oh My Zsh installation.
export ZSH="$HOME/.oh-my-zsh"

# Set name of the theme to load --- if set to "random", it will
# load a random theme each time Oh My Zsh is loaded, in which case,
# to know which specific one was loaded, run: echo $RANDOM_THEME
# See https://github.com/ohmyzsh/ohmyzsh/wiki/Themes

# Set list of themes to pick from when loading at random
# Setting this variable when ZSH_THEME=random will cause zsh to load
# a theme from this variable instead of looking in $ZSH/themes/
# If set to an empty array, this variable will have no effect.
# ZSH_THEME_RANDOM_CANDIDATES=( "robbyrussell" "agnoster" )

# Uncomment the following line to use case-sensitive completion.
# CASE_SENSITIVE="true"

# Uncomment the following line to use hyphen-insensitive completion.
# Case-sensitive completion must be off. _ and - will be interchangeable.
# HYPHEN_INSENSITIVE="true"

# Uncomment one of the following lines to change the auto-update behavior
# zstyle ':omz:update' mode disabled  # disable automatic updates
# zstyle ':omz:update' mode auto      # update automatically without asking
# zstyle ':omz:update' mode reminder  # just remind me to update when it's time

# Uncomment the following line to change how often to auto-update (in days).
# zstyle ':omz:update' frequency 13

# Uncomment the following line if pasting URLs and other text is messed up.
# DISABLE_MAGIC_FUNCTIONS="true"

# Uncomment the following line to disable colors in ls.
# DISABLE_LS_COLORS="true"

# Uncomment the following line to disable auto-setting terminal title.
# DISABLE_AUTO_TITLE="true"

# Uncomment the following line to enable command auto-correction.
# ENABLE_CORRECTION="true"

# Uncomment the following line to display red dots whilst waiting for completion.
# You can also set it to another string to have that shown instead of the default red dots.
# e.g. COMPLETION_WAITING_DOTS="%F{yellow}waiting...%f"
# Caution: this setting can cause issues with multiline prompts in zsh < 5.7.1 (see #5765)
# COMPLETION_WAITING_DOTS="true"

# Uncomment the following line if you want to disable marking untracked files
# under VCS as dirty. This makes repository status check for large repositories
# much, much faster.
# DISABLE_UNTRACKED_FILES_DIRTY="true"

# Uncomment the following line if you want to change the command execution time
# stamp shown in the history command output.
# You can set one of the optional three formats:
# "mm/dd/yyyy"|"dd.mm.yyyy"|"yyyy-mm-dd"
# or set a custom format using the strftime function format specifications,
# see 'man strftime' for details.
# HIST_STAMPS="mm/dd/yyyy"

# Would you like to use another custom folder than $ZSH/custom?
# ZSH_CUSTOM=/path/to/new-custom-folder

# Which plugins would you like to load?
# Standard plugins can be found in $ZSH/plugins/
# Custom plugins may be added to $ZSH_CUSTOM/plugins/
# Example format: plugins=(rails git textmate ruby lighthouse)
# Add wisely, as too many plugins slow down shell startup.
plugins=(
  git
  httpie
  gh
  aws
  poetry
  poetry-env
  ssh
  systemd
  ubuntu
  history
  dotenv
  fzf
  eza
  zsh-nvim-appname
)

source $ZSH/oh-my-zsh.sh

# User configuration

# export MANPATH="/usr/local/man:$MANPATH"

# You may need to manually set your language environment
# export LANG=en_US.UTF-8

# Preferred editor for local and remote sessions
# if [[ -n $SSH_CONNECTION ]]; then
#   export EDITOR='vim'
# else
#   export EDITOR='nvim'
# fi

# Compilation flags
# export ARCHFLAGS="-arch $(uname -m)"

# Set personal aliases, overriding those provided by Oh My Zsh libs,
# plugins, and themes. Aliases can be placed here, though Oh My Zsh
# users are encouraged to define aliases within a top-level file in
# the $ZSH_CUSTOM folder, with .zsh extension. Examples:
# - $ZSH_CUSTOM/aliases.zsh
# - $ZSH_CUSTOM/macos.zsh
# For a full list of active aliases, run `alias`.
#
# Example aliases
# alias zshconfig="mate ~/.zshrc"
# alias ohmyzsh="mate ~/.oh-my-zsh"

function y() {
	local tmp="$(mktemp -t "yazi-cwd.XXXXXX")" cwd
	yazi "$@" --cwd-file="$tmp"
	if cwd="$(command cat -- "$tmp")" && [ -n "$cwd" ] && [ "$cwd" != "$PWD" ]; then
		builtin cd -- "$cwd"
	fi
	rm -f -- "$tmp"
}

# Load AWS credentials from Keeper Secrets Manager (KSM)
aws_ksm_login() {
  if ! command -v ksm >/dev/null 2>&1; then
    echo "❌ Error: 'ksm' command not found. Please install Keeper Secrets Manager CLI first."
    return 1
  fi

  if [[ -z "$1" ]]; then
    echo "Usage: aws_ksm_login <record_uid>"
    return 1
  fi

  export AWS_ACCESS_KEY_ID=$(ksm secret get "$1" -f login)
  export AWS_SECRET_ACCESS_KEY=$(ksm secret get "$1" -f password)

  echo "🔐 AWS credentials loaded into environment from Keeper record UID: $1"
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

alias tf='terraform'
alias nvchad='export NVIM_APPNAME=chadnvim'
alias lazy='export NVIM_APPNAME=lazynvim'
alias nvim_default='export NVIM_APPNAME=nvim'

alias vfzf='nvim $(fzf --preview="bat --color=always {}")'


eval "$(starship init zsh)"
export NVIM_APPNAME=chadnvim
export OPENAI_KEY=
export PATH=$PATH:/usr/local/bin
export PATH="/snap/bin:$PATH"
export PATH="$HOME/.local/bin:$PATH"

# --- Yazi Setup --- #
export EDITOR="nvim"

# Alias definitions.
# You may want to put all your additions into a separate file like
# ~/.bash_aliases, instead of adding them here directly.
# See /usr/share/doc/bash-doc/examples in the bash-doc package.

if [ -f ~/.bash_aliases ]; then
  . ~/.bash_aliases
fi

# pnpm
export PNPM_HOME="$HOME/.local/share/pnpm"
case ":$PATH:" in
*":$PNPM_HOME:"*) ;;
*) export PATH="$PNPM_HOME:$PATH" ;;
esac
# pnpm end

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

# Cargo
export PATH=/usr/local/bin:/usr/bin:/bin:$PATH

PATH=$HOME/.console-ninja/.bin:$PATH

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion
eval "$(zoxide init --cmd cd zsh)"

# The next line updates PATH for the Google Cloud SDK.
if [ -f '/home/swimlane/google-cloud-sdk/path.zsh.inc' ]; then . '/home/swimlane/google-cloud-sdk/path.zsh.inc'; fi

# The next line enables shell command completion for gcloud.
if [ -f '/home/swimlane/google-cloud-sdk/completion.zsh.inc' ]; then . '/home/swimlane/google-cloud-sdk/completion.zsh.inc'; fi

