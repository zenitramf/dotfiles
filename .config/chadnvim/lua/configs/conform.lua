local options = {
  formatters_by_ft = {
    lua = { "stylua" },
    css = { "biomejs" },
    html = { "biomejs" },

    javascript = { "biomejs" },
    javascriptreact = { "biomejs" }, -- jsx
    typescript = { "biomejs" },
    typescriptreact = { "biomejs" }, -- tsx
  },

  format_on_save = {
    -- These options will be passed to conform.format()
    timeout_ms = 500,
    lsp_fallback = true,
  },
}

return options
