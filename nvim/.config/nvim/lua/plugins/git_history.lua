-- plugins/git_history.lua
return {
	{
		"tpope/vim-fugitive",
		cmd = { "G", "Git", "Gclog", "Gdiffsplit" },
		keys = {
			{ "<leader>gb", "<cmd>Git blame<CR>", desc = "Git blame current file" },
		},
	},
	{
		"rbong/vim-flog",
		dependencies = { "tpope/vim-fugitive" },
		cmd = { "Flog", "Flogsplit" },
	},
}
