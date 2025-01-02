# Instructions for ARCH on WSL2

## Install Apps

[Install AWS CLI V2](https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html)

---

[Install Poetry](https://python-poetry.org/docs/#installing-with-the-official-installer)
Use the Official Installer `curl -sSL https://install.python-poetry.org | python3 -`

---

[TMUX Plugin Manager](https://github.com/tmux-plugins/tpm)
Clone TPM `git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm`
This repo has all other steps configured

Reload tmux Configuration `tmux source ~/.config/tmux/tmux.conf`

---

[PNPM](https://pnpm.io/installation)
`curl -fsSL https://get.pnpm.io/install.sh | sh -`

---

[Starship](https://starship.rs/guide/#%F0%9F%9A%80-installation)
`curl -sS https://starship.rs/install.sh | sh`
If using Arch you can install using `sudo pacman -s starship`

---

[wsl-open](https://gitlab.com/4U6U57/wsl-open)

```
# Make a bin folder in your home directory
mkdir ~/bin

# Add the bin folder to your PATH in your bashrc
echo '[[ -e ~/bin ]] && export PATH=$PATH:~/bin' >> ~/.bashrc

# Download the script to a file named 'wsl-open'
curl -o ~/bin/wsl-open https://raw.githubusercontent.com/4U6U57/wsl-open/master/wsl-open.sh

```

[eza](https://github.com/eza-community/eza/blob/main/INSTALL.md)
`cargo install eza`
Need Rust and Cargo Installed

## Install Using pacman

List of apps to install using pacman.
`sudo pacman -S <APP>`

```pacman
7zip 24.09-3
base 3-2
base-devel 1-2
bottom 0.10.2-1
fd 10.2.0-1
fzf 0.57.0-1
gdu 5.29.0-1
git 2.47.1-1
github-cli 2.64.0-1
go 2:1.23.4-1
imagemagick 7.1.1.43-1
jq 1.7.1-2
lazygit 0.44.1-1
nano 8.2-1
neovim 0.10.3-1
openssh 9.9p1-2
python 3.13.1-1
python-pip 24.3.1-3
ripgrep 14.1.1-1
rust 1:1.83.0-1
starship 1.21.1-1
stow 2.4.1-1
sudo 1.9.16.p2-2
tmux 3.5_a-1
unzip 6.0-21
vim 9.1.0954-1
wget 1.25.0-1
wslu 4.1.1-0
yazi 0.4.2-1
zoxide 0.9.6-1
zsh 5.9-5
```
