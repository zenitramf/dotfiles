local map = vim.keymap.set

map('n', ';', ':', { desc = 'CMD enter command mode' })
map('i', 'jk', '<ESC>')

-- Terminal window navigation with Ctrl + h/j/k/l
map('t', '<C-h>', [[<C-\><C-n><C-w>h]], { noremap = true, silent = true })
map('t', '<C-j>', [[<C-\><C-n><C-w>j]], { noremap = true, silent = true })
map('t', '<C-k>', [[<C-\><C-n><C-w>k]], { noremap = true, silent = true })
map('t', '<C-l>', [[<C-\><C-n><C-w>l]], { noremap = true, silent = true })

-- Buffer navigation with Shift + h/l
map('n', '<S-h>', '<cmd> bprev <cr>', { desc = 'Previous buffer' })
map('n', '<S-l>', '<cmd> bnext <cr>', { desc = 'Next buffer' })

-- Code action shortcut
map({ 'n', 'x' }, '<leader>ca', function()
  require('tiny-code-action').code_action()
end, { noremap = true, silent = true, desc = 'Code Action' })

map({ 'n', 'i', 'v' }, '<C-s>', '<cmd> w <cr>')

map('n', '<leader>qq', function()
  vim.cmd 'confirm qa'
end, { noremap = true, silent = true, desc = 'Confirm quit all' })

map('n', 'zR', require('ufo').openAllFolds, { desc = 'Open all Folds' })
map('n', 'zM', require('ufo').closeAllFolds, { desc = 'Close all Folds' })
map('n', 'zK', function()
  local winid = require('ufo').peekFoldedLinesUnderCursor()
  if not winid then
    vim.lsp.buf.hover()
  end
end, { desc = 'Peek Fold' })

-- Atone Undo Toggle
map('n', '<leader>uu', '<cmd> Atone toggle <cr>', { desc = 'Atone Undo Toggle' })

-- Snacks Terminal
local Snacks = require 'snacks'
local termOpts = { start_insert = false }

map({ 'n', 't' }, '<C-t>', function()
  Snacks.terminal.toggle(null, termOpts)
end, { desc = 'Terminal' })

map('t', '<C-n>', function()
  local opts = { start_insert = false }
  Snacks.terminal.open(null, termOpts)
end, { desc = 'Terminal' })

map('n', '<leader>tt', function()
  Snacks.terminal.toggle(null, termOpts)
end, { desc = 'Terminal' })

-- Snacks Zen
map('n', '<leader>z', function()
  Snacks.zen()
end, { desc = 'Toggle Zen Mode' })

-- Hover
map('n', 'K', function()
  require('hover').open()
end, { desc = 'Hover' })
map('n', 'gK', function()
  require('hover').enter()
end, { desc = 'hover.nvim (enter)' })

map('n', '<C-p>', function()
  require('hover').switch 'previous'
end, { desc = 'hover.nvim (previous source)' })

map('n', '<C-n>', function()
  require('hover').switch 'next'
end, { desc = 'hover.nvim (next source)' })

-- Snacks Dim
map('n', '<leader>ud', function()
  if Snacks.dim.enabled then
    Snacks.dim.disable()
    return
  end
  Snacks.dim.enable()
end, { desc = 'Toggle Dim Mode' })

-- Buffer delete

map('n', '<leader>bd', function()
  Snacks.bufdelete()
end, { desc = 'Delete Buffer' })

-- Snacks Dashboard
map('n', '<leader>d', function()
  Snacks.dashboard()
end, { desc = 'Open Dashboard' })

-- Select All
map('n', '<C-a>', 'gg<S-v>G')
