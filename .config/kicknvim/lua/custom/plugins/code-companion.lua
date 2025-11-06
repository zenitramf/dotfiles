local spec = {
  'olimorris/codecompanion.nvim',
  event = 'VeryLazy',
  dependencies = { 'nvim-lua/plenary.nvim', 'nvim-treesitter/nvim-treesitter' },
  opts = {
    -- strategies = {
    --   chat = { adapter = "xai", model = "grok-4-fast-reasoning" },
    --   inline = { adapter = "xai", model = "grok-code-fast-1" },
    -- },
  },
}

return spec
