local oil = {
  'stevearc/oil.nvim',
  config = function()
    local oil = require 'oil'
    oil.setup {
      default_file_explorer = true,
      skip_confirm_for_simple_edits = true,
      columns = {
        'icon',
      },
      keymaps = {
        gs = {
          callback = function()
            -- get the current directory
            local prefills = { paths = oil.get_current_dir() }

            local grug_far = require 'grug-far'
            -- instance check
            if not grug_far.has_instance 'explorer' then
              grug_far.open {
                instanceName = 'explorer',
                prefills = prefills,
                staticTitle = 'Find and Replace from Explorer',
              }
            else
              grug_far.get_instance('explorer'):open()
              -- updating the prefills without clearing the search and other fields
              grug_far.get_instance('explorer'):update_input_values(prefills, false)
            end
          end,
          desc = 'oil: Search in directory',
        },
      },
      win_options = {
        wrap = false,
        signcolumn = 'no',
        cursorcolumn = false,
        foldcolumn = '0',
        spell = false,
        list = false,
        conceallevel = 3,
        concealcursor = 'nvic',
      },
      watch_for_changes = true,
      show_hidden = true,
    }
  end,
  event = 'VeryLazy',
  cmd = 'Oil',
  dependencies = { 'nvim-tree/nvim-web-devicons' },
  keys = {
    {
      '<leader>e',
      function()
        require('oil').open()
      end,
      desc = 'Open parent directory',
    },
  },
}

local oil_diag = {
  'JezerM/oil-lsp-diagnostics.nvim',
  dependencies = { 'stevearc/oil.nvim' },
  opts = {},
}

return { oil, oil_diag }
