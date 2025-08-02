-- Install lazy package manager if not already installed
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

-- System clipboard
vim.o.clipboard = "unnamedplus"

-- Reload keybinds
vim.api.nvim_create_user_command("ReloadKeybinds", function()
  local ok, err = pcall(dofile, vim.fn.stdpath("config") .. "/lua/nvim-keybinds.lua")
  if not ok then
    vim.notify("Failed to reload keybinds: " .. err, vim.log.levels.ERROR)
  else
    vim.notify("Keybinds reloaded!", vim.log.levels.INFO)
  end
end, {})

require("nvim-keybinds")
require("lazy").setup("plugins")

