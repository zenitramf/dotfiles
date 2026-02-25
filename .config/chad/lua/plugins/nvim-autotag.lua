local spec = {
  "windwp/nvim-ts-autotag",
  event = "VeryLazy",
  config = function()
    require("nvim-ts-autotag").setup {
      per_file = {
        html = true,
        javascript = {
          enable = true,
          filetypes = { "javascript", "typescript", "javascriptreact", "typescriptreact" },
        },
        svelte = true,
        vue = true,
        xml = true,
        php = true,
        jsx = true,
      },
    }
  end,
}
return spec
