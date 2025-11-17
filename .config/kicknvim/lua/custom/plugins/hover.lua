local spec = {
  'lewis6991/hover.nvim',
  config = function()
    require('hover').config {
      providers = {
        'hover.providers.diagnostic',
        'hover.providers.lsp',
        'hover.providers.dap',
        'hover.providers.man',
        'hover.providers.dictionary',
        -- Optional, disabled by default:
        'hover.providers.gh',
        'hover.providers.gh_user',
        -- 'hover.providers.jira',
        'hover.providers.fold_preview',
        'hover.providers.highlight',
      },
      mouse_providers = {
        'hover.providers.lsp',
      },
      mouse_delay = 1000,
      preview_window = true,
    }
  end,
}

return spec
