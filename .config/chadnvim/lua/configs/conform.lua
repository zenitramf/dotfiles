local options = {
  formatters_by_ft = {
    lua = { "stylua" },
    -- css = { "prettier" },
    -- html = { "prettier" },
    typescript = { "biome-check" },
    javascript = { "biome-check" },
    ["typescript.tsx"] = { "biome-check" },
    typescriptreact = { "biome-check" },
    javascriptreact = { "biome-check" },
    ["javascript.jsx"] = { "biome-check" },
    python = {
      -- To fix auto-fixable lint errors.
      "ruff_fix",
      -- To run the Ruff formatter.
      "ruff_format",
      -- To organize the imports.
      "ruff_organize_imports",
    },
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
