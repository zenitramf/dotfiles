local o = vim.o
-- set <space> as the leader key
-- must happen before plugins are loaded (otherwise wrong leader will be used)
vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- enable true color support
o.termguicolors = true

-- make line numbers default
o.number = true
o.relativenumber = false

-- enable mouse mode, can be useful for resizing splits for example!
o.mouse = "a"

-- don't show the mode, since it's already in the status line
o.showmode = false

-- sync clipboard between OS and Neovim.
--  remove this option if you want your OS clipboard to remain independent.
--  see `:help 'clipboard'`
o.clipboard = "unnamedplus"

-- save undo history
o.undofile = true

-- case-insensitive searching UNLESS \C or one or more capital letters in the search term
o.ignorecase = true
o.smartcase = true

-- keep signcolumn on by default
o.signcolumn = "yes"

-- decrease update time
o.updatetime = 250

-- decrease mapped sequence wait time
-- displays which-key popup sooner
o.timeoutlen = 300

-- configure how new splits should be opened
o.splitright = true
o.splitbelow = true

-- sets how neovim will display certain whitespace characters in the editor.
--  See `:help 'list'`
--  and `:help 'listchars'`
o.list = true
o.listchars = "tab:» ,trail:·,nbsp:␣"

-- preview substitutions live, as you type!
o.inccommand = "split"

-- show which line your cursor is on
o.cursorlineopt = "both"

-- enable line wrapping
o.wrap = true

-- Indenting
o.expandtab = true
o.shiftwidth = 2
o.smartindent = true
o.tabstop = 2
o.softtabstop = 2

-- folding
o.foldcolumn = "auto"
o.foldlevel = 99 -- Using ufo provider need a large value
o.foldlevelstart = 99
o.foldenable = true
o.foldmethod = "expr"
o.foldexpr = "v:lua.vim.treesitter.foldexpr()"

o.fillchars = "fold: ,foldopen:,foldsep: ,foldclose:,stl: ,eob: "

vim.diagnostic.config({
	signs = {
		text = {
			[vim.diagnostic.severity.ERROR] = " ",
			[vim.diagnostic.severity.WARN] = " ",
			[vim.diagnostic.severity.INFO] = " ",
			[vim.diagnostic.severity.HINT] = " ",
		},
	},
	virtual_text = true, -- show inline diagnostics
})
