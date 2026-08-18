vim.g.mapleader = " "
vim.g.maplocalleader = "\\"

vim.opt.clipboard = "unnamedplus"

vim.opt.number = true

vim.opt.tabstop = 4
vim.opt.shiftwidth = 4
vim.opt.softtabstop = 4

vim.opt.list = true
vim.opt.listchars = { tab = "⇥ ", trail = "·", nbsp = "·" }

vim.pack.add{
  { src = 'https://github.com/neovim/nvim-lspconfig' },
  { src = 'https://github.com/mason-org/mason.nvim' },
  { src = 'https://github.com/mason-org/mason-lspconfig.nvim' },


  { src = 'https://github.com/folke/which-key.nvim' }
}

require('mason').setup()
require('mason-lspconfig').setup()

