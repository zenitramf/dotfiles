local spec = {
  {
    'nvim-neo-tree/neo-tree.nvim',
    branch = 'v3.x',
    config = function()
      require('neo-tree').setup {
        window = {
          mappings = {
            ['e'] = function()
              vim.cmd 'Neotree focus filesystem'
            end,
            ['b'] = function()
              vim.cmd 'Neotree focus buffers'
            end,
            ['g'] = function()
              vim.cmd 'Neotree focus git_status'
            end,
            ['gi'] = function()
              vim.cmd 'Neogit diff'
            end,
          },
        },
      }
    end,
    dependencies = {
      'nvim-lua/plenary.nvim',
      'MunifTanjim/nui.nvim',
      'nvim-tree/nvim-web-devicons', -- optional, but recommended
    },
    lazy = false, -- neo-tree will lazily load itself
    keys = {
      -- { '<leader>e', '<cmd>Neotree toggle<cr>', desc = 'NeoTree Toggle' },
    },
  },
}

return spec
