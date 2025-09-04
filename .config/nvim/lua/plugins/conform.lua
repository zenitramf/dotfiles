return {
  "stevearc/conform.nvim",
  opts = function(_, opts)
    local conform = require("conform")

    -- Define formatter configs (yamlfix style)
    conform.formatters["biome-check"] = {
      require_cwd = true,
    }
    conform.formatters["biome-organize-imports"] = {
      require_cwd = true,
    }

    -- Attach to JS/TS filetypes
    local ts_js = {
      "javascript",
      "javascriptreact",
      "typescript",
      "typescriptreact",
    }

    opts.formatters_by_ft = opts.formatters_by_ft or {}

    for _, ft in ipairs(ts_js) do
      opts.formatters_by_ft[ft] = opts.formatters_by_ft[ft] or {}
      local list = opts.formatters_by_ft[ft]

      local function add(name)
        for _, v in ipairs(list) do
          if v == name then
            return
          end
        end
        table.insert(list, name)
      end

      -- order matters: organize imports first, then check
      add("biome-organize-imports")
      add("biome-check")
    end
  end,
}
