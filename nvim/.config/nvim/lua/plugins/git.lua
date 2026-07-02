-- lua/plugins/git.lua

local default_review_base = "origin/dev/staging"

local function diffview_review(base)
	base = base or ""
	if base == "" then
		base = default_review_base
	end

	vim.cmd("DiffviewOpen " .. vim.fn.fnameescape(base) .. "...HEAD")
end

local function diffview_commit(commit)
	if commit == nil or commit == "" then
		vim.ui.input({ prompt = "Commit: " }, function(input)
			if input == nil or input == "" then
				return
			end
			vim.cmd("DiffviewOpen " .. vim.fn.fnameescape(input) .. "^!")
		end)
		return
	end

	vim.cmd("DiffviewOpen " .. vim.fn.fnameescape(commit) .. "^!")
end

local function add_command_alias(alias, command)
	vim.cmd(
		string.format(
			[[cnoreabbrev <expr> %s getcmdtype() == ':' && getcmdline() ==# '%s' ? '%s' : '%s']],
			alias,
			alias,
			command,
			alias
		)
	)
end

return {
	{
		"tpope/vim-fugitive",
		cmd = {
			"G",
			"Git",
			"Gblame",
			"Gdiffsplit",
			"Gvdiffsplit",
			"Gclog",
			"Gedit",
			"Gread",
			"Gwrite",
		},
		keys = {
			{ "<leader>gb", "<cmd>Git blame<CR>", desc = "Git blame file" },
		},
	},

	{
		"sindrets/diffview.nvim",
		dependencies = { "nvim-lua/plenary.nvim" },
		cmd = {
			"DiffviewOpen",
			"DiffviewClose",
			"DiffviewToggleFiles",
			"DiffviewFocusFiles",
			"DiffviewRefresh",
			"DiffviewFileHistory",
			"Review",
			"ReviewCommit",
			"ReviewFileHistory",
		},
		init = function()
			vim.api.nvim_create_user_command("Review", function(opts)
				diffview_review(opts.args)
			end, {
				nargs = "?",
				complete = "customlist,v:lua.require'diffview.config'.get_config().hooks",
				desc = "Review branch against base branch",
			})

			vim.api.nvim_create_user_command("ReviewCommit", function(opts)
				diffview_commit(opts.args)
			end, {
				nargs = "?",
				desc = "Review one commit",
			})

			vim.api.nvim_create_user_command("ReviewFileHistory", function()
				vim.cmd("DiffviewFileHistory %")
			end, {
				desc = "Review current file history",
			})

			add_command_alias("mr", "Review")
			add_command_alias("commit", "ReviewCommit")
			add_command_alias("filehistory", "ReviewFileHistory")
			add_command_alias("reviewclose", "DiffviewClose")
		end,
		config = function()
			local actions = require("diffview.actions")

			require("diffview").setup({
				keymaps = {
					view = {
						{
							"n",
							"gn",
							function()
								vim.cmd.normal({ "]c", bang = true })
							end,
							{ desc = "Next change" },
						},
						{
							"n",
							"gb",
							function()
								vim.cmd.normal({ "[c", bang = true })
							end,
							{ desc = "Previous change" },
						},
						{
							"n",
							"gf",
							actions.goto_file,
							{ desc = "Open actual file" },
						},
						{
							"n",
							"q",
							"<cmd>DiffviewClose<CR>",
							{ desc = "Close review" },
						},
					},

					file_panel = {
						{
							"n",
							"j",
							actions.next_entry,
							{ desc = "Next file" },
						},
						{
							"n",
							"k",
							actions.prev_entry,
							{ desc = "Previous file" },
						},
						{
							"n",
							"<CR>",
							actions.select_entry,
							{ desc = "Open file diff" },
						},
						{
							"n",
							"o",
							actions.select_entry,
							{ desc = "Open file diff" },
						},
						{
							"n",
							"q",
							"<cmd>DiffviewClose<CR>",
							{ desc = "Close review" },
						},
					},

					file_history_panel = {
						{
							"n",
							"j",
							actions.next_entry,
							{ desc = "Next entry" },
						},
						{
							"n",
							"k",
							actions.prev_entry,
							{ desc = "Previous entry" },
						},
						{
							"n",
							"<CR>",
							actions.select_entry,
							{ desc = "Open entry" },
						},
						{
							"n",
							"q",
							"<cmd>DiffviewClose<CR>",
							{ desc = "Close history" },
						},
					},
				},
			})
		end,
	},

	{
		"rbong/vim-flog",
		dependencies = { "tpope/vim-fugitive" },
		cmd = { "Flog", "Flogsplit", "Floggit" },
	},
}
