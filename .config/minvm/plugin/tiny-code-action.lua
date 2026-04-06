vim.pack.add({ "https://github.com/rachartier/tiny-code-action.nvim" })
require("tiny-code-action").setup({
	picker = "snacks",
	backend = "vim",
})
