vim.pack.add({
	{
		src = "https://github.com/nvim-treesitter/nvim-treesitter",
		version = "main",
	},
}, { confirm = false })

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

vim.api.nvim_create_autocmd("FileType", {
	pattern = { "*" },
	callback = function(args)
		local ft = vim.bo[args.buf].filetype

		-- Disable treesitter for CSV
		if ft == "csv" then
			return
		end

		local lang = vim.treesitter.language.get_lang(ft)

		if not vim.treesitter.language.add(lang) then
			local available = vim.g.ts_available or require("nvim-treesitter").get_available()
			if not vim.g.ts_available then
				vim.g.ts_available = available
			end
			if vim.tbl_contains(available, lang) then
				require("nvim-treesitter").install(lang)
			end
		end

		if vim.treesitter.language.add(lang) then
			vim.treesitter.start(args.buf, lang)
			vim.wo[0][0].foldexpr = "v:lua.vim.treesitter.foldexpr()"
			vim.wo[0][0].foldmethod = "expr"
		end
	end,
})
