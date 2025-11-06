require "nvchad.mappings"

-- add yours here

local map = vim.keymap.set

map("n", ";", ":", { desc = "CMD enter command mode" })
map("i", "jk", "<ESC>")

-- Terminal window navigation with Ctrl + h/j/k/l
map("t", "<C-h>", [[<C-\><C-n><C-w>h]], { noremap = true, silent = true })
map("t", "<C-j>", [[<C-\><C-n><C-w>j]], { noremap = true, silent = true })
map("t", "<C-k>", [[<C-\><C-n><C-w>k]], { noremap = true, silent = true })
map("t", "<C-l>", [[<C-\><C-n><C-w>l]], { noremap = true, silent = true })

-- Buffer navigation with Shift + h/l
map("n", "<S-h>", "<cmd> bnext <cr>", { desc = "Previous buffer" })
map("n", "<S-l>", "<cmd> bprev <cr>", { desc = "Next buffer" })

-- Tmux pane navigation with Ctrl + h/j/k/l
map("n", "<C-h>", "<cmd>TmuxNavigateLeft<cr>", { desc = "Navigate to left tmux pane" })
map("n", "<C-j>", "<cmd>TmuxNavigateDown<cr>", { desc = "Navigate to below tmux pane" })
map("n", "<C-k>", "<cmd>TmuxNavigateUp<cr>", { desc = "Navigate to above tmux pane" })
map("n", "<C-l>", "<cmd>TmuxNavigateRight<cr>", { desc = "Navigate to right tmux pane" })
map("n", "<C-\\>", "<cmd>TmuxNavigatePrevious<cr>", { desc = "Navigate to previous tmux pane" })

-- Code action shortcut
map({ "n", "x" }, "<leader>ca", function()
  require("tiny-code-action").code_action()
end, { noremap = true, silent = true, desc = "Code Action" })

-- map({ "n", "i", "v" }, "<C-s>", "<cmd> w <cr>")

map("n", "<leader>qq", function()
  vim.cmd "confirm qa"
end, { noremap = true, silent = true, desc = "Confirm quit all" })

-- Use this for removing keymaps
local removeMap = vim.keymap.del
-- Remove default Tab and Shift-Tab mappings in normal mode

removeMap("n", "<Tab>")
removeMap("n", "<S-Tab>")
