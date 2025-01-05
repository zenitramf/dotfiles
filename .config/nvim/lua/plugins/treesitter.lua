-- Customize Treesitter

---@type LazySpec
return {
  "nvim-treesitter/nvim-treesitter",
  opts = {
    ensure_installed = {
      "lua",
      "vim",
      "python",
      "css",
      "html",
      "json",
      "go",
      "bash",
      "astro",
      "dockerfile",
      "http",
      "javascript",
      "markdown",
      "markdown_inline",
      "jsdoc",
      "comment",
      "yaml",
      "typescript",
      "toml",
      "tsx",
      -- add more arguments for adding more treesitter parsers
    },
  },
}
