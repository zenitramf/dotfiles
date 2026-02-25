local spec = {
  "rachartier/tiny-code-action.nvim",
  dependencies = {
    { "nvim-lua/plenary.nvim" },
  },
  event = "LspAttach",
  opts = {
    picker = "telescope",
    backend = "delta",
  },
}
return spec
