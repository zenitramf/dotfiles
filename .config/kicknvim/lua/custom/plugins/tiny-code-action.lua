local spec = {
  'rachartier/tiny-code-action.nvim',
  dependencies = {
    { 'nvim-lua/plenary.nvim' },
    {
      opts = {
        terminal = {},
      },
    },
  },
  event = 'LspAttach',
  opts = {
    picker = 'telescope',
    backend = 'delta',
  },
}
return spec
