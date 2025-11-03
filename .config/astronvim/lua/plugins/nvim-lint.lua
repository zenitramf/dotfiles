return {
  "mfussenegger/nvim-lint",
  opts = function(_, opts)
    -- merge instead of overwrite
    opts.linters_by_ft = vim.tbl_deep_extend("force", opts.linters_by_ft or {}, {
      javascript = { "biomejs" },
      javascriptreact = { "biomejs" },
      typescript = { "biomejs" },
      typescriptreact = { "biomejs" },
    })
  end,
  config = function(_, opts)
    local lint = require "lint"
    lint.linters_by_ft = opts.linters_by_ft

    -- Double-check linter registration (Astro loads custom modules early)
    -- if not lint.linters.biomejs then
    --   lint.linters.biomejs = {
    --     name = "biomejs",
    --     cmd = "biome",
    --     stdin = true,
    --     args = { "lint", "--stdin-file-path", "%filepath" },
    --     ignore_exitcode = true,
    --     parser = require("lint.parser").from_errorformat("%f:%l:%c %m", { source = "biomejs" }),
    --   }
    -- end
    --
    vim.api.nvim_create_autocmd(
      { "User", "BufReadPost", "BufAdd", "BufEnter", "BufWinEnter", "InsertLeave", "BufWrite", "TextChanged" },
      {
        callback = function() lint.try_lint() end,
      }
    )
  end,
}
