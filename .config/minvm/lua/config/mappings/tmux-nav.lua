local map = vim.keymap.set

-- TMUX Nav
map("n", "<C-h>", "<Cmd>TmuxNavigateLeft<CR>", { silent = true })
map("n", "<C-j>", "<Cmd>TmuxNavigateDown<CR>", { silent = true })
map("n", "<C-k>", "<Cmd>TmuxNavigateUp<CR>", { silent = true })
map("n", "<C-l>", "<Cmd>TmuxNavigateRight<CR>", { silent = true })

map("t", "<C-h>", [[<C-\><C-n><Cmd>TmuxNavigateLeft<CR>]], { silent = true })
map("t", "<C-j>", [[<C-\><C-n><Cmd>TmuxNavigateDown<CR>]], { silent = true })
map("t", "<C-k>", [[<C-\><C-n><Cmd>TmuxNavigateUp<CR>]], { silent = true })
map("t", "<C-l>", [[<C-\><C-n><Cmd>TmuxNavigateRight<CR>]], { silent = true })
