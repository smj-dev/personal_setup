-- Neo-tree treeview setup --
return {
	"nvim-neo-tree/neo-tree.nvim",
	branch = "v3.x",
	dependencies = {
		"nvim-lua/plenary.nvim",
		"nvim-tree/nvim-web-devicons",
		"MunifTanjim/nui.nvim",
	},
	config = function()
		vim.keymap.set("n", "<C-n>", ":Neotree toggle<CR>")

		local function jump_tree_by_first_char(direction)
			local ch = vim.fn.getcharstr()
			if ch == nil or ch == "" then
				return
			end
			ch = ch:lower()

			local buf = vim.api.nvim_get_current_buf()
			local row = vim.api.nvim_win_get_cursor(0)[1] -- 1-based
			local lines = vim.api.nvim_buf_get_lines(buf, 0, -1, false)

			local function entry_name(line)
				line = line:gsub("^%s+", "")
				line = line:gsub("^[│├└─]+%s*", "")
				-- drop one leading icon/glyph + optional space (helps with devicons)
				line = line:gsub("^[%z\1-\127\194-\244][\128-\191]*%s*", "")
				return vim.trim(line)
			end

			local i = row + direction
			while i >= 1 and i <= #lines do
				local name = entry_name(lines[i] or "")
				if name:sub(1, 1):lower() == ch then
					vim.api.nvim_win_set_cursor(0, { i, 0 })
					return
				end
				i = i + direction
			end
		end

		require("neo-tree").setup({
			event_handlers = {
				{
					event = "file_open_requested",
					handler = function()
						require("neo-tree.command").execute({ action = "close" })
					end,
				},
			},

			filesystem = {
				filtered_items = {
					visible = true,
					hide_dotfiles = false,
					hide_gitignored = true,
				},

				window = {
					mappings = {
						["f"] = function()
							jump_tree_by_first_char(1)
						end,
						["F"] = function()
							jump_tree_by_first_char(-1)
						end,

						["gf"] = "fuzzy_finder",
						["zf"] = "filter_on_submit",
					},
				},
			},
		})
	end,
}
