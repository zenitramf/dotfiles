---@type LazySpec
return {
  {
    "rose-pine/neovim",
    opts = {
      styles = {
        transparency = true,
      },
    },
  },
  {
    "mvllow/modes.nvim",
    opts = {
      colors = {
        bg = "", -- Optional bg param, defaults to Normal hl group
        copy = "#f6c177",
        delete = "#eb6f92",
        insert = "#9ccfd8",
        visual = "#ebbcba",
      },
      line_opacity = 0.3,
    },
  },
  {
    "AstroNvim/astroui",
    ---@type AstroUIOpts
    opts = {
      colorscheme = "rose-pine-main",
    },
  },
}
