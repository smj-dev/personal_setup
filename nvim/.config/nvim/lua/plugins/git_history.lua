-- plugins/git_history.lua
return {
  {
    "tpope/vim-fugitive",
    cmd = { "G", "Git", "Gclog", "Gdiffsplit", "Gblame" }, -- lazy load on commands
  },
  {
    "rbong/vim-flog",
    dependencies = { "tpope/vim-fugitive" },
    cmd = { "Flog", "Flogsplit" }, -- lazy load on commands
  },
}

