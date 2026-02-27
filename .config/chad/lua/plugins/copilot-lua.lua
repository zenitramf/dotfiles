--@type NvPluginSpec
local spec = {
  "zbirenbaum/copilot.lua",
  event = { "InsertEnter" },
  cmd = { "Copilot" },
  opts = {
    panel = {
      enabled = false,
    },
    suggestion = {
      enabled = false,
    },
  },
}
return spec
