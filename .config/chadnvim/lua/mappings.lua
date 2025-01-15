require "nvchad.mappings"

-- add yours here

local map = vim.keymap.set
local prefix = "<Leader>"

map("n", ";", ":", { desc = "CMD enter command mode" })
map("i", "jk", "<ESC>")

-- Oil NVIM
map("n", prefix .. "O", "<cmd>Oil<CR>", {desc = "Oil File Explorer"})

-- map({ "n", "i", "v" }, "<C-s>", "<cmd> w <cr>")
