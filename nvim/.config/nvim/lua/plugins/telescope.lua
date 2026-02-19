-- Fuzzy finding --
return {
	{
		"nvim-telescope/telescope.nvim",
		tag = "0.1.5",
		dependencies = { "nvim-lua/plenary.nvim" },
		config = function()
			local telescope = require("telescope")
			local builtin = require("telescope.builtin")

			telescope.setup({
				defaults = {
					file_ignore_patterns = { ".git/" }, -- keep .git ignored
					preview = { treesitter = false },
				},
				pickers = {
					find_files = {
						hidden = true, -- include dotfiles
					},
				},
				extensions = {
					["ui-select"] = {
						require("telescope.themes").get_dropdown({}),
					},
				},
			})

			telescope.load_extension("ui-select")

			-- Helper: yank visual selection if in visual mode
			local function get_selection_if_visual()
				if vim.fn.mode():match("[vV]") then
					local save_reg = vim.fn.getreg('"')
					vim.cmd('noau normal! "vy') -- yank selection
					local text = vim.fn.getreg('"')
					vim.fn.setreg('"', save_reg)
					return text:gsub("\n", " ")
				end
				return nil
			end

			-- Unified search wrapper
			local function telescope_search(builtin_name)
				local selected_text = get_selection_if_visual()
				if selected_text and #selected_text > 0 then
					builtin[builtin_name]({ default_text = selected_text })
				else
					builtin[builtin_name]()
				end
			end

			-- Keymaps (work in both normal & visual mode)
			vim.keymap.set({ "n", "v" }, "<leader>ff", function()
				telescope_search("find_files")
			end, { noremap = true, silent = true, desc = "Find files (normal/visual, dotfiles too)" })

			vim.keymap.set({ "n", "v" }, "<leader>fg", function()
				telescope_search("live_grep")
			end, { noremap = true, silent = true, desc = "Live grep (normal/visual)" })

			vim.keymap.set("n", "<C-p>", builtin.find_files, { desc = "Find files (dotfiles too)" })
			vim.keymap.set("n", "<leader>fs", builtin.lsp_document_symbols, { desc = "Find symbols in file" })
			vim.keymap.set("n", "<leader>fr", builtin.grep_string, { desc = "Grep repo (word under cursor)" })
		end,
	},
	{
		"nvim-telescope/telescope-ui-select.nvim",
	},
}
