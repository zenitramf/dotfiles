local spec = {
  'nvim-lualine/lualine.nvim',
  dependencies = { 'nvim-tree/nvim-web-devicons' },
  enabled = true,
  config = function()
    function StatusLine_Line()
      return vim.fn.line '.' .. '󰉸'
    end

    function StatusLine_Col()
      return vim.fn.col '.' .. ''
    end

    function StatusLine_Mode()
      local mode_map = {
        ['n'] = 'N',
        ['no'] = 'N-PENDING',
        ['i'] = 'I',
        ['ic'] = 'I',
        ['t'] = 'TERM',
        ['v'] = 'V',
        ['V'] = 'V-LINE',
        [''] = 'V-BLOCK',
        ['R'] = 'REPL',
        ['Rv'] = 'V-REPL',
        ['s'] = 'SEL',
        ['S'] = 'S-LINE',
        [''] = 'S-BLOCK',
        ['c'] = 'COMM',
        ['cv'] = 'COMM',
        ['ce'] = 'COMM',
        ['r'] = 'PROMPT',
        ['rm'] = 'MORE',
        ['r?'] = 'CONF',
      }
      return mode_map[vim.fn.mode()] or 'UNKNOWN'
    end

    require('lualine').setup {
      options = {
        theme = 'ayu_dark',
        section_separators = '',
        component_separators = '',
      },
      sections = {
        lualine_a = { StatusLine_Mode },
        lualine_b = {
          'diff',
          {
            'diagnostics',
            on_click = function(number, mousebutton, clicks, modifiers)
              if mousebutton == 'l' then
                return vim.cmd 'Trouble diagnostics toggle filter.buf=0'
              end
            end,
          },
        },
        lualine_c = {
          {
            'filename',
            on_click = function(number, mousebutton, clicks, modifiers)
              if mousebutton == 'l' then
                return require('oil').open()
              end
            end,
          },
        },
        lualine_x = {},
        lualine_y = {
          {
            'lsp_status',
            on_click = function(number, mousebutton, clicks, modifiers)
              if mousebutton == 'l' then
                return vim.cmd.LspInfo()
              end
            end,
          },
        },
        lualine_z = { 'searchcount', { StatusLine_Line, padding = {} }, StatusLine_Col },
      },
    }
  end,
}

return spec
