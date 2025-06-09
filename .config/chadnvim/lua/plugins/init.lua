---@type Lazy
return {
  {
    "stevearc/conform.nvim",
    event = "BufWritePre", -- uncomment for format on save
    opts = require "configs.conform",
  },

  -- These are some examples, uncomment them if you want to see them work!
  -- {
  --   "neovim/nvim-lspconfig",
  --   config = function()
  --     require "configs.lspconfig"
  --   end,
  -- },

  -- test new blink
  { import = "nvchad.blink.lazyspec" },

  {
    "nvim-treesitter/nvim-treesitter",
    opts = {
      ensure_installed = {
        "vim",
        "lua",
        "vimdoc",
        "html",
        "css",
        "tsx",
        "typescript",
        "json",
        "javascript",
        "terraform",
        "markdown",
      },
    },
  },

  {
    "folke/lazydev.nvim",
    ft = "lua", -- only load on lua files
    opts = {
      library = {
        -- See the configuration section for more details
        -- Load luvit types when the `vim.uv` word is found
        { path = "${3rd}/luv/library", words = { "vim%.uv" } },
      },
    },
  },

  { -- optional blink completion source for require statements and module annotations
    "saghen/blink.cmp",
    opts = require "configs.blink",
  },

  {
    "stevearc/oil.nvim",
    lazy = false,
    cmd = nil,
    event = "VeryLazy",
    opts = require "configs.oil",
    specs = {},
    -- Optional dependencies
    -- dependencies = { { "echasnovski/mini.icons", opts = {} } },
    dependencies = { "nvim-tree/nvim-web-devicons" }, -- use if prefer nvim-web-devicons
  },
  {
    "nvim-tree/nvim-tree.lua",
    enabled = false,
  },
  {
    "folke/which-key.nvim",
    opts = require "configs.whichkey",
  },
  {
    "kylechui/nvim-surround",
    enabled = false,
  },
  {
    "echasnovski/mini.surround",
    version = "*",
    opts = "configs.mini-surround.lua",
    event = "BufEnter",
  },
  {
    "smoka7/hop.nvim",
    version = "*",
    opts = require "configs.hop",
    cmd = { "HopChar2", "HopNodes", "HopLine", "HopLineStart", "HopPattern" },
  },
}
