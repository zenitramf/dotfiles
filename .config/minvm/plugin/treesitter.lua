vim.pack.add({ "https://github.com/nvim-treesitter/nvim-treesitter" }, { confirm = false })

require("nvim-treesitter").setup({
	-- Directory to install parsers and queries to (prepended to `runtimepath` to have priority)
	install_dir = vim.fn.stdpath("data") .. "/site",
})

require("nvim-treesitter")
	.install({
		"vim",
		"lua",
		"vimdoc",
		"html",
		"css",
		"svelte",
		"javascript",
		"typescript",
		"python",
		"jq",
		"json",
		"bash",
		"tsx",
		"astro",
		"zsh",
		"fish",
		"just",
		"yaml",
		"json",
		"json5",
		"jq",
		"prisma",
	})
	:wait(3000000)
