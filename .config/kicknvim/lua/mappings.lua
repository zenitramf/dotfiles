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

-- Use this for removing keymaps
-- local removeMap = vim.keymap.del
-- Remove default Tab and Shift-Tab mappings in normal mode
