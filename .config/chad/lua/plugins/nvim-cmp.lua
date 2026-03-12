return {
  {
    "hrsh7th/nvim-cmp",
    config = function(_, opts)
      local cmp = require "cmp"

      opts.preselect = cmp.PreselectMode.None
      opts.completion = {
        completeopt = "menu,menuone,noselect",
      }

      opts.mapping = cmp.mapping.preset.insert {
        ["<C-b>"] = cmp.mapping.scroll_docs(-4),
        ["<C-f>"] = cmp.mapping.scroll_docs(4),
        ["<C-Space>"] = cmp.mapping.complete(),
        ["<C-@>"] = cmp.mapping.complete(),
        ["<C-e>"] = cmp.mapping.abort(),
        ["<CR>"] = cmp.mapping.confirm { select = false },
      }

      opts.sources = cmp.config.sources {
        { name = "copilot", group_index = 2 },
        { name = "nvim_lsp" },
        { name = "path" },
        { name = "vim-dadbod-completion" },
        { name = "luasnip" },
        { name = "buffer" },
      }

      cmp.setup(opts)
    end,
  },
}
