set -g fish_greeting ""


eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"

starship init fish | source

alias tf='terraform'
alias nvchad='export NVIM_APPNAME=nvchad'
alias lazy='export NVIM_APPNAME=lazynvim'
alias nvim_default='export NVIM_APPNAME=nvim'
alias ls="li -1"
alias lsa="llai"
alias fishconfig="nvim ~/dotfiles/.config/fish/config.fish"
alias nvimconfig="cd ~/dotfiles/.config/kicknvim/ && nvim ."
alias zw='sesh connect zenwiki -c "cd ~/git/zenwiki && nvim "'

# --- Zed (WSL Remote) ---
# fish aliases can't forward args reliably; use a function instead.
functions -e zed 2>/dev/null
function zed --description "Open Zed from WSL using Windows Zed in Remote WSL mode"
    /mnt/c/Users/marti/AppData/Local/Programs/Zed/Zed.exe $argv
end

set -gx EDITOR nvim
set -gx VISUAL nvim

set -x NVIM_APPNAME chad
set -x PATH $PATH:/usr/local/bin
set -x PATH "/snap/bin:$PATH"
set -x PATH "$HOME/.local/bin:$PATH"

zoxide init --cmd cd fish | source


# opencode
fish_add_path /home/zenitram/.opencode/bin

function obsidian
    nohup /home/zenitram/.local/bin/obsidian >/dev/null 2>&1 &
end
