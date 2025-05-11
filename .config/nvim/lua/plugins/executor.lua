local prefix = "<Leader>r"
---@type LazySpec
return {
  "google/executor.nvim",
  opts = {
    use_split = false,
  },
  specs = {
    {
      "AstroNvim/astroui",
      ---@type AstroUIOpts
      opts = {
        icons = {
          Executor = " ",
        },
      },
    },

    {
      "AstroNvim/astrocore",
      opts = function(_, opts)
        local maps = opts.mappings
        maps.n[prefix] = { desc = require("astroui").get_icon("Executor", 1, true) .. "Code Executor" }
        maps.n[prefix .. "r"] = {
          "<cmd>ExecutorRun<CR>",
          desc = require("astroui").get_icon("Executor", 1, true) .. "Run Code",
        }
        maps.n[prefix .. "s"] = {
          "<cmd>ExecutorShowDetail<CR>",
          desc = "Show Results",
        }
        maps.n[prefix .. "d"] = {
          "<cmd>ExecutorSwapToSplit<CR>",
          desc = "Swap to Split Type",
        }
        maps.n[prefix .. "p"] = {
          "<cmd>ExecutorSwapToPopup",
          desc = "Swap to Popup Type",
        }
      end,
    },
  },
}
