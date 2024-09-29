# Install Configuration for New WSL Setup
## Install WSL Apps
`sudo apt install node`
`sudo apt install go`
`sudo apt install deno`

# Node Prerequesites
## pnpm
`curl -fsSL https://get.pnpm.io/install.sh | sh -`

## Install Neovim
`sudo snap install neovim --classic`

## Install Neovim Prerequesites
### Install make
`sudo apt install make`

### Install GCC
`sudo apt install GCC`

### Install Luarocks
[Reference](https://innovativeinnovation.github.io/ubuntu-setup/lua/luarocks.html)
Run install command
`sudo apt install luarocks`

Check installation using 
`luarocks --version`

### Install Rust
 [Reference](https://phoenixnap.com/kb/install-rust-ubuntu)
Install using Rustup
`curl https://sh.rustup.rs -sSf | sh`

### Install Ripgrep
`sudo apt install ripgrep`

### Run nvim
`: MasonInstallAll`

## Install Starship
[Reference](https://starship.rs/)
Install Latest Version with Shell
`curl -sS https://starship.rs/install.sh | sh`

## Install tmux package manager
`git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm`

Reload tmux Configuration
`tmux source ~/.config/tmux/tmux.conf`


