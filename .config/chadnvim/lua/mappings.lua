require "nvchad.mappings"

-- add yours here

local map = vim.keymap.set

map("n", ";", ":", { desc = "CMD enter command mode" })
map("i", "jk", "<ESC>")

map({ "n", "v" }, "<leader>q", "<cmd>qall<cr>", { desc = "Quit All" })
map({ "n", "v" }, "<leader>w", "<cmd>w<cr>", { desc = "Save File" })
map({ "n" }, "<leader>e", "<cmd>Oil --float<cr>", { desc = "Oil" })
map({ "n" }, "s", "<cmd>HopChar2<cr>")

local unmap = vim.keymap.del

unmap("n", "<leader>wk")
