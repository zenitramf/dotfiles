local wk = require "which-key"
---@class wk.Opts
local options = {
  preset = "helix",
  ---@type wk.Spec
  spec = {},
  icons = {
    ---@type wk.IconRule[]|false
    rules = {
      {
        plugin = "oil.nvim",
        pattern = "oil",
        icon = "󰏇",
        color = "green",
      },
      {
        pattern = "whichkey",
        icon = "󰌆",
        color = "azure",
      },
    },
  },
}
return options
