local ctrlo = vim.api.nvim_replace_termcodes("<C-o>", true, true, true)
vim.fn.setreg("y", "gg0vGy" .. ctrlo)
