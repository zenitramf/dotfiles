---@type LazySpec
local prefix = "<Leader>k"
return {
  "mistweaverco/kulala.nvim",
  ft = "http",
  opts = {
    default_winbar_panes = { "body", "headers", "headers_body", "script_output" },
    winbar = true,
  },
  specs = {
    {
      "AstroNvim/astroui",
      ---@type AstroUIOpts
      opts = {
        icons = { Kulala = "" },
      },
    },
    {
      "AstroNvim/astrocore",
      opts = function(_, opts)
        local maps = opts.mappings
        maps.n[prefix] = {
          desc = require("astroui").get_icon("Kulala", 1, true) .. "Kulala",
        }
        maps.n[prefix .. "r"] = {
          "<cmd>lua require('kulala').run()<CR>",
          desc = "Execute Request Under Cursor",
        }
        maps.n[prefix .. "a"] = {
          "<cmd>lua require('kulala').run_all()<CR>",
          desc = "Execute All Requests Under Cursor",
        }
        maps.n[prefix .. "i"] = {
          "<cmd>lua require('kulala').inspect()<CR>",
          desc = "View Parsed Request",
        }
        maps.n[prefix .. "S"] = {
          "<cmd>lua require('kulala').scratchpad()<CR>",
          desc = "Execute All Requests Under Cursor",
        }
        maps.n[prefix .. "c"] = {
          "<cmd>lua require('kulala').copy()<CR>",
          desc = "Copy request as CURL",
        }
        maps.n[prefix .. "C"] = {
          "<cmd>lua require('kulala').from_curl()<CR>",
          desc = "Parse the CURL command from the clipboard and write HTTP spec into buffer.",
        }
        maps.n[prefix .. " "] = {
          "<cmd>lua require('kulala').search()<CR>",
          desc = "Search for all named requests in the current buffer.",
        }
        maps.n[prefix .. "x"] = {
          "<cmd>lua require('kulala').close()<CR>",
          desc = "Closes Kulala window and the http buffer.",
        }
        maps.n[prefix .. "e"] = {
          "<cmd>lua require('kulala').set_selected_env()<CR>",
          desc = "Sets the selected environment.",
        }
        maps.n[prefix .. "E"] = {
          "<cmd>lua require('kulala').get_selected_env()<CR>",
          desc = "Returns the selected environment.",
        }
        maps.n[prefix .. "["] = {
          "<cmd>lua require('kulala').jump_prev()<CR>",
          desc = "Jump to previous request.",
        }
        maps.n[prefix .. "]"] = {
          "<cmd>lua require('kulala').jump_next()<CR>",
          desc = "Jump to next request.",
        }
        maps.n[prefix .. "t"] = {
          "<cmd>lua require('kulala').toggle_view()<CR>",
          desc = "Toggles between body and header.",
        }
        maps.n[prefix .. "R"] = {
          "<cmd>lua require('kulala').replay()<CR>",
          desc = "Replays the last request.",
        }
        maps.n[prefix .. "v"] = {
          "<cmd>lua require('kulala').show_stats()<CR>",
          desc = "Shows the statistics of the last run request.",
        }
      end,
    },
  },
}
