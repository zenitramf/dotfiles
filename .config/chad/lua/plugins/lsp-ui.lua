---@type NvPluginSpec
local spec = {
  "jinzhongjia/LspUI.nvim",
  event = "LspAttach",
  opts = {},
  config = function()
    require("LspUI").setup {
      -- config options go here
    }
  end,
}

return spec
