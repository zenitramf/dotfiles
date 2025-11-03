---@type NvPluginSpec
local spec = {
  {
    "stevearc/oil.nvim",
    opts = {
      default_file_explorer = true,
      skip_confirm_for_simple_edits = true,
    },
    event = "VeryLazy",
    cmd = "Oil",
    keys = {
      {
        "<leader>e",
        function()
          require("oil").open()
        end,
        desc = "Open parent directory",
      },
    },
  },
}
return spec
