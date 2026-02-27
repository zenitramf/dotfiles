local cmp = require "cmp"

cmp.setup {
  sources = cmp.config.sources {
    { name = "copilot", group_index = 2 },
    { name = "nvim_lsp" },
    { name = "luasnip" },
    { name = "buffer" },
    { name = "path" },
  },
}
