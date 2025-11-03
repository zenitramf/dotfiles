---@type NvPluginSpec
local spec = {
  "nvim-mini/mini.surround",
  event = "VeryLazy",
  version = "*",
  config = function()
    require("mini.surround").setup()
  end,
}

return spec
