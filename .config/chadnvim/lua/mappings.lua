require "nvchad.mappings"

local map = vim.keymap.set
local prefix = "<Leader>"
local unmap = vim.keymap.del

-- Escapes for visual and insert
map({ "i", "v" }, "jk", "<ESC>")
map({ "i" }, "jj", "<ESC>")

-- Remove keymapping for close buffer
unmap({ "n" }, prefix .. "x")

require("which-key").add {
  { prefix .. "c", group = "[c]had" },
  { prefix .. "f", group = "[f]ind" },
  { prefix .. "d", group = "[d]iagnostic" },
  { prefix .. "m", group = "[m]arks" },
  { prefix .. "x", group = "trouble" },
  {
    prefix .. "wq",
    function()
      local choice = vim.fn.confirm "Are you sure you want to save and quit?"
      if choice == 1 then
        vim.cmd "wqall"
      else
        print "File not saved"
      end
    end,
    mode = { "n", "v" },
    desc = "save file and quit",
  },
  { prefix .. "ww", "<cmd>w<CR>", mode = { "n", "v" }, desc = "save file" },
  { prefix .. "O", "<cmd>Oil<CR>", mode = { "n" }, desc = "oil file explorer" },
  {
    prefix .. "fc",

    function()
      require("telescope.builtin").find_files {
        cwd = vim.fn.stdpath "config",
        prompt_title = "Config Files",
        follow = true,
      }
    end,
    desc = "telescope find nvim config",
  },
  {
    "s",
    function()
      require("hop").hint_char2()
    end,
    mode = { "n" },
    desc = "nvim-hop char2",
  },
  {
    prefix .. "xx",
    "<cmd>Trouble diagnostics toggle<CR>",
    desc = "Diagnostics (Trouble)",
  },
  {
    prefix .. "xX",
    "<cmd>Trouble diagnostics toggle filter.buf=0<CR>",
    desc = "Buffer Diagnostics (Trouble)",
  },
  {
    prefix .. "xQ",
    "<cmd>Trouble qflist toggle<CR>",
    desc = "Quickfix List (Trouble)",
  },
  {
    prefix .. "xL",
    "<cmd>Trouble loclist toggle<CR>",
    desc = "Location List (Trouble)",
  },
  {
    prefix .. "cs",
    "<cmd>Trouble symbols toggle focus=false<cr>",
    desc = "Symbols (Trouble)",
  },
  {
    prefix .. "e",
    "<cmd>Oil --float<CR>",
    desc = "oil float window",
  },
  {
    prefix .. "rr",
    "<cmd>ExecutorRun<CR>",
    desc = "Run Code",
  },
  {
    prefix .. "rd",
    "<cmd>ExecutorShowDetail<CR>",
    desc = "Show Results",
  },
  {
    prefix .. "rs",
    "<cmd>ExecutorSwapToSplit<CR>",
    desc = "Swap to Split Type",
  },
  {
    prefix .. "rp",
    "<cmd>ExecutorSwapToPopup",
    desc = "Swap to Popup Type",
  },
}
