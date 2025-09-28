-- Keybinds & Config --
-- Leader
vim.g.mapleader = ' '
vim.g.maplocalleader = ' '

-- Remap :
vim.keymap.set('n', '.', ':', { noremap = true })

-- Prevent <Space> from doing its default move in visual mode
vim.keymap.set("v", "<Space>", "<Nop>", { noremap = true, silent = true })

-- Options
vim.opt.tabstop = 2
vim.opt.softtabstop = 2
vim.opt.shiftwidth = 2
vim.opt.expandtab = true
vim.opt.nu = true
vim.opt.wrap = false
vim.opt.incsearch = true
vim.opt.scrolloff = 8
vim.opt.number = true
vim.opt.relativenumber = false
vim.opt.signcolumn = "auto"


-- Helper function for consistency
local function map(mode, lhs, rhs, desc)
  vim.keymap.set(mode, lhs, rhs, { noremap = true, silent = true, desc = desc })
end

-- Navigation ------------------------------------------------------------

-- Motion remaps
local modes = { "n", "v", "x", "o" }
map(modes, "H", "0", "Jump to line start")
map(modes, "L", "$", "Jump to line end")
map(modes, "K", "<C-u>", "Page up")
map(modes, "J", "<C-d>", "Page down")

-- Pane navigation
map("n", "<C-k>", ":wincmd k<CR>", "Pane up")
map("n", "<C-j>", ":wincmd j<CR>", "Pane down")
map("n", "<C-h>", ":wincmd h<CR>", "Pane left")
map("n", "<C-l>", ":wincmd l<CR>", "Pane right")

-- Insert mode movement
map("i", "<M-h>", "<Left>", "Move left in insert mode")
map("i", "<M-l>", "<Right>", "Move right in insert mode")
map("i", "<M-j>", "<Down>", "Move down in insert mode")
map("i", "<M-k>", "<Up>", "Move up in insert mode")
map("i", "<M-K>", "<C-o>b", "Move word left in insert mode")
map("i", "<M-L>", "<C-o>w", "Move word right in insert mode")
map("i", "<M-J>", "<C-o><C-d>", "Half-page down in insert mode")
map("i", "<M-U>", "<C-o><C-u>", "Half-page up in insert mode")
map("i", "<M-BS>", "<C-w>", "Delete word in insert mode")

-- Search ----------------------------------------------------------------

map("v", "/", function()
  vim.cmd('normal! "vy')
  local selected_text = vim.fn.getreg('"')
  selected_text = selected_text:gsub("\n", " ")
  selected_text = vim.fn.escape(selected_text, "\\/.*$^~[]")
  local keys = vim.api.nvim_replace_termcodes("/" .. selected_text, true, false, true)
  vim.api.nvim_feedkeys(keys, "n", false)
end, "Search with selection")

-- Editing ---------------------------------------------------------------

map("n", "<leader>o", [[:call append(line('.'), '')<CR>]], "Add line below")
map("n", "<leader>O", [[:call append(line('.') - 1, '')<CR>]], "Add line above")
map("n", "<leader><Space>", "i <Esc>", "Insert space")

map("n", "<C-M-k>", "mz:m-2<CR>`z==", "Move line up")
map("n", "<C-M-j>", "mz:m+1<CR>`z==", "Move line down")
map("v", "<C-M-k>", ":m '<-2<CR>gv=gv", "Move selection up")
map("v", "<C-M-j>", ":m '>+1<CR>gv=gv", "Move selection down")

map("n", "<C-M-h>", "<<", "Indent left")
map("n", "<C-M-l>", ">>", "Indent right")
map("v", "<C-M-h>", "<gv", "Indent left (reselect)")
map("v", "<C-M-l>", ">gv", "Indent right (reselect)")

-- Paste over word and keep buffer
map("n", "<leader>p", [["_ciw<C-r>0<Esc>]], "Paste over word (keep yank, keep spaces)")
map("x", "<leader>p", [["_dP]], "Paste over selection (keep yank)")

-- Toggle between header/source with same basename in the same folder
local function toggle_header_source()
  local path = vim.api.nvim_buf_get_name(0)
  if path == "" then return end
  local base, ext = path:match("^(.*)%.([%w_]+)$")
  if not base then return end

  local headers = { h = true, hh = true, hpp = true, hxx = true }
  local sources = { c = true, cc = true, cpp = true, cxx = true }

  local candidates
  if headers[ext] then
    candidates = { "cpp", "cc", "cxx", "c" }
  elseif sources[ext] then
    candidates = { "h", "hpp", "hh", "hxx" }
  else
    vim.notify("Not a C/C++ header or source: " .. ext, vim.log.levels.WARN)
    return
  end

  for _, e in ipairs(candidates) do
    local cand = base .. "." .. e
    if vim.loop.fs_stat(cand) then
      vim.cmd.edit(vim.fn.fnameescape(cand))
      return
    end
  end
  vim.notify("No counterpart found next to file", vim.log.levels.WARN)
end

map("n", "<leader>gh", toggle_header_source, "Toggle header/source")

