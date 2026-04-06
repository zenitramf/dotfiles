local map = vim.keymap.set
-- Opencode
map({ "n", "x" }, "<leader-ox>", function()
	require("opencode").select()
end, { desc = "Execute opencode action…" })

map({ "n", "x" }, "go", function()
	return require("opencode").operator("@this ")
end, { desc = "Add range to opencode", expr = true })

map("n", "goo", function()
	return require("opencode").operator("@this ") .. "_"
end, { desc = "Add line to opencode", expr = true })

map({ "n", "x" }, "goa", function()
	require("opencode").ask("@this: ", { submit = true })
end, { desc = "Ask opencode…" })
