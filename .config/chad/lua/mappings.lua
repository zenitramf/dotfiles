require "nvchad.mappings"

-- add yours here

local map = vim.keymap.set

map("n", ";", ":", { desc = "CMD enter command mode" })
map("i", "jk", "<ESC>")
map("n", "<leader>gf", ":Git<CR>", { desc = "Git Fugitive" })

-- Code action shortcut
map({ "n", "x" }, "<leader>ca", function()
  require("tiny-code-action").code_action()
end, { noremap = true, silent = true, desc = "Code Action" })

-- map({ "n", "i", "v" }, "<C-s>", "<cmd> w <cr>")
