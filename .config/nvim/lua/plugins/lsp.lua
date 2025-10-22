return {
	"neovim/nvim-lspconfig",
	dependencies = {
		"mason-org/mason.nvim",
		"mason-org/mason-lspconfig.nvim",
		"ibhagwan/fzf-lua",
		"folke/lazydev.nvim",
	},

	config = function()
		local fzf = require("fzf-lua")
		local mason_lspconfig = require("mason-lspconfig")

		-- Hydrate the lua lsp with vim apis
		require("lazydev").setup({
			library = {
				-- See the configuration section for more details
				-- Load luvit types when the `vim.uv` word is found
				{ path = "${3rd}/luv/library", words = { "vim%.uv" } },
			},
		})

		mason_lspconfig.setup()

		-- Apply bashls to sh and zsh files
		vim.lsp.config("bashls", {
			filetypes = { "sh", "zsh" },
		})

		vim.lsp.config("pylsp", {
			settings = {
				pylsp = {
					plugins = {
						pycodestyle = {
							ignore = { "W391", "W503", "E501" },
							maxLineLength = 100,
						},
					},
				},
			},
		})

		vim.lsp.config("cssls", {
			settings = {
				css = {
					lint = {
						unknownAtRules = "ignore",
					},
				},
				scss = {
					lint = {
						unknownAtRules = "ignore",
					},
				},
				less = {
					lint = {
						unknownAtRules = "ignore",
					},
				},
			},
		})

		vim.api.nvim_create_autocmd("LspAttach", {
			callback = function(ev)
				vim.keymap.set("n", "<leader>R", "<cmd>LspRestart<CR>", { buffer = ev.buf, desc = "LSP: Restart LSP" })
				vim.keymap.set("n", "<leader>r", vim.lsp.buf.rename, { buffer = ev.buf, desc = "LSP: Rename variable" })
				vim.keymap.set("n", "gt", fzf.lsp_typedefs, { buffer = ev.buf, desc = "LSP: Goto type definition" })
				vim.keymap.set("n", "gd", fzf.lsp_definitions, { buffer = ev.buf, desc = "LSP: Goto definition" })
				vim.keymap.set(
					"n",
					"gi",
					fzf.lsp_implementations,
					{ buffer = ev.buf, desc = "LSP: Goto implementation" }
				)
				vim.keymap.set("n", "gr", fzf.lsp_references, { desc = "LSP: Goto references", nowait = true })
				vim.keymap.set("n", "gD", fzf.lsp_declarations, { buffer = ev.buf, desc = "LSP: Goto declaration" })
				vim.keymap.set("n", "K", vim.lsp.buf.hover, { buffer = ev.buf, desc = "LSP: Hover" })
				vim.keymap.set(
					{ "n", "v" },
					"<leader>ca",
					vim.lsp.buf.code_action,
					{ buffer = ev.buf, desc = "LSP: Code actions" }
				)
			end,
		})
	end,
}
