# Environment
$env.EDITOR = "nvim"
$env.VISUAL = "nvim"
$env.NVIM_APPNAME = "chad"


# PATH
$env.PATH = (
    $env.PATH
    | prepend [
        "/home/zenitram/.opencode/bin"
        "/home/zenitram/.local/bin"
        "/snap/bin"
        "/usr/local/bin"
        "/home/linuxbrew/.linuxbrew/bin"
    ]
)


# Optional Linuxbrew vars
$env.HOMEBREW_PREFIX = "/home/linuxbrew/.linuxbrew"
$env.HOMEBREW_CELLAR = "/home/linuxbrew/.linuxbrew/Cellar"
$env.HOMEBREW_REPOSITORY = "/home/linuxbrew/.linuxbrew/Homebrew"
