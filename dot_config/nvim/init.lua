vim.g.mapleader = " "
vim.g.maplocalleader = "_"

vim.opt.clipboard = "unnamedplus"

vim.opt.number = true

vim.opt.tabstop = 4
vim.opt.shiftwidth = 4
vim.opt.softtabstop = 4

vim.opt.list = true
vim.opt.listchars = { tab = "⇥ ", trail = "·", nbsp = "·" }

vim.opt.expandtab = true
vim.opt.relativenumber = true
vim.opt.undofile = true
vim.opt.ignorecase = true
vim.opt.smartcase = true
vim.opt.scrolloff = 5

-- literal tabs for languages that require them
vim.api.nvim_create_autocmd('FileType', {
  pattern = { 'make', 'gdscript' },
  callback = function(args)
    vim.bo[args.buf].expandtab = false
  end,
})

vim.pack.add{
  { src = 'https://github.com/neovim/nvim-lspconfig' },
  { src = 'https://github.com/mason-org/mason.nvim' },
  { src = 'https://github.com/mason-org/mason-lspconfig.nvim' },

  { src = 'https://github.com/saghen/blink.lib' },
  { src = 'https://github.com/saghen/blink.cmp' },
  { src = 'https://github.com/folke/snacks.nvim' },
  { src = 'https://github.com/neovim-treesitter/treesitter-parser-registry' },
  { src = 'https://github.com/nvim-treesitter/nvim-treesitter' },

  { src = 'https://github.com/folke/which-key.nvim' },
  { src = 'https://github.com/lewis6991/gitsigns.nvim' },
  { src = 'https://github.com/nvim-lualine/lualine.nvim' },
  { src = 'https://github.com/rafamadriz/friendly-snippets' }
}

-- mason installs the servers; enabling is explicit (lspconfig names)
local servers = { 'clangd', 'html', 'lua_ls', 'pylsp' }

require('mason').setup()
require('mason-lspconfig').setup({
  automatic_enable = false,
  ensure_installed = servers,
})

vim.lsp.enable(servers)

-- completion
local cmp = require('blink.cmp')
cmp.build():pwait()
cmp.setup({
  keymap = { preset = 'super-tab' },
  signature = {
    enabled = true,
    trigger = { show_on_insert = true, show_on_keyword = true, show_on_accept = true },
  },
})

-- picker
require('snacks').setup({ picker = { enabled = true } })
vim.keymap.set('n', '<leader><space>', function() Snacks.picker.smart() end, { desc = 'Smart Find Files' })
vim.keymap.set('n', '<leader>/',       function() Snacks.picker.grep() end, { desc = 'Grep' })
vim.keymap.set('n', '<leader>ff',      function() Snacks.picker.files() end, { desc = 'Find Files' })
vim.keymap.set('n', '<leader>fb',      function() Snacks.picker.buffers() end, { desc = 'Buffers' })
vim.keymap.set('n', '<leader>sh',      function() Snacks.picker.help() end, { desc = 'Help Pages' })

-- syntax
require('nvim-treesitter').install({ 'lua', 'vim', 'vimdoc', 'query', 'bash', 'markdown', 'markdown_inline' })
vim.api.nvim_create_autocmd('FileType', {
  callback = function(args) pcall(vim.treesitter.start, args.buf) end,
})

-- git gutter
require('gitsigns').setup()

-- statusline
require('lualine').setup()

