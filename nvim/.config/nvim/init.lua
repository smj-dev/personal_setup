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

-- ─────────────────────────────────────────────────────────────
-- Absolute numbers on the left + relative numbers on the right
-- ─────────────────────────────────────────────────────────────

-- Left: absolute numbers + LSP signs
vim.opt.number = true
vim.opt.relativenumber = false
vim.opt.signcolumn = "yes"

-- Right: virtual-text relative numbers
local ns_id = vim.api.nvim_create_namespace("RightRelNumbers")

local function update_rel_numbers()
  vim.api.nvim_buf_clear_namespace(0, ns_id, 0, -1)

  local current_line = vim.fn.line(".")
  local total_lines = vim.fn.line("$")

  for lnum = 1, total_lines do
    local rel = math.abs(lnum - current_line)
    local virt_text = (rel == 0) and "" or tostring(rel)

    vim.api.nvim_buf_set_extmark(0, ns_id, lnum - 1, -1, {
      virt_text = { { virt_text, "LineNr" } },
      virt_text_pos = "right_align",
    })
  end
end

vim.api.nvim_create_autocmd(
  { "CursorMoved", "CursorMovedI", "BufEnter", "TextChanged" },
  { callback = update_rel_numbers }
)

-- ─────────────────────────────────────────────────────────────
-- Load plugins and keybinds
-- ─────────────────────────────────────────────────────────────

require("nvim-keybinds")
require("lazy").setup("plugins")

