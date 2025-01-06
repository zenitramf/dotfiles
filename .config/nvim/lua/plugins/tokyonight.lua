-- if true then return {} end
---@type LazySpec
return {
  "folke/tokyonight.nvim",
  priority = 1000,
  ---@class tokyonight.Config
  opts = {
    style = "moon",
    transparent = true,
    lualine_bold = false,
    dim_inactive = true,
  },
}
