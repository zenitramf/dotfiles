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

-- Terminal window navigation with Ctrl + h/j/k/l
map("t", "<C-h>", [[<C-\><C-n><C-w>h]], { noremap = true, silent = true })
map("t", "<C-j>", [[<C-\><C-n><C-w>j]], { noremap = true, silent = true })
map("t", "<C-k>", [[<C-\><C-n><C-w>k]], { noremap = true, silent = true })
map("t", "<C-l>", [[<C-\><C-n><C-w>l]], { noremap = true, silent = true })

-- Buffer navigation with Shift + h/l
map("n", "<S-h>", "<cmd> bprev <cr>", { desc = "Previous buffer" })
map("n", "<S-l>", "<cmd> bnext <cr>", { desc = "Next buffer" })

-- Select All
map("n", "<C-a>", "gg<S-v>G")
