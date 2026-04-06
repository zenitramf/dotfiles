local map = vim.keymap.set

-- Flash
map({ "n", "x", "o" }, "s", function()
	require("flash").jump()
end, { desc = "Flash" })

-- Flash Treesitter
map({ "n", "x", "o" }, "S", function()
	require("flash").treesitter()
end, { desc = "Flash Treesitter" })

-- Remote Flash
map("o", "r", function()
	require("flash").remote()
end, { desc = "Remote Flash" })

-- Treesitter Search
map({ "o", "x" }, "R", function()
	require("flash").treesitter_search()
end, { desc = "Treesitter Search" })

-- Toggle Flash Search (command mode)
map("c", "<C-s>", function()
	require("flash").toggle()
end, { desc = "Toggle Flash Search" })
