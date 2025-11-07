-- Detect if current buffer is part of a Deno project
local function is_deno_project(bufnr)
  local root = vim.fs.root(bufnr or 0, { 'deno.json', 'deno.jsonc' })
  return root ~= nil
end

vim.lsp.config('stylua', {
  cmd = { 'stylua', '--lsp' },
  filetypes = { 'lua' },
  root_markers = { '.stylua.toml', 'stylua.toml', '.editorconfig' },
})

vim.lsp.config('ruff', {
  cmd = { 'ruff', 'server' },
  filetypes = { 'python' },
  root_markers = { 'pyproject.toml', 'ruff.toml', '.git' },
  settings = {},
})

-- Configure vtsls
vim.lsp.config('vtsls', {
  cmd = { 'vtsls', '--stdio' },
  init_options = {
    hostInfo = 'neovim',
  },
  filetypes = {
    'javascript',
    'javascriptreact',
    'javascript.jsx',
    'typescript',
    'typescriptreact',
    'typescript.tsx',
  },
  root_dir = function(bufnr, on_dir)
    -- skip if Deno project detected
    if is_deno_project(bufnr) then
      vim.schedule(function()
        vim.notify('[LSP] Skipping vtsls (Deno project detected)', vim.log.levels.INFO)
      end)
      return
    end

    -- otherwise, normal vtsls root detection
    local root_markers = {
      'package-lock.json',
      'yarn.lock',
      'pnpm-lock.yaml',
      'bun.lockb',
      'bun.lock',
      '.git',
    }
    local project_root = vim.fs.root(bufnr, root_markers) or vim.fn.getcwd()
    on_dir(project_root)
  end,
})

-- Configure denols
vim.lsp.config('denols', {
  cmd = { 'deno', 'lsp' },
  root_dir = function(bufnr, on_dir)
    local deno_root = vim.fs.root(bufnr, { 'deno.json', 'deno.jsonc' })
    if deno_root then
      on_dir(deno_root)
    end
  end,
  init_options = {
    lint = true,
    unstable = true,
  },
})

-- read :h vim.lsp.config for changing options of lsp servers

local map = vim.keymap.set

vim.api.nvim_create_autocmd('LspAttach', {
  callback = function(ev)
    local client = vim.lsp.get_client_by_id(ev.data.client_id)
    -- local buffer = ev.buf

    -- Enable LLM-based inline completion

    if client then
      if client:supports_method(vim.lsp.protocol.Methods.textDocument_inlineCompletion) then
        vim.opt.completeopt = { 'menu', 'menuone', 'noinsert', 'fuzzy', 'popup' }
        vim.lsp.inline_completion.enable(true)
        map('i', '<A-l>', function()
          if not vim.lsp.inline_completion.get() then
            return '<A-l>'
          end
        end, { expr = true, replace_keycodes = true, desc = 'Get the current inline completion' })
      end
    end
  end,
})
