local options = {
  formatters_by_ft = {
    lua = { "stylua" },
    javascript = { "biome", "biome-check", "biome-organize-imports" },
    javascriptreact = { "biome", "biome-check", "biome-organize-imports" },
    ["javascript.jsx"] = { "biome", "biome-check", "biome-organize-imports" },
    typescript = { "biome", "biome-check", "biome-organize-imports" },
    typescriptreact = { "biome", "biome-check", "biome-organize-imports" },
    ["typescript.tsx"] = { "biome", "biome-check", "biome-organize-imports" },
    -- css = { "prettier" },
    -- html = { "prettier" },
  },

  format_on_save = {
    -- These options will be passed to conform.format()
    timeout_ms = 500,
    lsp_fallback = true,
  },
}

return options
