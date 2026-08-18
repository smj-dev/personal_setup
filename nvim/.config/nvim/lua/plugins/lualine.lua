-- Setts a themed bottom bar to display info --
return {
  "nvim-lualine/lualine.nvim",
  config = function()
    require('lualine').setup({
      options = {
        -- catppuccin ships no plain 'catppuccin' theme, so that silently fell
        -- back to 'auto'. This one follows whichever flavour is active.
        theme = 'catppuccin-nvim',
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
        lualine_c = { {'filename', path=1 }},
        lualine_x = { 'filetype' },
        lualine_y = { 'progress' },
        lualine_z = { 'location' }
      }
    })
  end
}
