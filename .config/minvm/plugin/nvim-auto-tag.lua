vim.pack.add({ "https://github.com/windwp/nvim-ts-autotag" }, { confirm = false })

require("nvim-ts-autotag").setup({
	per_file = {
		html = true,
		javascript = {
			enable = true,
			filetypes = { "javascript", "typescript", "javascriptreact", "typescriptreact" },
		},
		svelte = true,
		vue = true,
		xml = true,
		php = true,
		jsx = true,
	},
})
