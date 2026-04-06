local map = vim.keymap.set
map({ "n" }, "<leader>ca", function()
	require("tiny-code-action").code_action()
end, { desc = "Code Action" })
