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

vim.schedule(function()
  local ok, builtin = pcall(require, "telescope.builtin")
  if not ok then return end

  -- Telescope keybindings
  vim.keymap.set('n', '<C-p>', builtin.find_files, { desc = "Find files" })
  vim.keymap.set('n', '<leader>ff', builtin.find_files, { desc = "Find files (leader)" })
  vim.keymap.set('n', '<leader>fg', builtin.live_grep, { desc = "Live grep" })
    vim.keymap.set('n', '<leader>fs', builtin.lsp_document_symbols, { desc = "Find symbols in file" })
end)