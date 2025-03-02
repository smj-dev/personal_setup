-- Vim keybinds --

-- Fix tabs --
vim.opt.tabstop=2
vim.opt.softtabstop=2
vim.opt.shiftwidth=2
vim.opt.expandtab=true

-- Set editor config -- 
vim.opt.nu = true -- linenumbers
vim.opt.relativenumber = true

vim.opt.wrap = false -- linewrap off

vim.opt.incsearch = true

vim.opt.scrolloff = 8

-- Set leader key --
vim.g.mapleader = ' '

-- Set navigations --
vim.keymap.set("n", "H", "0")
vim.keymap.set("n", "L", "$")

-- Navigate vim panes in nvim --
vim.keymap.set('n', '<C-k>', ':wincmd k<CR>')
vim.keymap.set('n', '<C-j>', ':wincmd j<CR>')
vim.keymap.set('n', '<C-h>', ':wincmd h<CR>')
vim.keymap.set('n', '<C-l>', ':wincmd l<CR>')
