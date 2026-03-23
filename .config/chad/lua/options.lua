require "nvchad.options"

-- add yours here!

local o = vim.o
o.cursorlineopt = "both" -- to enable cursorline!

o.clipboard = "unnamedplus"

o.foldmethod = "expr"
o.foldexpr = "nvim_treesitter#foldexpr()"

o.foldcolumn = "auto"
o.foldlevel = 99 -- Using ufo provider need a large value
o.foldlevelstart = 99
o.foldnestmax = 0
o.foldenable = true
o.foldmethod = "indent"

o.winheight = 25
o.winminheight = 25
o.winwidth = 20
o.winminwidth = 10
o.equalalways = false

vim.opt.fillchars = {
  fold = " ",
  foldopen = "",
  foldsep = " ",
  foldclose = "",
  stl = " ",
  eob = " ",
}

-- Force clipboard integration in WSL (Windows clipboard)
vim.g.clipboard = {
  name = "win32yank-wsl",
  copy = {
    ["+"] = "win32yank.exe -i --crlf",
    ["*"] = "win32yank.exe -i --crlf",
  },
  paste = {
    ["+"] = "win32yank.exe -o --lf",
    ["*"] = "win32yank.exe -o --lf",
  },
  cache_enabled = 0,
}

vim.lsp.inlay_hint.enable(false)

vim.filetype.add {

  extension = {
    mdx = "mdx",
  },
}
