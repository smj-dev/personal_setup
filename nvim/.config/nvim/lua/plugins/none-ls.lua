-- Formattertools etc, dependency stylua installed via Mason.
return {
	"nvimtools/none-ls.nvim",
	config = function()
		local null_ls = require("null-ls")
		local ruff = {
			name = "ruff",
			method = null_ls.methods.DIAGNOSTICS,
			filetypes = { "python" },
			generator = null_ls.generator({
				command = "ruff",
				args = { "check", "--quiet", "--output-format", "json", "$FILENAME" },
				to_stdin = false,
				from_stderr = false,
				format = "json",
				check_exit_code = function(code)
					return code == 0 or code == 1
				end,
				on_output = function(params)
					local diags = {}
					for _, item in ipairs(params.output or {}) do
						table.insert(diags, {
							row = item.location.row,
							col = item.location.column,
							end_row = item.end_location and item.end_location.row or item.location.row,
							end_col = item.end_location and item.end_location.column or item.location.column,
							message = (item.code and (item.code .. ": ") or "") .. item.message,
							severity = vim.diagnostic.severity.WARN,
							source = "ruff",
						})
					end
					return diags
				end,
			}),
		}

		null_ls.setup({
			sources = {
				null_ls.builtins.formatting.stylua,
				null_ls.builtins.formatting.black,
				ruff,
			},
		})
		vim.keymap.set("n", "<leader>gf", vim.lsp.buf.format, {})
	end,
}
