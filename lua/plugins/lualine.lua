-- Setts a themed bottom bar to display info --
return {
  "nvim-lualine/lualine.nvim",
  config = function()
  require('lualine').setup({
      options = {
        theme = 'dracula'
      }
    })
  end
}
