-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here
--
vim.keymap.set("i", "jk", "<Esc>", { noremap = true, silent = true })

-- Switch to previous buffer
vim.keymap.set("n", "H", "<Cmd>bprevious<CR>", { desc = "Go to previous buffer" })

-- Switch to next buffer
vim.keymap.set("n", "L", "<Cmd>bnext<CR>", { desc = "Go to next buffer" })
