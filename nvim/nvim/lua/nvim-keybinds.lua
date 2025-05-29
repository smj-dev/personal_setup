-- Vim keybinds --

vim.api.nvim_create_user_command("ReloadKeybinds", function()
  loadfile(vim.fn.stdpath("config") .. "/lua/nvim-keybinds.lua")()
end, {})

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
vim.keymap.set("n", "K", "<C-u>")
vim.keymap.set("n", "J", "<C-d>")


-- Add lines --
vim.keymap.set("n", "<leader>o","call append(line('.'),'')<CR>")
vim.keymap.set("n", "<leader>O","call append(line('.') -1,'')<CR>")

-- Navigate vim panes in nvim --
vim.keymap.set('n', '<C-k>', ':wincmd k<CR>')
vim.keymap.set('n', '<C-j>', ':wincmd j<CR>')
vim.keymap.set('n', '<C-h>', ':wincmd h<CR>')
vim.keymap.set('n', '<C-l>', ':wincmd l<CR>')

-- navigate in insert mode --
vim.keymap.set('i', '<M-h>', '<Left>', { desc = 'Move left in insert mode'})
vim.keymap.set('i', '<M-l>', '<Right>', { desc = 'Move left in insert mode'})
vim.keymap.set('i', '<M-j>', '<Down>', { desc = 'Move left in insert mode'})
vim.keymap.set('i', '<M-k>', '<Up>', { desc = 'Move left in insert mode'})

vim.schedule(function()
  local ok, builtin = pcall(require, "telescope.builtin")
  if not ok then return end

  -- Telescope keybindings
  vim.keymap.set('n', '<C-p>', builtin.find_files, { desc = "Find files" })
  vim.keymap.set('n', '<leader>ff', builtin.find_files, { desc = "Find files (leader)" })
  vim.keymap.set('n', '<leader>fg', builtin.live_grep, { desc = "Live grep" })
    vim.keymap.set('n', '<leader>fs', builtin.lsp_document_symbols, { desc = "Find symbols in file" })
end)
