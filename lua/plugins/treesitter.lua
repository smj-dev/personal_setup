-- Treesitter, language highlighting TODO ADD C++  --
return  { 
  "nvim-treesitter/nvim-treesitter", 
  build = ":TSUpdate", 
  config = function()
    vim.keymap.set('n', '<C-n>', ':Neotree toggle<CR>')
    local config = require("nvim-treesitter.configs")
    config.setup({
      ensure_instlled = {"lua", "c", "cmake", "python"},
      highlight = { enable = true },
      indent = { enable = true },
    })
  end
}

