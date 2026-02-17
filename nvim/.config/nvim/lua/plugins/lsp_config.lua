-- lua/plugins/lsp_config.lua
return {
	{
		"williamboman/mason.nvim",
		config = function()
			require("mason").setup()
		end,
	},
	{
		"williamboman/mason-lspconfig.nvim",
		config = function()
			require("mason-lspconfig").setup({
				ensure_installed = { "lua_ls", "clangd", "html", "pyright", "bashls" },
			})
		end,
	},
	{
		"neovim/nvim-lspconfig",
		config = function()
			local capabilities = require("cmp_nvim_lsp").default_capabilities()

			vim.diagnostic.config({
				virtual_text = false,
				severity_sort = true,
				signs = {
					text = {
						[vim.diagnostic.severity.ERROR] = "▎",
						[vim.diagnostic.severity.WARN] = "▎",
						[vim.diagnostic.severity.HINT] = "▎",
						[vim.diagnostic.severity.INFO] = "▎",
					},
				},
			})

			vim.lsp.config("clangd", { capabilities = capabilities })
			vim.lsp.config("html", { capabilities = capabilities })
			vim.lsp.config("lua_ls", { capabilities = capabilities })
			vim.lsp.config("pyright", {
				capabilities = capabilities,
				settings = {
					python = {
						pythonPath = vim.fn.exepath("python3"),
						venvPath = ".",
						analysis = {
							autoSearchPaths = true,
							useLibraryCodeForTypes = true,
							diagnosticMode = "openFilesOnly",
						},
					},
				},
			})
			vim.lsp.config("bashls", { capabilities = capabilities })

			vim.lsp.enable({ "clangd", "html", "lua_ls", "pyright", "bashls" })

			vim.keymap.set("n", "K", vim.lsp.buf.hover, { desc = "LSP Hover" })
			vim.keymap.set("n", "gd", vim.lsp.buf.definition, { desc = "LSP Goto Definition" })
			vim.keymap.set("n", "<leader>ca", vim.lsp.buf.code_action, { desc = "LSP Code Action" })
			vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename, { desc = "LSP Rename" })
		end,
	},
}
