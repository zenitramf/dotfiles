return {
  cmd = { "gh-actions-language-server", "--stdio" },
  filetypes = { "yaml" },
  root_dir = function(bufnr, on_dir)
    local parent = vim.fs.dirname(vim.api.nvim_buf_get_name(bufnr))
    if
      vim.endswith(parent, "/.github/workflows")
      or vim.endswith(parent, "/.forgejo/workflows")
      or vim.endswith(parent, "/.gitea/workflows")
    then
      on_dir(parent)
    end
  end,
  init_options = {},
  capabilities = {
    workspace = {
      didChangeWorkspaceFolders = {
        dynamicRegistration = true,
      },
    },
  },
}
