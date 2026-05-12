vim.pack.add({ "https://github.com/chipsenkbeil/distant.nvim" })

require("distant"):setup({
	["network.private"] = true,
})
