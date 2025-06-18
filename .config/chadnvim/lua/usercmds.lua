vim.api.nvim_create_user_command("RenameFilePrompt", function()
  vim.ui.input({ prompt = "New file name: ", default = vim.fn.expand "%" }, function(input)
    if input and input ~= "" and input ~= vim.fn.expand "%" then
      local old = vim.fn.expand "%"
      vim.cmd("saveas " .. input)
      vim.cmd("silent !rm " .. vim.fn.fnameescape(old))
      vim.cmd("bd " .. vim.fn.fnameescape(old))
    end
  end)
end, {})
