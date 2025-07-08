require "nvchad.mappings"

-- add yours here

local map = vim.keymap.set
map("i", "jk", "<ESC>")

map({ "n", "v" }, "<leader>q", "<cmd>qall<cr>", { desc = "Quit All" })
map({ "n", "v" }, "<leader><space>w", "<cmd>w<cr>", { desc = "Save File" })
map({ "n" }, "<leader>e", "<cmd>Oil --float<cr>", { desc = "Oil" })
map({ "n", "v" }, "s", "<cmd>HopChar2<cr>")
map({ "n" }, "<leader>fe", function()
  require("telescope.builtin").diagnostics { severity = vim.diagnostic.severity.ERROR }
end, { desc = "telescope find errors" })
map({ "n" }, "<leader>df", "<cmd>lua vim.diagnostic.open_float()<cr>", { desc = "LSP Diagnostic Hover" })
map({ "n" }, "<leader>fr", function()
  require("telescope").extensions.neoclip.default()
end, { desc = "Telescope Find Registers" })
map({ "n" }, "<leader>o", "<cmd>Outline<cr>", { desc = "Outliner" })
map({ "n" }, "<leader>uz", function()
  require("snacks").toggle.zen():toggle()
end, { desc = "Toggle Zen Mode" })
map({ "n" }, "<leader>rf", "<cmd>RenameFilePrompt<cr>", { desc = "Rename File" })
map({ "n" }, "<leader>fc", function()
  require("telescope.builtin").find_files {
    prompt_title = "Config Files",
    cwd = vim.fn.stdpath "config",
    follow = true,
  }
end, { desc = "Telescope NVIM Configs" })

map({ "n" }, "<leader>fC", function()
  require("snacks.picker").files {
    cwd = vim.fn.stdpath "config",
  }
end, { desc = "Picker Config Files" })

map({ "n" }, "<leader>tx", "<cmd>Trouble diagnostics toggle<cr>", { desc = "Toggle diagnostics" })
map(
  { "n" },
  "<leader>td",
  "<CMD>TodoTelescope keywords=TODO,FIX,FIXME,BUG,TEST,NOTE <CR>",
  { desc = "Toggle Todo/Fix/Fixme" }
)

map({ "n" }, "<leader>sr", function()
  local grug = require "grug-far"
  local ext = vim.bo.buftype == "" and vim.fn.expand "%:e"
  grug.open {
    transient = true,
    prefills = {
      filesFilter = ext and ext ~= "" and "*." .. ext or nil,
    },
  }
end, { desc = "Search and Replace" })

map({ "n" }, "grr", function()
  Snacks.picker.lsp_references()
end, { desc = "Find References" })

local unmap = vim.keymap.del

unmap("n", "<leader>wk")
unmap("n", "<M-h>")
