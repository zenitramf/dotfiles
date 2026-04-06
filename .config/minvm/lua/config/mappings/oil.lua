local map = vim.keymap.set

map("n", "<leader>e", function()
  require("oil").open()
end, {desc = "Open parent directory"})


