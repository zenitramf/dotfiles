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
  -- { import = "nvchad.blink.lazyspec" },

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

  { -- optional cmp completion source for require statements and module annotations
    "hrsh7th/nvim-cmp",
    opts = function(_, opts)
      opts.sources = opts.sources or {}
      table.insert(opts.sources, {
        name = "lazydev",
        group_index = 0, -- set group index to 0 to skip loading LuaLS completions
      })
    end,
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

  {
    "echasnovski/mini.move",
    version = "*",
    opts = require "configs.mini-move",
    event = "VeryLazy",
  },

  {
    "mfussenegger/nvim-lint",
    event = { "BufWritePost", "BufReadPost", "BufEnter" },
    config = function()
      require "configs.nvim-lint"
    end,
  },

  {
    "kevinhwang91/nvim-ufo",
    dependencies = "kevinhwang91/promise-async",
    event = { "BufReadPost", "BufNewFile" },
    opts = require "configs.nvim-ufo",
  },
  {
    "AckslD/nvim-neoclip.lua",
    event = "BufEnter",
    dependencies = {
      { "nvim-telescope/telescope.nvim" },
    },
    opts = require "configs.neo-clip",
  },
  {
    "karb94/neoscroll.nvim",
    enabled = false,
    event = "VeryLazy",
    opts = {},
  },
  {
    "windwp/nvim-ts-autotag",
    event = "BufEnter",
    opts = {},
  },
  {
    "hedyhli/outline.nvim",
    event = "VeryLazy",
    cmd = { "Outline", "OutlineOpen" },
    opts = {},
  },
  {
    "echasnovski/mini.ai",
    event = "BufEnter",
    opts = {},
  },
  {
    "folke/snacks.nvim",
    priority = 1000,
    lazy = false,
    ---@type snacks.Config
    opts = {
      -- your configuration comes here
      -- or leave it empty to use the default settings
      -- refer to the configuration section below
      bigfile = { enabled = false },
      dashboard = { enabled = false },
      explorer = { enabled = false },
      indent = { enabled = true },
      input = { enabled = true },
      picker = { enabled = true },
      notifier = { enabled = true },
      quickfile = { enabled = true },
      scope = { enabled = true },
      scroll = { enabled = true },
      statuscolumn = { enabled = true },
      words = { enabled = true },
      rename = { enabled = false },
      zen = {
        enabled = true,
        toggles = {
          ufo = true,
          dim = true,
          git_signs = false,
          diagnostics = false,
          line_number = false,
          relative_number = false,
          signcolumn = false,
          indent = false,
        },
      },
    },
  },

  {
    "folke/trouble.nvim",
    event = "VeryLazy",
    cmd = { "Trouble", "TroubleToggle", "TodoTrouble" },
    dependencies = {
      {
        "folke/todo-comments.nvim",
        opts = {},
      },
    },
    opts = require "configs.trouble",
  },

  {
    "MagicDuck/grug-far.nvim",
    event = "VeryLazy",
    config = require "configs.grug-far",
  },
}
