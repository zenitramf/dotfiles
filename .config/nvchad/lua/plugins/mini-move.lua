---@type NvPluginSpec
local spec = {
  "nvim-mini/mini.move",
  event = "VeryLazy",
  version = "*",
  config = function()
    require("mini.move").setup()
  end,
}
return spec
