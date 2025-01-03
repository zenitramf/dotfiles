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
  -- { import = "astrocommunity.note-taking.obsidian-nvim" },
}
