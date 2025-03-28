local prefix = "<Leader>"
---@type LazySpec
return {
  {
    "stevearc/oil.nvim",
    lazy = false,
    cmd = nil,
    ---@module 'oil'
    ---@type oil.SetupOpts
    opts = {
      default_file_explorer = true,
      skip_confirm_for_simple_edits = true,
      view_options = {
        show_hidden = true,
        is_always_hidden = function(name, _) return name == ".." or name == ".git" end,
      },
    },
    specs = {
      {
        "AstroNvim/astrocore",
        opts = function(_, opts)
          local maps = opts.mappings
          maps.n[prefix .. "e"] = {
            "<cmd>Oil --float<CR>",
          }
        end,
      },
    },
    -- Optional dependencies
    -- dependencies = { { "echasnovski/mini.icons", opts = {} } },
    dependencies = { "nvim-tree/nvim-web-devicons" }, -- use if prefer nvim-web-devicons
  },
}
