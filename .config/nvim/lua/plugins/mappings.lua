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
  opts = {
    mappings = mappings,
  },
}
