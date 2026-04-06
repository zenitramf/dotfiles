set -g fish_greeting "Hello!!"


# starship init fish | source

alias ls="li -1"
alias lsa="llai"
alias fishconfig="nvim ~/dotfiles/.config/fish/config.fish"
alias nvimconfig="cd ~/dotfiles/.config/kicknvim/ && nvim ."

set -gx EDITOR nvim
set -gx VISUAL nvim

set -x NVIM_APPNAME minvm

# zoxide init --cmd cd fish | source

fish_add_path --move --prepend $HOME/.vite-plus/bin
fish_add_path $HOME/.opencode/bin
fish_add_path $HOME/.local/bin
fish_add_path /usr/local/bin
fish_add_path /snap/bin
fish_add_path $HOME/linuxbrew/.linuxbrew/bin

alias obsidian='/mnt/c/Program\ Files/Obsidian/Obsidian.com'


# Win32Yank
# function win32yank
#     /mnt/c/Users/marti/scoop/shims/win32yank.exe $argv
# end
