-- Show popup hints for <leader> mappings
return {
  "folke/which-key.nvim",
  event = "VeryLazy",
  config = function()
    require("which-key").setup()
  end,
}
