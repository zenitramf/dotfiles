$env.config.show_banner = false
$env.config.buffer_editor = "nvim"

  
# Zed (WSL)
def --wrapped zed [...args] {
    ^/mnt/c/Users/marti/AppData/Local/Programs/Zed/Zed.exe ...$args
}

# Obsidian (WSL)
def --wrapped obsidian [...args] {
    ^"/mnt/c/Program Files/Obsidian/Obsidian.com" ...$args
}

# List all files, including hidden ones, sorted by modified date in reverse order
def lsa [] {
    ls -a | sort-by modified --reverse
}

mkdir ($nu.data-dir | path join "vendor/autoload")
starship init nu | save -f ($nu.data-dir | path join "vendor/autoload/starship.nu")
