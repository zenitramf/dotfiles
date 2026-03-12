require("nvchad.configs.lspconfig").defaults()

local function is_deno_project(bufnr)
  local root = vim.fs.root(bufnr or 0, { "deno.json", "deno.jsonc" })
  return root ~= nil
end

local servers = {
  "html",
  "cssls",
  "oxlint",
  "oxfmt",
  "svelteserver",
  "vtsls",
  "denols",
  "unocss",
  "ruff",
  "lua_ls",
  "sylua",
  "tailwindcss",
  "jsonls",
  "prismals",
  "copilot",
  "jqls",
  "gopls",
  "astro",
  "yamlls",
  "just",
}
vim.lsp.enable(servers)
-- read :h vim.lsp.config for changing options of lsp servers

---@type vim.lsp.Config
vim.lsp.config("svelteserver", {
  cmd = { "svelteserver", "--stdio" },
  filetypes = { "svelte" },
  root_dir = function(bufnr, on_dir)
    local fname = vim.api.nvim_buf_get_name(bufnr)
    -- Svelte LSP only supports file:// schema. https://github.com/sveltejs/language-tools/issues/2777
    if vim.uv.fs_stat(fname) ~= nil then
      local root_markers = { "package-lock.json", "yarn.lock", "pnpm-lock.yaml", "bun.lockb", "bun.lock", "deno.lock" }
      root_markers = vim.fn.has "nvim-0.11.3" == 1 and { root_markers, { ".git" } }
        or vim.list_extend(root_markers, { ".git" })
      -- We fallback to the current working directory if no project root is found
      local project_root = vim.fs.root(bufnr, root_markers) or vim.fn.getcwd()
      on_dir(project_root)
    end
  end,
  on_attach = function(client, bufnr)
    -- Workaround to trigger reloading JS/TS files
    -- See https://github.com/sveltejs/language-tools/issues/2008
    vim.api.nvim_create_autocmd("BufWritePost", {
      pattern = { "*.js", "*.ts" },
      group = vim.api.nvim_create_augroup("lspconfig.svelte", {}),
      callback = function(ctx)
        -- internal API to sync changes that have not yet been saved to the file system
        ---@diagnostic disable-next-line: param-type-mismatch
        client:notify("$/onDidChangeTsOrJsFile", { uri = ctx.match })
      end,
    })
    vim.api.nvim_buf_create_user_command(bufnr, "LspMigrateToSvelte5", function()
      client:exec_cmd {
        title = "Migrate Component to Svelte 5 Syntax",
        command = "migrate_to_svelte_5",
        arguments = { vim.uri_from_bufnr(bufnr) },
      }
    end, { desc = "Migrate Component to Svelte 5 Syntax" })
  end,
})

vim.lsp.config("stylua", {
  cmd = { "stylua", "--lsp" },
  filetypes = { "lua" },
  root_markers = { ".stylua.toml", "stylua.toml", ".editorconfig" },
})

vim.lsp.config("ruff", {
  cmd = { "ruff", "server" },
  filetypes = { "python" },
  root_markers = { "pyproject.toml", "ruff.toml", ".git" },
  settings = {},
})

vim.lsp.config("lua_ls", {
  cmd = { "lua-language-server" },
  filetypes = { "lua" },
  root_markers = {
    ".luarc.json",
    ".luarc.jsonc",
    ".git",
  },
  settings = {
    Lua = {
      runtime = {
        version = "LuaJIT",
      },
      diagnostics = {
        globals = { "vim" }, -- fixes "undefined global 'vim'"
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

vim.lsp.config("unocss", {
  root_dir = function(bufnr, on_dir)
    local root = vim.fs.root(bufnr, {
      "uno.config.ts",
    })

    if root then
      on_dir(root)
    end
    -- If nil, LSP will NOT start
  end,
})

vim.lsp.config("tailwindcss", {
  root_dir = function(bufnr, on_dir)
    local root = vim.fs.root(bufnr, {
      "tailwind.config.ts",
      "tailwind.config.js",
    })

    if root then
      on_dir(root)
    end
  end,
})

-- Configure vtsls
vim.lsp.config("vtsls", {
  cmd = { "vtsls", "--stdio" },
  init_options = {
    hostInfo = "neovim",
  },
  filetypes = {
    "javascript",
    "javascriptreact",
    "javascript.jsx",
    "typescript",
    "typescriptreact",
    "typescript.tsx",
  },
  root_dir = function(bufnr, on_dir)
    -- skip if Deno project detected
    if is_deno_project(bufnr) then
      vim.schedule(function()
        vim.notify("[LSP] Skipping vtsls (Deno project detected)", vim.log.levels.INFO)
      end)
      return
    end

    -- otherwise, normal vtsls root detection
    local root_markers = {
      "package-lock.json",
      "yarn.lock",
      "pnpm-lock.yaml",
      "bun.lockb",
      "bun.lock",
      ".git",
    }
    local project_root = vim.fs.root(bufnr, root_markers) or vim.fn.getcwd()
    on_dir(project_root)
  end,
})

-- Configure TSGO
vim.lsp.config("tsgo", {
  cmd = function(dispatchers, config)
    local cmd = "tsgo"
    local local_cmd = (config or {}).root_dir and config.root_dir .. "/node_modules/.bin/tsgo"
    if local_cmd and vim.fn.executable(local_cmd) == 1 then
      cmd = local_cmd
    end
    return vim.lsp.rpc.start({ cmd, "--lsp", "--stdio" }, dispatchers)
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
    local root_markers = { "package-lock.json", "yarn.lock", "pnpm-lock.yaml", "bun.lockb", "bun.lock" }
    -- Give the root markers equal priority by wrapping them in a table
    root_markers = vim.fn.has "nvim-0.11.3" == 1 and { root_markers, { ".git" } }
      or vim.list_extend(root_markers, { ".git" })

    -- exclude deno
    if vim.fs.root(bufnr, { "deno.json", "deno.jsonc", "deno.lock" }) then
      return
    end

    -- We fallback to the current working directory if no project root is found
    local project_root = vim.fs.root(bufnr, root_markers) or vim.fn.getcwd()

    on_dir(project_root)
  end,
})

-- Configure denols
vim.lsp.config("denols", {
  cmd = { "deno", "lsp" },
  root_dir = function(bufnr, on_dir)
    local deno_root = vim.fs.root(bufnr, { "deno.json", "deno.jsonc" })
    if deno_root then
      on_dir(deno_root)
    end
  end,
  init_options = {
    lint = true,
    unstable = true,
  },
})
