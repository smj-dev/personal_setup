-- Setts a themed bottom bar to display info --
return {
  "nvim-lualine/lualine.nvim",
  config = function()
    require('lualine').setup({
      options = {
        theme = 'catppuccin', -- or 'auto' if you prefer fallback
        section_separators = '',
        component_separators = '',
        globalstatus = true
      },
      sections = {
        lualine_a = {
          {
            'mode',
            separator = '',
            padding = { left = 1, right = 1 }
          }
        },
        lualine_b = { 'branch' },
        lualine_c = { 'filename' },
        lualine_x = { 'filetype' },
        lualine_y = { 'progress' },
        lualine_z = { 'location' }
      }
    })
  end
}
