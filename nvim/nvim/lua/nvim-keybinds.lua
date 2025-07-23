-- Vim keybinds --

vim.api.nvim_create_user_command("ReloadKeybinds", function()
  loadfile(vim.fn.stdpath("config") .. "/lua/nvim-keybinds.lua")()
end, {})

vim.keymap.set('n', '.', ':', { noremap = true })

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
local modes = { "n", "v", "x", "o" }
vim.keymap.set(modes, "H", "0", { noremap = true })
vim.keymap.set(modes, "L", "$", { noremap = true })
vim.keymap.set(modes, "K", "<C-u>", { noremap = true })
vim.keymap.set(modes, "J", "<C-d>", { noremap = true })

-- Add lines --
vim.keymap.set("n", "<leader>o", [[:call append(line('.'), '')<CR>]])
vim.keymap.set("n", "<leader>O", [[:call append(line('.') - 1, '')<CR>]])

local move_opts = { noremap = true, silent = true }

-- Move line up/down in normal mode (preserve cursor)
vim.keymap.set("n", "<C-M-k>", "mz:m-2<CR>`z==", move_opts)
vim.keymap.set("n", "<C-M-j>", "mz:m+1<CR>`z==", move_opts)

-- Move selection up/down in visual mode (preserve selection)
vim.keymap.set("v", "<C-M-k>", ":m '<-2<CR>gv=gv", move_opts)
vim.keymap.set("v", "<C-M-j>", ":m '>+1<CR>gv=gv", move_opts)

-- Indent in normal mode
vim.keymap.set("n", "<C-M-h>", "<<", move_opts)
vim.keymap.set("n", "<C-M-l>", ">>", move_opts)

-- Indent in visual mode (reselect after shift)
vim.keymap.set("v", "<C-M-h>", "<gv", move_opts)
vim.keymap.set("v", "<C-M-l>", ">gv", move_opts)


-- Navigate vim panes in nvim --
vim.keymap.set('n', '<C-k>', ':wincmd k<CR>')
vim.keymap.set('n', '<C-j>', ':wincmd j<CR>')
vim.keymap.set('n', '<C-h>', ':wincmd h<CR>')
vim.keymap.set('n', '<C-l>', ':wincmd l<CR>')

-- navigate in insert mode --
vim.keymap.set('i', '<M-h>', '<Left>', { desc = 'Move left in insert mode'})
vim.keymap.set('i', '<M-l>', '<Right>', { desc = 'Move right in insert mode'})
vim.keymap.set('i', '<M-j>', '<Down>', { desc = 'Move down in insert mode'})
vim.keymap.set('i', '<M-k>', '<Up>', { desc = 'Move up in insert mode'})

vim.keymap.set('i', '<M-K>', '<C-o>b', { desc = 'Move word left in insert mode'})
vim.keymap.set('i', '<M-L>', '<C-o>w', { desc = 'Move word right in insert mode'})
vim.keymap.set('i', '<M-J>', '<C-o><C-d>', { desc = 'Move half-page down in insert mode'})
vim.keymap.set('i', '<M-J>', '<C-o><C-u>', { desc = 'Move half-page up in insert mode'})

vim.keymap.set('i', '<M-BS>', '<C-w>', { desc = 'Delete previous word in insert mode'})

vim.schedule(function()
  local ok, builtin = pcall(require, "telescope.builtin")
  if not ok then return end

  -- Telescope keybindings
  vim.keymap.set('n', '<C-p>', builtin.find_files, { desc = "Find files" })
  vim.keymap.set('n', '<leader>ff', builtin.find_files, { desc = "Find files (leader)" })
  vim.keymap.set('n', '<leader>fg', builtin.live_grep, { desc = "Live grep" })
    vim.keymap.set('n', '<leader>fs', builtin.lsp_document_symbols, { desc = "Find symbols in file" })
end)
