return {
  {
    "rest-nvim/rest.nvim",
    opts = {
      request = {
        skip_ssl_verification = true,
      },
    },
  },
  {
    "mistweaverco/kulala.nvim",
    opts = {
      curl_path = "/snap/bin/curl",
    },
  },
}
