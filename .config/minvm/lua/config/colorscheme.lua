local nightfox = function()
	vim.pack.add({ "https://github.com/EdenEast/nightfox.nvim" })
	require("nightfox").setup({
		options = {
			transparent = false,
		},
		palettes = {
			carbonfox = {
				transparent = true,
				bg0 = "#0A0E14",
				bg1 = "#0A0E14",
				bg2 = "#0A0E14",
				bg3 = "#0A0E14",
				-- bg4 = "#0A0E14",
				fg0 = "#B3B1AD",
				fg1 = "#B3B1AD",
				fg2 = "#B3B1AD",
				fg3 = "#B3B1AD",
				-- sel0 = "#0A0E14",
				-- sel1 = "#0A0E14",
				-- comment = ""
			},
		},
	})
end

local kanagawa = function()
	vim.pack.add({ "https://github.com/rebelot/kanagawa.nvim" })
	require("kanagawa").setup({
		transparent = false,
		colors = {
			theme = {

				all = {
					ui = {
						bg_gutter = "none",
					},
				},
			},
		},
	})
end

kanagawa()

local cyberdream = function()
	vim.pack.add({ "https://github.com/scottmckendry/cyberdream.nvim" })
	require("cyberdream").setup({
		transparent = false,
	})
end

vim.cmd("colorscheme kanagawa")
