local map = vim.keymap.set
local function is_deno_project(bufnr)
	local root = vim.fs.root(bufnr or 0, { "deno.json", "deno.jsonc" })
	return root ~= nil
end

local servers = {
	"html",
	"cssls",
	"oxlint",
	"oxfmt",
	"svelte",
	"vtsls",
	"denols",
	"unocss",
	"ruff",
	"lua_ls",
	"stylua",
	"tailwindcss",
	"jsonls",
	"prismals",
	"copilot",
	"jqls",
	"gopls",
	"astro",
	"yamlls",
	"just",
	"pyright",
	"mdx_analyzer",
}

-- lsp servers we want to use and their configuration
-- see `:h lspconfig-all` for available servers and their settings

vim.pack.add({
	"https://github.com/neovim/nvim-lspconfig", -- default configs for lsps
	-- see `:h lsp-quickstart` for more details.
	"https://github.com/mason-org/mason.nvim", -- package manager
	"https://github.com/mason-org/mason-lspconfig.nvim", -- lspconfig bridge
	"https://github.com/WhoIsSethDaniel/mason-tool-installer.nvim", -- auto installer
}, { confirm = false })

require("mason").setup()
require("mason-lspconfig").setup()
require("mason-tool-installer").setup({
	ensure_installed = servers,
})

local function on_attach(client, bufnr)
	local Snacks = require("snacks")
	local function opts(desc)
		return { buffer = bufnr, desc = "LSP " .. desc }
	end

	-- map("n", "gD", vim.lsp.buf.declaration, opts("Go to declaration"))
	-- map("n", "gd", vim.lsp.buf.definition, opts("Go to definition"))

	map("n", "gD", function()
		Snacks.picker.lsp_declarations()
	end, opts("Go to declaration"))

	map("n", "gd", function()
		Snacks.picker.lsp_definitions()
	end, opts("Go to definition"))

	map("n", "<leader>wa", vim.lsp.buf.add_workspace_folder, opts("Add workspace folder"))
	map("n", "<leader>wr", vim.lsp.buf.remove_workspace_folder, opts("Remove workspace folder"))
	map("n", "<leader>wl", function()
		print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
	end, opts("List workspace folders"))
	map("n", "<leader>D", vim.lsp.buf.type_definition, opts("Go to type definition"))

	if client.name == "svelte" then
		vim.api.nvim_buf_create_user_command(bufnr, "LspMigrateToSvelte5", function()
			client:exec_cmd({
				title = "Migrate Component to Svelte 5 Syntax",
				command = "migrate_to_svelte_5",
				arguments = { vim.uri_from_bufnr(bufnr) },
			})
		end, { desc = "Migrate Component to Svelte 5 Syntax" })
	end
end

-- configure each lsp server on the table
-- to check what clients are attached to the current buffer, use
-- `:checkhealth vim.lsp`. to view default lsp keybindings, use `:h lsp-defaults`.

vim.lsp.config("*", {
	on_attach = on_attach,
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
				globals = { "vim" },
			},
			workspace = {
				checkThirdParty = false,
				library = {
					vim.env.VIMRUNTIME,
					unpack(vim.api.nvim_get_runtime_file("lua", true)),
				},
			},
			telemetry = {
				enable = false,
			},
			hint = { enable = true },
		},
	},
})

vim.lsp.config("unocss", {
	root_dir = function(bufnr, on_dir)
		local root = vim.fs.root(bufnr, { "uno.config.ts" })
		if root then
			on_dir(root)
		end
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
		if is_deno_project(bufnr) then
			vim.print("DENO PROJECT DETECTED")
			return
		end

		local root_markers = {
			"package-lock.json",
			"yarn.lock",
			"pnpm-lock.yaml",
			"bun.lockb",
			"bun.lock",
			".git",
		}

		local root = vim.fs.root(bufnr, root_markers) or vim.fn.getcwd()
		on_dir(root)
	end,
})

vim.lsp.config("tsgo", {
	cmd = function(dispatchers, config)
		local cmd = "tsgo"
		local local_cmd = config.root_dir and (config.root_dir .. "/node_modules/.bin/tsgo") or nil

		if local_cmd and vim.fn.executable(local_cmd) == 1 then
			cmd = local_cmd
		end

		return vim.lsp.rpc.start({ cmd, "--lsp", "--stdio" }, dispatchers)
	end,
	filetypes = {},
	root_dir = function(bufnr, on_dir)
		if is_deno_project(bufnr) then
			return
		end

		local root_markers = {
			"package-lock.json",
			"yarn.lock",
			"pnpm-lock.yaml",
			"bun.lockb",
			"bun.lock",
			".git",
		}

		local root = vim.fs.root(bufnr, root_markers) or vim.fn.getcwd()
		on_dir(root)
	end,
})

vim.lsp.config("denols", {
	cmd = { "deno", "lsp" },
	root_dir = function(bufnr, on_dir)
		local deno_root = vim.fs.root(bufnr, { "deno.json", "deno.jsonc", "deno.lock" })
		if deno_root then
			on_dir(deno_root)
		end
	end,
	init_options = {
		lint = true,
		unstable = true,
	},
})

vim.opt.completeopt = { "menu", "menuone", "popup", "fuzzy" }

vim.lsp.enable(servers)

vim.api.nvim_create_autocmd("LspAttach", {
	callback = function(ev)
		local client = vim.lsp.get_client_by_id(ev.data.client_id)
		if client and client:supports_method(vim.lsp.protocol.Methods.textDocument_inlineCompletion) then
			vim.opt.completeopt = { "menu", "menuone", "noinsert", "fuzzy", "popup" }
			vim.lsp.inline_completion.enable(true)
			map("i", "<A-l>", function()
				if not vim.lsp.inline_completion.get() then
					return "<A-l>"
				end
			end)
		end
	end,
})
