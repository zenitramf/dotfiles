-- INFO: fuzzy finder
vim.pack.add({
	"https://github.com/nvim-lua/plenary.nvim",
	"https://github.com/nvim-tree/nvim-web-devicons",
	"https://github.com/folke/snacks.nvim",
	"https://github.com/folke/trouble.nvim",
}, { confirm = false })

require("trouble").setup()

local Snacks = require("snacks")

Snacks.setup({
	bigfile = { enabled = false },
	dashboard = { enabled = false },
	explorer = { enabled = false },
	indent = {},
	input = {},
	picker = {
		enabled = true,
		layout = "dropdown",
		actions = vim.tbl_extend("force", require("trouble.sources.snacks").actions, {
			opencode_send = function(...)
				return require("opencode").snacks_picker_send(...)
			end,
		}),
		win = {
			input = {
				keys = {
					["<C-t>"] = {
						"trouble_open",
						mode = { "n", "i" },
					},
					["<C-o>"] = {
						"opencode_send",
						mode = { "n", "i" },
					},
				},
			},
		},
	},
	terminal = {},
	notifier = {},
	quickfile = { enabled = false },
	scope = { enabled = false },
	scroll = { enabled = false },
	statuscolumn = { enabled = false },
	words = { enabled = false },
	zen = {},
})
