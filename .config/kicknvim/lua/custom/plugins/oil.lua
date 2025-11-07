local spec = {
  'stevearc/oil.nvim',
  config = function()
    require('oil').setup {
      default_file_explorer = true,
      skip_confirm_for_simple_edits = true,
    }
  end,
  event = 'VeryLazy',
  cmd = 'Oil',
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

return spec
