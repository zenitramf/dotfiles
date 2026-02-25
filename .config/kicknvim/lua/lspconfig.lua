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

vim.lsp.config('lua_ls', {
  cmd = { 'lua-language-server' },
  filetypes = { 'lua' },
  root_markers = {
    '.luarc.json',
    '.luarc.jsonc',
    '.git',
  },
  settings = {
    Lua = {
      runtime = {
        version = 'LuaJIT',
      },
      diagnostics = {
        globals = { 'vim' }, -- fixes "undefined global 'vim'"
      },
      workspace = {
        checkThirdParty = false,
        library = {
          vim.env.VIMRUNTIME,
        },
      },
      telemetry = {
        enable = false,
      },
    },
  },
})

vim.lsp.config('unocss', {
  root_dir = function(bufnr, on_dir)
    local root = vim.fs.root(bufnr, {
      'uno.config.ts',
    })

    if root then
      on_dir(root)
    end
    -- If nil, LSP will NOT start
  end,
})

vim.lsp.config('tailwindcss', {
  root_dir = function(bufnr, on_dir)
    local root = vim.fs.root(bufnr, {
      'tailwind.config.ts',
      'tailwind.config.js',
    })

    if root then
      on_dir(root)
    end
  end,
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

-- Configure TSGO
vim.lsp.config('tsgo', {
  cmd = function(dispatchers, config)
    local cmd = 'tsgo'
    local local_cmd = (config or {}).root_dir and config.root_dir .. '/node_modules/.bin/tsgo'
    if local_cmd and vim.fn.executable(local_cmd) == 1 then
      cmd = local_cmd
    end
    return vim.lsp.rpc.start({ cmd, '--lsp', '--stdio' }, dispatchers)
  end,
  filetypes = {
    -- 'javascript',
    -- 'javascriptreact',
    -- 'javascript.jsx',
    -- 'typescript',
    -- 'typescriptreact',
    -- 'typescript.tsx',
  },
  root_dir = function(bufnr, on_dir)
    -- The project root is where the LSP can be started from
    -- As stated in the documentation above, this LSP supports monorepos and simple projects.
    -- We select then from the project root, which is identified by the presence of a package
    -- manager lock file.
    local root_markers = { 'package-lock.json', 'yarn.lock', 'pnpm-lock.yaml', 'bun.lockb', 'bun.lock' }
    -- Give the root markers equal priority by wrapping them in a table
    root_markers = vim.fn.has 'nvim-0.11.3' == 1 and { root_markers, { '.git' } } or vim.list_extend(root_markers, { '.git' })

    -- exclude deno
    if vim.fs.root(bufnr, { 'deno.json', 'deno.jsonc', 'deno.lock' }) then
      return
    end

    -- We fallback to the current working directory if no project root is found
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

-- local map = vim.keymap.set
--
-- -- Global toggle for inline completion
-- vim.g.inline_completion_enabled = true
--
-- vim.keymap.set('n', '<leader>ai', function()
--   vim.g.inline_completion_enabled = not vim.g.inline_completion_enabled
--   vim.lsp.inline_completion.enable(vim.g.inline_completion_enabled)
--   vim.notify('Inline completion: ' .. (vim.g.inline_completion_enabled and 'ON' or 'OFF'), vim.log.levels.INFO)
-- end, { desc = 'Toggle inline completion' })
--
-- vim.api.nvim_create_autocmd('LspAttach', {
--   callback = function(ev)
--     local client = vim.lsp.get_client_by_id(ev.data.client_id)
--     if not client then
--       return
--     end
--
--     if client:supports_method(vim.lsp.protocol.Methods.textDocument_inlineCompletion) then
--       -- Respect current toggle state when a client attaches
--       vim.lsp.inline_completion.enable(vim.g.inline_completion_enabled)
--
--       -- Keep your accept key (Alt-l)
--       vim.keymap.set('i', '<A-l>', function()
--         -- If inline completion is off, just pass the key through
--         if not vim.g.inline_completion_enabled then
--           return '<A-l>'
--         end
--
--         -- If there's an inline suggestion, accept it; otherwise pass through
--         if not vim.lsp.inline_completion.get() then
--           return '<A-l>'
--         end
--       end, { expr = true, replace_keycodes = true, buffer = ev.buf, desc = 'Accept inline completion' })
--     end
--   end,
-- })
