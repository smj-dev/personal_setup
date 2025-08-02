-- Soften cursor line number
vim.api.nvim_set_hl(0, "CursorLineNr", { fg = "#a6adc8", bold = false })
-- Muted absolute numbers
vim.api.nvim_set_hl(0, "AbsLineNr", { fg = "#7f849c", bold = false })

return {
  {
    "shrynx/line-numbers.nvim",
    opts = {
      mode = "both",
      format = "abs_rel",
      separator = " ",
      abs_highlight = { link = "AbsLineNr" },
      rel_highlight = { link = "LineNr" },
      exclude_filetypes = { "NvimTree", "neo-tree", "TelescopePrompt" },
    },
  },
}
