if true then
  return {}
end
local spec = {
  'folke/sidekick.nvim',
  opts = {
    -- add any options here
    cli = {
      mux = {
        backend = 'tmux',
        enabled = true,
      },
    },
  },
}

return spec
