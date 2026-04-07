local map = vim.keymap.set

require("config.mappings.code-actions")
require("config.mappings.flash")
require("config.mappings.oil")
require("config.mappings.opencode")
require("config.mappings.snacks")
require("config.mappings.tmux-nav")
require("config.mappings.trouble")

-- clear search highlights with <Esc>
map("n", "<Esc>", "<cmd>nohlsearch<CR>")

-- map("n", ";", ":", { desc = "CMD enter command mode" })

-- Select All
map("n", "<C-a>", "gg<S-v>G")

-- Close Buffer
-- map("n", "<leader>x", function()
-- 	local current = vim.api.nvim_get_current_buf()
-- 	local buffers = vim.fn.getbufinfo({ buflisted = 1 })
--
-- 	if #buffers > 1 then
-- 		vim.cmd("bnext")
-- 	else
-- 		vim.cmd("enew")
-- 	end
--
-- 	vim.cmd("bdelete " .. current)
-- end, { desc = "Close Buffer" })

-- Save (All Modes)
map({ "n", "i", "v" }, "<C-s>", "<cmd>w<CR>")

-- LazyGit
map("n", "<leader>gg", function()
	if vim.env.TMUX and vim.env.TMUX ~= "" then
		vim.fn.jobstart(
			{ "tmux", "popup", "-E", "-w", "90%", "-h", "90%", "-T", "LazyGit", "lazygit" },
			{ detach = true }
		)
		return
	end

	vim.cmd("LazyGit")
end, { desc = "LazyGit" })

-- Hover
map("n", "K", function()
	vim.lsp.buf.hover({
		border = "rounded",
		width = 100,
		max_height = 5,
		wrap = true,
		anchor_bias = "above",
	})
end, { desc = "LSP Hover" })
