if true then return {} end

---@type LazySpec
return {
  "lukas-reineke/indent-blankline.nvim",
  ---@module "ibl"
  ---@type ibl.config
  opts = {
    indent = {},
    whitespace = {},
    scope = {
      highlight = { "Function", "Label" },
    },
  },
}
