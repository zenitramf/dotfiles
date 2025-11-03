if true then
  return {}
end
---@type NvPluginSpec
local spec = {
  "nvim-mini/mini.animate",
  event = "VeryLazy",
  version = "*",
  config = function()
    require("mini.animate").setup()
  end,
}

return spec
