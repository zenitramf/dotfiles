local spec = {
  'NMAC427/guess-indent.nvim',
  event = 'VeryLazy',
  config = function()
    require('guess-indent').setup {
      -- add any custom settings here
    }
  end,
}
return spec
