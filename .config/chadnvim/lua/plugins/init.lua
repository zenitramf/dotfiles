---@type LazySpec
return {
  {
    "folke/which-key.nvim",
    opts = require "configs.which-key",
  },
  {
    "stevearc/conform.nvim",
    event = "BufWritePre", -- uncomment for format on save
    opts = require "configs.conform",
  },

  {
    "nvim-tree/nvim-tree.lua",
    enabled = false,
  },

  {
    "stevearc/oil.nvim",
    lazy = false,
    cmd = nil,
    opts = require "configs.oil",
    dependencies = {
      "nvim-tree/nvim-web-devicons",
    },
  },

  {
    "neovim/nvim-lspconfig",
    config = function()
      require "configs.lspconfig"
    end,
  },

  {
    "nvim-treesitter/nvim-treesitter",
    opts = function()
      require "configs.nvim-treesitter"
    end,
  },
  {
    "smoka7/hop.nvim",
    version = "*",
    opts = require "configs.hop",
  },
  {
    "stevearc/dressing.nvim",
    opts = require "configs.dressing",
    enabled = true,
  },
  {
    "kylechui/nvim-surround",
    version = "*", -- Use for stability; omit to use `main` branch for the latest features
    event = "VeryLazy",
    enabled = true,
    config = function()
      require("nvim-surround").setup {}
    end,
  },
  {
    "echasnovski/mini.ai",
    version = "*",
    lazy = false,
    config = function()
      require("mini.ai").setup()
    end,
  },
  {
    "folke/trouble.nvim",
    opts = {},
    cmd = "Trouble",
  },
  {
    "kevinhwang91/nvim-ufo",
    event = "VeryLazy",
    dependencies = { { "kevinhwang91/promise-async", lazy = true } },
    opts = {},
    init = function()
      vim.o.foldcolumn = "1" -- '0' is not bad
      vim.o.foldlevel = 99 -- Using ufo provider need a large value, feel free to decrease the value
      vim.o.foldlevelstart = 99
      vim.o.foldenable = true
    end,
    config = function()
      require "configs.ufo"
    end,
  },
  {
    "google/executor.nvim",
    opts = {
      use_split = false,
    },
    dependencies = "MunifTanjim/nui.nvim",
    cmd = {
      "ExecutorRun",
      "ExecutorSetCommand",
      "ExecutorShowDetail",
      "ExecutorHideDetail",
      "ExecutorToggleDetail",
      "ExecutorSwapToSplit",
      "ExecutorSwapToPopup",
      "ExecutorToggleDetail",
      "ExecutorReset",
    },
  },
  {
    "mistweaverco/kulala.nvim",
    ft = "http",
    opts = require("configs.kulala").opts(),
    config = require("configs.kulala").config(),
  },
}
