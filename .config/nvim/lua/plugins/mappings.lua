local mapping_array = {}

---@type LazySpec
local executor = {
  n = {
    ["<Leader>E"] = { desc = "Code Executor" },
    ["<Leader>Er"] = {
      "<cmd>ExecutorRun <CR>",
      desc = "Run code.",
    },
    ["<Leader>Ed"] = {
      "<cmd>ExecutorShowDetail <CR>",
      desc = "Run code show results.",
    },
    ["<Leader>Es"] = {
      "<cmd>ExecutorSwapToSplit<CR>",
      desc = "Swap to Split Type",
    },
    ["<Leader>Ep"] = {
      "<cmd>ExecutorSwapToPopup<CR>",
      desc = "Swap to Popup Type",
    },
  },
}

---@type LazySpec
local oil = {
  n = {
    ["<Leader>O"] = {
      "<cmd> Oil <CR>",
      desc = "Launch Oil.",
    },
  },
}

---@type AstroCoreOpts
table.insert(mapping_array, executor)
table.insert(mapping_array, oil)

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
  opts = {
    mappings = mappings,
  },
}
