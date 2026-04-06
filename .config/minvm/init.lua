-- NVIM options
require("config.options")
--
-- local function require_all(dir)
-- 	local path = vim.fn.stdpath("config") .. "/lua/" .. dir
-- 	local handle = vim.loop.fs_scandir(path)
-- 	if not handle then
-- 		return
-- 	end
--
-- 	while true do
-- 		local name, type = vim.loop.fs_scandir_next(handle)
-- 		if not name then
-- 			break
-- 		end
--
-- 		if type == "file" and name:match("%.lua$") then
-- 			require(dir .. "." .. name:gsub("%.lua$", ""))
-- 		end
-- 	end
-- end
-- require_all("plugins")
--
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
