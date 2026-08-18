-- Treesitter, language highlighting --
return {
  {
    "nvim-treesitter/nvim-treesitter",
    -- Upstream's default branch is now main, which is a rewrite needing Neovim
    -- 0.12 and the tree-sitter CLI. Pin master until both are in place, or a
    -- fresh clone silently gets the rewrite and this config stops working.
    branch = "master",
    build = ":TSUpdate",
    config = function()
      -- Options belong to nvim-treesitter.configs; the top level setup() takes
      -- no arguments and silently drops everything passed to it.
      require("nvim-treesitter.configs").setup({
        ensure_installed = { "lua", "c", "cmake", "python", "cpp" },
        highlight = { enable = true },
        indent = { enable = true },
      })
    end,
  },
}

