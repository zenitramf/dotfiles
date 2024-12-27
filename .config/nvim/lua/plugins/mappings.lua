---@type LazySpec

return {
  "AstroNvim/astrocore",
  ---@type AstroCoreOpts
  opts = {
    mappings = {
      n = {
        ["<Leader>rp"] = { "<cmd> w | !python %<CR>", desc = "Save and run python file. (Requires an environment.)" },
        ["<Leader>rn"] = { desc = "Run Node Commands. (Requires PNPM)" },
        ["<Leader>rnt"] = {
          "<cmd>!pnpm run test %<CR>",
          desc = "Save and run node file. (Requires Node test script.)",
        },
        ["<Leader>E"] = { desc = "Extras" },
        ["<Leader>O"] = {
          "<cmd>Oil<CR>",
          desc = "Launch Oil.",
        },
      },
    },
  },
}
