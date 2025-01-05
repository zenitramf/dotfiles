---@type LazySpec
return {
  "chrishrb/gx.nvim",
  init = function() vim.g.netrw_nogx = 1 end,
  cmd = { "Browse" },
  dependencies = { "nvim-lua/plenary.nvim" },
  opts = {
    open_browser_app = "wslview",
    handlers = {
      plugin = true,
      github = true,
      package_json = true,
      search = true,
    },
    handler_options = {
      search_engine = "google",
    },
  },
  specs = {
    {
      "AstroNvim/astrocore",
      opts = function(_, opts)
        local maps = opts.mappings
        maps.n["gx"] = {
          "<cmd>Browse<CR>",
          desc = "Open links using gx.nvim.",
        }
        maps.x["gx"] = {
          "<cmd>Browse<CR>",
          desc = "Open links using gx.nvim",
        }
      end,
    },
  },
}
