local spec = {
  'rachartier/tiny-code-action.nvim',
  dependencies = {
    { 'nvim-lua/plenary.nvim' },
    {
      'folke/snacks.nvim',
      opts = {
        terminal = {},
      },
    },
  },
  event = 'LspAttach',
  opts = {
    picker = 'telescope',
    backend = 'difftastic',
  },
}
return spec
