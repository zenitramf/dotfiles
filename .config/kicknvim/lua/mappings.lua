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
map('n', '<leader>u', '<cmd> Atone toggle <cr>', { desc = 'Atone Undo Toggle' })

local Snacks = require 'snacks'
-- Snacks Pickers
map('n', '<leader>sh', function()
  Snacks.picker.help()
end, { desc = 'Help Search' })

map('n', '<leader>sk', function()
  Snacks.picker.keymaps()
end, { desc = 'Keymaps Search' })

map('n', '<leader>sf', function()
  Snacks.picker.files()
end, { desc = 'Files Search' })

map('n', '<leader>ss', function()
  Snacks.picker()
end, { desc = 'Snacks Main Picker' })

map('n', '<leader>sw', function()
  Snacks.picker.grep_word()
end, { desc = 'Search Current Word' })

map('n', '<leader>/', function()
  Snacks.picker.grep()
end, { desc = 'Search Input String' })

map('n', '<leader>sd', function()
  Snacks.picker.diagnostics()
end, { desc = 'Diagnostics Search' })

map('n', '<leader>sr', function()
  Snacks.picker.resume()
end, { desc = 'Resume Last Picker' })

map('n', '<leader>s.', function()
  Snacks.picker.recent()
end, { desc = 'Recent Files Search' })

map('n', '<leader><leader>', function()
  Snacks.picker.buffers()
end, { desc = 'Buffers Search' })

map('n', '<leader>sc', function()
  Snacks.picker.files { cwd = vim.fn.stdpath 'config' }
end, { desc = 'Snacks Command Search' })

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

-- Buffer delete

map('n', '<leader>bd', function()
  Snacks.bufdelete()
end, { desc = 'Delete Buffer' })

-- Snacks Dashboard
map('n', '<leader>d', function()
  Snacks.dashboard()
end, { desc = 'Open Dashboard' })
