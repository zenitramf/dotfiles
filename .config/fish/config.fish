eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"

starship init fish | source

alias tf='terraform'
alias nvchad='export NVIM_APPNAME=nvchad'
alias lazy='export NVIM_APPNAME=lazynvim'
alias nvim_default='export NVIM_APPNAME=nvim'
alias ls="li -1"
alias lsa="llai"

set -x NVIM_APPNAME kicknvim
set -x PATH $PATH:/usr/local/bin
set -x PATH "/snap/bin:$PATH"
set -x PATH "$HOME/.local/bin:$PATH"




zoxide init --cmd cd fish | source


# opencode
fish_add_path /home/zenitram/.opencode/bin
