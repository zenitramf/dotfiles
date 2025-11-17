---@class snacks.dashboard.Config
---@field enabled? boolean
---@field header string
---@field sections snacks.dashboard.Section
---@field formats table<string, snacks.dashboard.Text|fun(item:snacks.dashboard.Item, ctx:snacks.dashboard.Format.ctx):snacks.dashboard.Text>

local dashboardSpec = {
  width = 60,
  row = nil, -- dashboard position. nil for center
  col = nil, -- dashboard position. nil for center
  pane_gap = 4, -- empty columns between vertical panes
  autokeys = '1234567890abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ', -- autokey sequence
  -- These settings are used by some built-in sections
  preset = {
    -- Defaults to a picker that supports `fzf-lua`, `telescope.nvim` and `mini.pick`
    ---@type fun(cmd:string, opts:table)|nil
    pick = nil,
    -- Used by the `keys` section to show keymaps.
    -- Set your custom keymaps here.
    -- When using a function, the `items` argument are the default keymaps.
    ---@type snacks.dashboard.Item[]
    keys = {
      { icon = ' ', key = 'f', desc = 'Find File', action = ":lua Snacks.dashboard.pick('files')" },
      { icon = ' ', key = 'n', desc = 'New File', action = ':ene | startinsert' },
      { icon = ' ', key = 'g', desc = 'Find Text', action = ":lua Snacks.dashboard.pick('live_grep')" },
      { icon = ' ', key = 'r', desc = 'Recent Files', action = ":lua Snacks.dashboard.pick('oldfiles')" },
      { icon = ' ', key = 'c', desc = 'Config', action = ":lua Snacks.dashboard.pick('files', {cwd = vim.fn.stdpath('config')})" },
      { icon = ' ', key = 's', desc = 'Restore Session', section = 'session' },
      { icon = '󰒲 ', key = 'L', desc = 'Lazy', action = ':Lazy', enabled = package.loaded.lazy ~= nil },
      { icon = ' ', key = 'q', desc = 'Quit', action = ':qa' },
    },
    -- Used by the `header` section
  },
  -- item field formatters
  formats = {
    icon = function(item)
      if item.file and item.icon == 'file' or item.icon == 'directory' then
        return Snacks.dashboard.icon(item.file, item.icon)
      end
      return { item.icon, width = 2, hl = 'icon' }
    end,
    footer = { '%s', align = 'center' },
    header = { '%s', align = 'center' },
    file = function(item, ctx)
      local fname = vim.fn.fnamemodify(item.file, ':~')
      fname = ctx.width and #fname > ctx.width and vim.fn.pathshorten(fname) or fname
      if #fname > ctx.width then
        local dir = vim.fn.fnamemodify(fname, ':h')
        local file = vim.fn.fnamemodify(fname, ':t')
        if dir and file then
          file = file:sub(-(ctx.width - #dir - 2))
          fname = dir .. '/…' .. file
        end
      end
      local dir, file = fname:match '^(.*)/(.+)$'
      return dir and { { dir .. '/', hl = 'dir' }, { file, hl = 'file' } } or { { fname, hl = 'file' } }
    end,
  },
  sections = {
    { section = 'header' },
    {
      pane = 2,
      section = 'terminal',
      cmd = "set p (curl -s https://dailyverses.net/(date +%Y/%m/%d)/kjv); set v (echo $p | htmlq -t 'span.v1'); set r (echo $p | htmlq -t 'a.vc' | head -n1); printf '\\n\\e[1;38;5;45m✨ Daily Verse ✨\\e[0m\\n\\n\\e[1;97m%s\\e[0m\\n\\n\\e[38;5;117m%s\\e[0m\\n' $v $r",
      height = 9,
      padding = 1,
    },
    { section = 'keys', gap = 1, padding = 1 },
    { pane = 2, icon = ' ', title = 'Recent Files', section = 'recent_files', indent = 2, padding = 1 },
    { pane = 2, icon = ' ', title = 'Projects', section = 'projects', indent = 2, padding = 1 },
    {
      pane = 2,
      icon = ' ',
      title = 'Git Status',
      section = 'terminal',
      enabled = function()
        return Snacks.git.get_root() ~= nil
      end,
      cmd = 'git status --short --branch --renames',
      height = 5,
      padding = 1,
      ttl = 5 * 60,
      indent = 3,
    },
    { section = 'startup' },
  },
}

local pickerSpec = {
  -- Top Pickers & Explorer
  {
    '<leader><space>',
    function()
      Snacks.picker.buffers()
    end,
    desc = 'Find Buffers',
  },
  {
    '<leader>/',
    function()
      Snacks.picker.grep()
    end,
    desc = 'Grep',
  },
  {
    '<leader>:',
    function()
      Snacks.picker.command_history()
    end,
    desc = 'Command History',
  },
  {
    '<leader>n',
    function()
      Snacks.picker.notifications()
    end,
    desc = 'Notification History',
  },
  {
    '<leader>e',
    function()
      Snacks.explorer()
    end,
    desc = 'File Explorer',
  },
  -- find
  {
    '<leader>fb',
    function()
      Snacks.picker.buffers()
    end,
    desc = 'Buffers',
  },
  {
    '<leader>fc',
    function()
      Snacks.picker.files { cwd = vim.fn.stdpath 'config' }
    end,
    desc = 'Find Config File',
  },
  {
    '<leader>ff',
    function()
      Snacks.picker.files()
    end,
    desc = 'Find Files',
  },
  {
    '<leader>fg',
    function()
      Snacks.picker.git_files()
    end,
    desc = 'Find Git Files',
  },
  {
    '<leader>fp',
    function()
      Snacks.picker.projects()
    end,
    desc = 'Projects',
  },
  {
    '<leader>fr',
    function()
      Snacks.picker.recent()
    end,
    desc = 'Recent',
  },
  -- git
  {
    '<leader>gb',
    function()
      Snacks.picker.git_branches()
    end,
    desc = 'Git Branches',
  },
  {
    '<leader>gl',
    function()
      Snacks.picker.git_log()
    end,
    desc = 'Git Log',
  },
  {
    '<leader>gL',
    function()
      Snacks.picker.git_log_line()
    end,
    desc = 'Git Log Line',
  },
  {
    '<leader>gs',
    function()
      Snacks.picker.git_status()
    end,
    desc = 'Git Status',
  },
  {
    '<leader>gS',
    function()
      Snacks.picker.git_stash()
    end,
    desc = 'Git Stash',
  },
  {
    '<leader>gd',
    function()
      Snacks.picker.git_diff()
    end,
    desc = 'Git Diff (Hunks)',
  },
  {
    '<leader>gf',
    function()
      Snacks.picker.git_log_file()
    end,
    desc = 'Git Log File',
  },
  -- gh
  {
    '<leader>gi',
    function()
      Snacks.picker.gh_issue()
    end,
    desc = 'GitHub Issues (open)',
  },
  {
    '<leader>gI',
    function()
      Snacks.picker.gh_issue { state = 'all' }
    end,
    desc = 'GitHub Issues (all)',
  },
  {
    '<leader>gp',
    function()
      Snacks.picker.gh_pr()
    end,
    desc = 'GitHub Pull Requests (open)',
  },
  {
    '<leader>gP',
    function()
      Snacks.picker.gh_pr { state = 'all' }
    end,
    desc = 'GitHub Pull Requests (all)',
  },
  -- Grep
  {
    '<leader>sb',
    function()
      Snacks.picker.lines()
    end,
    desc = 'Buffer Lines',
  },
  {
    '<leader>,',
    function()
      Snacks.picker.grep_buffers()
    end,
    desc = 'Grep Open Buffers',
  },
  {
    '<leader>sB',
    function()
      Snacks.picker.grep_buffers()
    end,
    desc = 'Grep Open Buffers',
  },
  {
    '<leader>sg',
    function()
      Snacks.picker.grep()
    end,
    desc = 'Grep',
  },
  {
    '<leader>sw',
    function()
      Snacks.picker.grep_word()
    end,
    desc = 'Visual selection or word',
    mode = { 'n', 'x' },
  },
  -- search
  {
    '<leader>s"',
    function()
      Snacks.picker.registers()
    end,
    desc = 'Registers',
  },
  {
    '<leader>s/',
    function()
      Snacks.picker.search_history()
    end,
    desc = 'Search History',
  },
  {
    '<leader>sa',
    function()
      Snacks.picker.autocmds()
    end,
    desc = 'Autocmds',
  },
  {
    '<leader>sb',
    function()
      Snacks.picker.lines()
    end,
    desc = 'Buffer Lines',
  },
  {
    '<leader>sc',
    function()
      Snacks.picker.command_history()
    end,
    desc = 'Command History',
  },
  {
    '<leader>sC',
    function()
      Snacks.picker.commands()
    end,
    desc = 'Commands',
  },
  {
    '<leader>sd',
    function()
      Snacks.picker.diagnostics()
    end,
    desc = 'Diagnostics',
  },
  {
    '<leader>sD',
    function()
      Snacks.picker.diagnostics_buffer()
    end,
    desc = 'Buffer Diagnostics',
  },
  {
    '<leader>sh',
    function()
      Snacks.picker.help()
    end,
    desc = 'Help Pages',
  },
  {
    '<leader>sH',
    function()
      Snacks.picker.highlights()
    end,
    desc = 'Highlights',
  },
  {
    '<leader>si',
    function()
      Snacks.picker.icons()
    end,
    desc = 'Icons',
  },
  {
    '<leader>sj',
    function()
      Snacks.picker.jumps()
    end,
    desc = 'Jumps',
  },
  {
    '<leader>sk',
    function()
      Snacks.picker.keymaps()
    end,
    desc = 'Keymaps',
  },
  {
    '<leader>sl',
    function()
      Snacks.picker.loclist()
    end,
    desc = 'Location List',
  },
  {
    '<leader>sm',
    function()
      Snacks.picker.marks()
    end,
    desc = 'Marks',
  },
  {
    '<leader>sM',
    function()
      Snacks.picker.man()
    end,
    desc = 'Man Pages',
  },
  {
    '<leader>sp',
    function()
      Snacks.picker.lazy()
    end,
    desc = 'Search for Plugin Spec',
  },
  {
    '<leader>sq',
    function()
      Snacks.picker.qflist()
    end,
    desc = 'Quickfix List',
  },
  {
    '<leader>sR',
    function()
      Snacks.picker.resume()
    end,
    desc = 'Resume',
  },
  {
    '<leader>su',
    function()
      Snacks.picker.undo()
    end,
    desc = 'Undo History',
  },
  {
    '<leader>uC',
    function()
      Snacks.picker.colorschemes()
    end,
    desc = 'Colorschemes',
  },
  -- LSP
  {
    'gd',
    function()
      Snacks.picker.lsp_definitions()
    end,
    desc = 'Goto Definition',
  },
  {
    'gD',
    function()
      Snacks.picker.lsp_declarations()
    end,
    desc = 'Goto Declaration',
  },
  {
    'gr',
    function()
      Snacks.picker.lsp_references()
    end,
    nowait = true,
    desc = 'References',
  },
  {
    'gI',
    function()
      Snacks.picker.lsp_implementations()
    end,
    desc = 'Goto Implementation',
  },
  {
    'gy',
    function()
      Snacks.picker.lsp_type_definitions()
    end,
    desc = 'Goto T[y]pe Definition',
  },
  {
    'gai',
    function()
      Snacks.picker.lsp_incoming_calls()
    end,
    desc = 'C[a]lls Incoming',
  },
  {
    'gao',
    function()
      Snacks.picker.lsp_outgoing_calls()
    end,
    desc = 'C[a]lls Outgoing',
  },
  {
    '<leader>ss',
    function()
      Snacks.picker.lsp_symbols()
    end,
    desc = 'LSP Symbols',
  },
  {
    '<leader>sS',
    function()
      Snacks.picker.lsp_workspace_symbols()
    end,
    desc = 'LSP Workspace Symbols',
  },
  -- Other
  {
    '<leader>z',
    function()
      Snacks.zen()
    end,
    desc = 'Toggle Zen Mode',
  },
  {
    '<leader>Z',
    function()
      Snacks.zen.zoom()
    end,
    desc = 'Toggle Zoom',
  },
  {
    '<leader>.',
    function()
      Snacks.scratch()
    end,
    desc = 'Toggle Scratch Buffer',
  },
  {
    '<leader>S',
    function()
      Snacks.scratch.select()
    end,
    desc = 'Select Scratch Buffer',
  },
  {
    '<leader>n',
    function()
      Snacks.notifier.show_history()
    end,
    desc = 'Notification History',
  },
  {
    '<leader>bd',
    function()
      Snacks.bufdelete()
    end,
    desc = 'Delete Buffer',
  },
  {
    '<leader>cR',
    function()
      Snacks.rename.rename_file()
    end,
    desc = 'Rename File',
  },
  {
    '<leader>gB',
    function()
      Snacks.gitbrowse()
    end,
    desc = 'Git Browse',
    mode = { 'n', 'v' },
  },
  {
    '<leader>gg',
    function()
      Snacks.lazygit()
    end,
    desc = 'Lazygit',
  },
  {
    '<leader>un',
    function()
      Snacks.notifier.hide()
    end,
    desc = 'Dismiss All Notifications',
  },
  {
    '<c-_>',
    function()
      Snacks.terminal()
    end,
    desc = 'which_key_ignore',
  },
  {
    ']]',
    function()
      Snacks.words.jump(vim.v.count1)
    end,
    desc = 'Next Reference',
    mode = { 'n', 't' },
  },
  {
    '[[',
    function()
      Snacks.words.jump(-vim.v.count1)
    end,
    desc = 'Prev Reference',
    mode = { 'n', 't' },
  },
  {
    '<leader>N',
    desc = 'Neovim News',
    function()
      Snacks.win {
        file = vim.api.nvim_get_runtime_file('doc/news.txt', false)[1],
        width = 0.6,
        height = 0.6,
        wo = {
          spell = false,
          wrap = false,
          signcolumn = 'yes',
          statuscolumn = ' ',
          conceallevel = 3,
        },
      }
    end,
  },
}

---@class snacks.statuscolumn.Config
---@field left snacks.statuscolumn.Components
---@field right snacks.statuscolumn.Components
---@field enabled? boolean
local statuscolumnSpec = {
  left = { 'mark', 'sign' }, -- priority of signs on the left (high to low)
  right = { 'fold', 'git' }, -- priority of signs on the right (high to low)
  folds = {
    open = false, -- show open fold icons
    git_hl = false, -- use Git Signs hl for fold icons
  },
  git = {
    -- patterns to match Git signs
    patterns = { 'GitSign', 'MiniDiffSign' },
  },
  refresh = 50, -- refresh at most every 50ms
}

local spec = {
  'folke/snacks.nvim',
  priority = 1000,
  lazy = false,
  ---@type snacks.Config
  opts = {
    -- your configuration comes here
    -- or leave it empty to use the default settings
    -- refer to the configuration section below
    bigfile = { enabled = false },
    dashboard = dashboardSpec,
    explorer = { enabled = false },
    indent = {},
    input = {},
    picker = { enabled = true, layout = 'ivy' },
    terminal = {},
    notifier = {},
    quickfile = { enabled = false },
    scope = { enabled = false },
    scroll = { enabled = false },
    statuscolumn = statuscolumnSpec,
    words = { enabled = false },
    zen = {},
  },
  keys = pickerSpec,
}
return spec
