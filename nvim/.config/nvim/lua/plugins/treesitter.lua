-- Treesitter, language highlighting --
-- The main branch dropped the module system of master: parsers are installed
-- explicitly, and highlighting and indenting are Neovim's own, enabled per
-- filetype. Needs Neovim 0.12 and the tree-sitter CLI.
local parsers = { "lua", "c", "cmake", "python", "cpp", "julia", "markdown", "markdown_inline" }

-- markdown_inline is only ever injected, so it has no filetype of its own.
local filetypes = { "lua", "c", "cmake", "python", "cpp", "julia", "markdown" }

return {
  {
    "nvim-treesitter/nvim-treesitter",
    branch = "main",
    lazy = false,
    build = ":TSUpdate",
    config = function()
      require("nvim-treesitter").setup()
      require("nvim-treesitter").install(parsers)

      vim.api.nvim_create_autocmd("FileType", {
        pattern = filetypes,
        callback = function()
          -- Installing is async, so the parser may not be there yet for the
          -- first buffer of a filetype on a fresh machine.
          if pcall(vim.treesitter.start) then
            vim.bo.indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
          end
        end,
      })
    end,
  },
}
