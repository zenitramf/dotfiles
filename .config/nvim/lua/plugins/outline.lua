local prefix = "<Leader>f"
---@type LazySpec
return {
  "hedyhli/outline.nvim",
  event = "VeryLazy",
  cmd = { "Outline", "OutlineOpen" },
  opts = {},
  specs = {
    {
      "AstroNvim/astrocore",
      opts = function(_, opts)
        local maps = opts.mappings
        maps.n[prefix .. "l"] = {
          "<cmd>Outline<CR>",
          desc = "Outliner",
        }
      end,
    },
  },
}
