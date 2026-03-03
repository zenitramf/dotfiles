local spec = {
  "hrsh7th/nvim-cmp",
  opts = function(_, opts)
    local cmp = require "cmp"

    -- Example: change sources order / add sources
    opts.sources = cmp.config.sources {
      { name = "copilot" },
      { name = "nvim_lsp" },
      { name = "path" },
      { name = "vim-dadbod-completion" },
      { name = "luasnip" },
      { name = "buffer" },
    }

    return opts
  end,
}

return spec
