-- if true then return {} end
local prefix = "<Leader>v"

local keyMap = function(vault, command)
  vim.cmd("ObsidianWorkspace " .. vault)
  vim.cmd(command)
end

local work = "Work"
local personal = "Personal"

return {
  "epwalsh/obsidian.nvim",
  event = "VeryLazy",
  dependencies = {
    "nvim-lua/plenary.nvim",
    "hrsh7th/nvim-cmp",
    "nvim-telescope/telescope.nvim",
  },
  opts = {
    workspaces = {
      {
        name = "Personal",
        path = "/mnt/c/Users/marti/Obsidian/ZenitramF_Personal",
      },
      {
        name = "Work",
        path = "/mnt/c/Users/marti/Obsidian/Cyberleaf-Dev",
      },
    },
    mappings = {
      ["fo"] = {
        action = function() return require("obsidian").util.gf_passthrough() end,
        opts = { noremap = false, expr = true, buffer = true },
      },
      -- Smart action depending on context, either follow link or toggle checkbox.
      ["<cr>"] = {
        action = function() return require("obsidian").util.smart_action() end,
        opts = { buffer = true, expr = true },
      },
    },
    preferred_link_style = "markdown",
    --- @param url string
    follow_url_func = function(url) vim.ui.open(url) end,
    follow_img_func = function(img)
      -- vim.fn.jobstart { "qlmanage", "-p", img } -- Mac OS quick look preview
      vim.fn.jobstart { "wslview", img } -- linux
      -- vim.cmd(':silent exec "!start ' .. url .. '"') -- Windows
    end,
  },
  specs = {
    {
      "AstroNvim/astroui",
      ---@type AstroUIOpts
      opts = {
        icons = {
          Obsidian = "",
          Personal = "",
          Work = "",
        },
      },
    },
    {
      "AstroNvim/astrocore",
      opts = function(_, opts)
        local maps = opts.mappings
        maps.n[prefix] = {
          desc = require("astroui").get_icon("Obsidian", 1, true) .. "Vault",
        }
        maps.n[prefix .. "W"] = {
          "<cmd>ObsidianWorkspace<CR>",
          desc = "Switch Workspaces",
        }
        maps.n[prefix .. "T"] = {
          "<cmd>ObsidianTemplate<CR>",
          desc = "Insert a template from Templates Folder",
        }
        maps.n[prefix .. "e"] = {
          "<cmd>ObsidianExtractNote<CR>",
          desc = "Extract Visually Selected Note to New Note and Link to it",
        }
        maps.n[prefix .. "t"] = {
          "<cmd>ObsidianTags<CR>",
          desc = "Picker List of All Tag Occurences",
        }
        maps.n[prefix .. "y"] = {
          function() keyMap(personal, "ObsidianToday") end,
          desc = "Open the Daily Note in the Personal Vault",
        }
        maps.n[prefix .. "r"] = {
          "<cmd>ObsidianRename<CR>",
          desc = "Rename Note of the Current Buffer",
        }
        maps.n[prefix .. "P"] = {
          "<cmd>ObsidianPasteImg<CR>",
          desc = "Paste Image from the Clipboard",
        }
        maps.n[prefix .. "pd"] = {
          function() keyMap(personal, "ObsidianDailies") end,
          desc = "Open Dailies from Personal Vault",
        }
        maps.n[prefix .. "w"] = {
          "<cmd>ObsidianWorkspace Work<CR>",
          desc = require("astroui").get_icon("Work", 1, true) .. "Work Notes",
        }
        maps.n[prefix .. "ws"] = {
          function() keyMap(work, "ObsidianSearch") end,
          desc = "Grep Search Work",
        }
        maps.n[prefix .. "wn"] = {
          function() keyMap(work, "ObsidianNew") end,
          desc = "New Work Note",
        }
        maps.n[prefix .. "wN"] = {
          function() keyMap(work, "ObsidianNewFromTemplate") end,
          desc = "New Work Note from Template",
        }
        maps.n[prefix .. "p"] = {
          "<cmd>ObsidianWorkspace Personal<CR>",
          desc = require("astroui").get_icon("Personal", 1, true) .. "Personal Notes",
        }
        maps.n[prefix .. "ps"] = {
          function() keyMap(personal, "ObsidianSearch") end,
          desc = "Grep Search Personal",
        }
        maps.n[prefix .. "pn"] = {
          function() keyMap(personal, "ObsidianNew") end,
          desc = "New Personal Note",
        }
        maps.n[prefix .. "pN"] = {
          function() keyMap(personal, "ObsidianNewFromTemplate") end,
          desc = "New Personal Note from Template",
        }
        maps.n[prefix .. "wq"] = {
          function() keyMap(work, "ObsidianQuickSwitch") end,
          desc = "Quick Switch Work Notes",
        }
        maps.n[prefix .. "pq"] = {
          function() keyMap(personal, "ObsidianQuickSwitch") end,
          desc = "Quick Switch Personal Notes",
        }
      end,
    },
  },
}
