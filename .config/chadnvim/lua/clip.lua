if vim.fn.has "wsl" == 1 then
  vim.g.clipboard = {
    name = "wsl-clipboard",
    copy = {
      ["+"] = { "clip.exe" },
      ["*"] = { "clip.exe" },
    },
    paste = {
      ["+"] = { "powershell.exe", "-noprofile", "-command", "Get-Clipboard | Out-String | %%{$_ -replace '\\r', ''}" },
      ["*"] = { "powershell.exe", "-noprofile", "-command", "Get-Clipboard | Out-String | %%{$_ -replace '\\r', ''}" },
    },
  }
elseif vim.fn.has "mac" == 1 then
  vim.g.clipboard = {
    name = "macOS-clipboard",
    copy = {
      ["+"] = { "pbcopy" },
      ["*"] = { "pbcopy" },
    },
    paste = {
      ["+"] = { "pbpaste" },
      ["*"] = { "pbpaste" },
    },
  }
elseif vim.fn.executable "wl-copy" == 1 and vim.fn.executable "wl-paste" == 1 then
  vim.g.clipboard = {
    name = "Wayland-clipboard",
    copy = {
      ["+"] = { "wl-copy", "--foreground", "--type", "text/plain" },
      ["*"] = { "wl-copy", "--foreground", "--type", "text/plain" },
    },
    paste = {
      ["+"] = { "wl-paste", "--no-newline" },
      ["*"] = { "wl-paste", "--no-newline" },
    },
  }
elseif vim.fn.executable "xclip" == 1 then
  vim.g.clipboard = {
    name = "xclip-clipboard",
    copy = {
      ["+"] = { "xclip", "-selection", "clipboard" },
      ["*"] = { "xclip", "-selection", "primary" },
    },
    paste = {
      ["+"] = { "xclip", "-selection", "clipboard", "-o" },
      ["*"] = { "xclip", "-selection", "primary", "-o" },
    },
  }
end
