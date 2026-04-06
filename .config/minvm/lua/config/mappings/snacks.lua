local map = vim.keymap.set
-- Tab Open on Space
map("n", "<leader><space>", function()
  Snacks.picker.buffers()
end, { desc = "View Buffers" })

-- Snacks File Open
map("n", "<leader>ff", function()
  Snacks.picker.files()
end, { desc = "View Files" })

-- Snacks File Open
map("n", "<leader>fb", function()
  Snacks.picker.files()
end, { desc = "View Files" })

-- Snacks Grep
map("n", "<leader>fw", function()
  Snacks.picker.grep()
end, { desc = "Grep in Files" })

-- Snacks Grep
map("n", "<leader>fz", function()
  Snacks.picker.grep_buffers()
end, { desc = "Grep in Buffers" })

-- Snacks File Open
map("n", "<leader>fo", function()
  Snacks.picker.recent()
end, { desc = "View Recent Files" })

-- Snacks  Git Status
map("n", "<leader>gt", function()
  Snacks.picker.git_status()
end, { desc = "Git Status" })

-- Snacks Git Diff
map("n", "<leader>gd", function()
  Snacks.picker.git_diff()
end, { desc = "Git Diff" })

-- Snacks Git Log Line
map("n", "<leader>gL", function()
  Snacks.picker.git_log_line()
end, { desc = "Git Log Line" })

-- Snacks Git Log
map("n", "<leader>gl", function()
  Snacks.picker.git_log()
end, { desc = "Git Log" })


-- Snacks Picker
  map( { "n", "v" },"<leader>gB", function()
      Snacks.gitbrowse()
    end,
    {desc = "Git Browse"})

-- Config
map("n", "<leader>fc", function()
  Snacks.picker.files {
    cwd = vim.fn.stdpath "config",
    hidden = true,
  }
end, { desc = "Find Config Files" })


