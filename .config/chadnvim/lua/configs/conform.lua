local options = {
  formatters_by_ft = {
    lua = { "stylua" },
    css = { "prettierd" },
    html = { "prettierd" },
    typescript = { "prettierd" },
    javascript = { "prettierd" },
    json = { "prettierd" },
    ["typescript.tsx"] = { "prettierd" },
    typescriptreact = { "prettierd" },
    javascriptreact = { "prettierd" },
    ["javascript.jsx"] = { "prettierd" },
    python = {
      -- To fix auto-fixable lint errors.
      "ruff_fix",
      -- To run the Ruff formatter.
      "ruff_format",
      -- To organize the imports.
      "ruff_organize_imports",
    },
    markdown = { "prettierd" },
  },
  formatters = {
    ruff = {
      prepend_args = { "--quote-style=single" },
    },
  },
  format_on_save = {
    -- These options will be passed to conform.format()
    timeout_ms = 500,
    lsp_fallback = true,
  },
}

return options
