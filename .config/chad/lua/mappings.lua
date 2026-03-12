require "nvchad.mappings"

-- add yours here

local map = vim.keymap.set

map("n", ";", ":", { desc = "CMD enter command mode" })
map("i", "jk", "<ESC>")
map("n", "<leader>gf", ":Git<CR>", { desc = "Git Fugitive" })

-- Code action shortcut
map({ "n", "x" }, "<leader>cr", function()
  require("tiny-code-action").code_action()
end, { noremap = true, silent = true, desc = "Code Action" })

-- Terminal window navigation with Ctrl + h/j/k/l
map("t", "<C-h>", [[<C-\><C-n><C-w>h]], { noremap = true, silent = true })
map("t", "<C-j>", [[<C-\><C-n><C-w>j]], { noremap = true, silent = true })
map("t", "<C-k>", [[<C-\><C-n><C-w>k]], { noremap = true, silent = true })
map("t", "<C-l>", [[<C-\><C-n><C-w>l]], { noremap = true, silent = true })

-- Buffer navigation with Shift + h/l
map("n", "<S-h>", "<cmd> bprev <cr>", { desc = "Previous buffer" })
map("n", "<S-l>", "<cmd> bnext <cr>", { desc = "Next buffer" })

-- Select All
map("n", "<C-a>", "gg<S-v>G")

-- Tab Open on Space
map("n", "<leader><space>", "<cmd>Telescope buffers<CR>", { desc = "View Buffers (Telescope)" })

map("n", "<leader>x", "<cmd>bdelete<CR>", { desc = "Close Buffer" })

map("n", "<leader>fc", function()
  local builtin = require "telescope.builtin"
  builtin.find_files {
    cwd = vim.fn.stdpath "config",
    hidden = true,
  }
end, { desc = "Find Config Files (Telescope)" })

-- Opencode
map({ "n", "x" }, "<leader-ox>", function()
  require("opencode").select()
end, { desc = "Execute opencode action…" })

map({ "n", "x" }, "go", function()
  return require("opencode").operator "@this "
end, { desc = "Add range to opencode", expr = true })

map("n", "goo", function()
  return require("opencode").operator "@this " .. "_"
end, { desc = "Add line to opencode", expr = true })

map({ "n", "x" }, "goa", function()
  require("opencode").ask("@this: ", { submit = true })
end, { desc = "Ask opencode…" })

local function tmux_jump_to_opencode()
  if not vim.env.TMUX or vim.env.TMUX == "" then
    vim.notify("Not inside tmux ($TMUX not set)", vim.log.levels.WARN)
    return
  end

  -- target format: session:window.pane (e.g. work:3.1)
  local lines =
    vim.fn.systemlist [[tmux list-panes -a -F '#{session_name}:#{window_index}.#{pane_index} #{pane_current_command}']]
  if vim.v.shell_error ~= 0 then
    vim.notify("tmux list-panes failed", vim.log.levels.ERROR)
    return
  end

  local pane_target
  for _, line in ipairs(lines) do
    local target, cmd = line:match "^(%S+)%s+(%S+)$"
    if target and cmd == "opencode" then
      pane_target = target
      break
    end
  end

  if not pane_target then
    vim.notify("No opencode pane found in tmux session", vim.log.levels.WARN)
    return
  end

  local session, win = pane_target:match "^([^:]+):(%d+)%.%d+$"
  if not session or not win then
    vim.notify("Could not parse tmux target: " .. pane_target, vim.log.levels.ERROR)
    return
  end

  -- Switch to that session (if different), then window, then pane
  vim.fn.system { "tmux", "switch-client", "-t", session }
  vim.fn.system { "tmux", "select-window", "-t", session .. ":" .. win }
  vim.fn.system { "tmux", "select-pane", "-t", pane_target }
end

map({ "n", "x" }, "<leader>oj", tmux_jump_to_opencode, { desc = "Jump to opencode tmux pane" })

-- LSPUI
map({ "n" }, "<leader>ca", "<cmd>LspUI code_action<CR>")

-- Snacks Terminal

local Snacks = require "snacks"
local termOpts = { start_insert = false }

map({ "n", "t" }, "<C-/>", function()
  Snacks.terminal.toggle(null, termOpts)
end, { desc = "Terminal" })

map({ "n", "t" }, "<leader>h", function()
  Snacks.terminal.toggle(null, termOpts)
end, { desc = "Terminal" })

map("t", "<C-n>", function()
  local opts = { start_insert = false }
  Snacks.terminal.open(null, termOpts)
end, { desc = "Terminal" })
-- Snacks Zen
map("n", "<leader>z", function()
  Snacks.zen()
end, { desc = "Toggle Zen Mode" })

-- PI
map("n", "<leader>ai", ":PiAsk<CR>", { desc = "Ask pi" })

map("v", "<leader>ai", ":PiAskSelection<CR>", { desc = "Ask pi (selection)" })

-- LazyGit
map("n", "<leader>gg", function()
  if vim.env.TMUX and vim.env.TMUX ~= "" then
    vim.fn.jobstart({ "tmux", "popup", "-E", "-w", "90%", "-h", "90%", "-T", "LazyGit", "lazygit" }, { detach = true })
    return
  end

  vim.cmd "LazyGit"
end, { desc = "LazyGit" })
