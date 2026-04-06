-- NVIM options
require("config.options")

-- Keymap configuration
require("config.autocmds")
require("config.mappings")
require("config.colorscheme")
require("config.lsp")

vim.pack.add({
	"https://github.com/windwp/nvim-autopairs", -- auto pairs
	"https://github.com/folke/todo-comments.nvim", -- highlight TODO/INFO/WARN comments
}, { confirm = false })

require("nvim-autopairs").setup()
require("todo-comments").setup()

-- uncomment to enable automatic plugin updates
-- vim.pack.update()
