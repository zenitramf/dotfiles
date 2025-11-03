---@type NvPluginSpec
local spec = {
  "nvim-mini/mini.ai",
  event = "VeryLazy",
  version = "*",
  config = function()
    require("mini.ai").setup()
  end,
}

return spec
