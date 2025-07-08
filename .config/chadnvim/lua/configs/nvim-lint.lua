local lint = require "lint"
lint.linters_by_ft = {
  javascript = { "oxlint" },
  typescript = { "oxlint" },
  python = { "ruff" },
}

vim.api.nvim_create_autocmd({ "BufEnter", "BufWritePost", "BufReadPost", "InsertLeave" }, {
  callback = function()
    lint.try_lint()
  end,
})
