vim.pack.add({ "https://github.com/pablopunk/pi.nvim", "https://github.com/rcarriga/nvim-notify" })

require("pi").setup({
	provider = "openai-codex",
	model = "openai-codex/gpt-5.4",
	thinking = "off", -- be careful, thinking is time-consuming, it's not a great experience if you want simplicity
	skills = true,
	extensions = true,
})
