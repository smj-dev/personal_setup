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
-- This fixes the linendings when pasting from windows to wsl --
vim.api.nvim_create_autocmd("InsertLeave", {
  pattern = "*",
  callback = function()
    vim.cmd("%s/\r//g")
  end
})

-- Plugins to be installed with lazy --
--local opts = {}

require("nvim-keybinds")
require("lazy").setup("plugins")
