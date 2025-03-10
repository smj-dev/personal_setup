-- Install lazy package manager, if not already installed --  
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable", -- latest stable release
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

-- Use system clipboard --
vim.opt.clipboard:append("unnamedplus")
vim.api.nvim_create_autocmd({"BufRead", "BufWritePre"}, {
  pattern = "*",
  command = "setlocal fileformat=unix"
})

-- Plugins to be installed with lazy --
local opts = {}

require("nvim-keybinds")
require("lazy").setup("plugins")
