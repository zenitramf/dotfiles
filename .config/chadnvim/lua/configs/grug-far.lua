local options = function(_, opts)
  require("grug-far").setup(opts)
  vim.api.nvim_create_autocmd("FileType", {
    pattern = "grug-far",
    callback = function()
      -- Map <Esc> to quit after ensuring we're in normal mode
      vim.keymap.set({ "i", "n" }, "<Esc>", "<Cmd>stopinsert | bd!<CR>", { buffer = true })
    end,
  })
end
return options
