-- AstroCommunity: import any community modules here
-- We import this file in `lazy_setup.lua` before the `plugins/` folder.
-- This guarantees that the specs are processed before any user plugins.

---@type LazySpec
return {
  "AstroNvim/astrocommunity",
  { import = "astrocommunity.pack.lua" },
  -- import/override with your plugins folder
  { import = "astrocommunity.diagnostics.trouble-nvim" },
  { import = "astrocommunity.utility.hover-nvim" },
  { import = "astrocommunity.motion.nvim-surround" },
  { import = "astrocommunity.fuzzy-finder.telescope-zoxide" },
  { import = "astrocommunity.code-runner.executor-nvim" },
  { import = "astrocommunity.motion.mini-move" },
  -- { import = "astrocommunity.programming-language-support.rest-nvim" },
  { import = "astrocommunity.file-explorer.oil-nvim" },
  { import = "astrocommunity.motion.flash-nvim" },
  -- { import = "astrocommunity.indent.indent-blankline-nvim" },
  { import = "astrocommunity.indent.mini-indentscope" },
  -- { import = "astrocommunity.motion.hop-nvim" },
  { import = "astrocommunity.remote-development.distant-nvim" },
  { import = "astrocommunity.motion.mini-ai" },
  { import = "astrocommunity.pack.typescript-all-in-one" },
  -- { import = "astrocommunity.completion.copilot-lua-cmp" },
  -- { import = "astrocommunity.completion.copilot-cmp" },
  { import = "astrocommunity.pack.python-ruff" },
  { import = "astrocommunity.markdown-and-latex.render-markdown-nvim" },
  { import = "astrocommunity.pack.svelte" },
}
