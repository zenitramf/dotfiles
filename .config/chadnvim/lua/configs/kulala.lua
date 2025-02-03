local M = {}

M.opts = function()
  local opts = {}
  opts.display_mode = "float"
  opts.split_direction = "horizontal"
  opts.default_winbar_panes = { "body", "headers", "headers_body", "script_output" }
  opts.winbar = true
  return opts
end

M.config = function()
  local prefix = "<Leader>k"
  require("which-key").add {
    { prefix, group = "[k]ulala" },
    { prefix .. "r", "<cmd>lua require('kulala').run()<CR>", desc = "Execute Request Under Cursor" },
    { prefix .. "r", "<cmd>lua require('kulala').run()<CR>", desc = "Execute Request Under Cursor" },
    { prefix .. "e", "<cmd>lua require('kulala').set_selected_env()<CR>", desc = "Sets the selected environment." },
    { prefix .. "d", "<cmd>lua require('kulala').inspect()<CR>", desc = "View Parsed Request" },
    {
      prefix .. "s",
      "<cmd>lua require('kulala').show_stats()<CR>",
      desc = "Shows the statistics of the last run request.",
    },
  }
end

return M
