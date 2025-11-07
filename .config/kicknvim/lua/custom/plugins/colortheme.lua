local tokyo = { -- You can easily change to a different colorscheme.
  -- Change the name of the colorscheme plugin below, and then
  -- change the command in the config to whatever the name of that colorscheme is.
  --
  -- If you want to see what colorschemes are already installed, you can use `:Telescope colorscheme`.
  'folke/tokyonight.nvim',
  priority = 1000, -- Make sure to load this before all the other start plugins.
  config = function()
    ---@diagnostic disable-next-line: missing-fields
    require('tokyonight').setup {
      transparent = true,
      style = 'night',
      styles = {
        comments = { italic = false }, -- Disable italics in comments
      },
    }

    -- Load the colorscheme here.
    -- Like many other themes, this one has different styles, and you could load
    -- any other, such as 'tokyonight-storm', 'tokyonight-moon', or 'tokyonight-day'.
    vim.cmd.colorscheme 'tokyonight-night'
  end,
}
local kanagawa = {
  'rebelot/kanagawa.nvim',
  config = function()
    require('kanagawa').setup {
      transparent = true,
      dimInactive = true,
      globalStatus = true,
    }
    vim.cmd.colorscheme 'kanagawa-wave'
  end,
}

local github = {
  'projekt0n/github-nvim-theme',
  name = 'github-theme',
  lazy = false, -- make sure we load this during startup if it is your main colorscheme
  priority = 1000, -- make sure to load this before all the other start plugins
  config = function()
    require('github-theme').setup {
      options = {
        transparent = true,
        styles = {
          comments = 'italic', -- Disable italics in comments
          functions = 'bold',
        },
      },
    }

    vim.cmd 'colorscheme github_dark_default'
  end,
}

local gruvbox = {
  'ellisonleao/gruvbox.nvim',
  config = function()
    require('gruvbox').setup {
      transparent_mode = true,
    }
    vim.cmd.colorscheme 'gruvbox'
  end,
}

return gruvbox
