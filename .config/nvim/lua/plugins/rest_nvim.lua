if true then return {} end
return {
  "rest-nvim/rest.nvim",
  opts = {
    request = {
      skip_ssl_verification = true,
    },
  },
}
