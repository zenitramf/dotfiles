local prefix = "<Leader>v"
local mapping_array = {}

---@type LazySpec
local generic = {
  n = {
    ["<S-Tab>"] = {
      "<cmd>bprev<CR>",
      desc = "Previous Buffer",
    },
    ["<Tab>"] = {
      "<cmd>bnext<CR>",
      desc = "Next Buffer",
    },
    [prefix .. "a"] = {
      function()
        local keys = vim.api.nvim_replace_termcodes("ggVGy<C-o>", true, false, true)
        vim.api.nvim_feedkeys(keys, "n", true)
      end,
      desc = "Select whole file and yank.",
    },
  },
}

---@type AstroCoreOpts
table.insert(mapping_array, generic)

---@type LazySpec
local mappings = {}

for _, maps in ipairs(mapping_array) do
  for k, v in pairs(maps) do
    if mappings[k] == nil then mappings[k] = {} end
    for key, value in pairs(v) do
      mappings[k][key] = value
    end
  end
end

return {
  "AstroNvim/astrocore",
  opts = function(_, opts)
    local maps = opts.mappings
    maps.o["aE"] = {
      function() vim.cmd "normal! ggVGy" end,
      desc = "Select whole file and yank.",
    }
    maps.n["<S-Tab>"] = {
      "<cmd>bprev<CR>",
      desc = "Previous Buffer",
    }
    maps.n["<Tab>"] = {
      "<cmd>bnext<CR>",
      desc = "Next Buffer",
    }
  end,
}
