local options = {
  formatters = {
    oxlint_fix = {
      command = "oxlint",
      args = {
        "--fix",
        "--quiet",
        "$FILENAME",
      },
      stdin = false, -- IMPORTANT: oxlint works on files, not stdin
      exit_codes = { 0, 1 },
    },
  },
  formatters_by_ft = {
    lua = { "stylua" },
    javascript = { "oxlint_fix", "prettier" },
    javascriptreact = { "oxlint_fix", "prettier" },
    ["javascript.jsx"] = { "oxlint_fix", "prettier" },
    typescript = { "oxlint_fix", "prettier" },
    typescriptreact = { "oxlint_fix", "prettier" },
    ["typescript.tsx"] = { "oxlint_fix", "prettier" },
    svelte = { "oxlint_fix", "prettier" },
    css = { "oxlint_fix", "prettier" },
    html = { "oxlint_fix", "prettier" },
    astro = { "oxlint_fix", "prettier" },
    markdown = { "markdownlint" },
    json = { "prettier" },

    -- Conform can also run multiple formatters sequentially
    -- python = { "isort", "black" },
    --
    -- You can use 'stop_after_first' to run the first available formatter from the list
    -- javascript = { "oxfmt", "prettier", stop_after_first = true },
  },

  format_on_save = {
    -- These options will be passed to conform.format()
    timeout_ms = 1000,
    lsp_fallback = true,
  },
}

return options
