return {
	"neovim/nvim-lspconfig",
	dependencies = {
		{
			"hrsh7th/cmp-nvim-lsp",
			config = function()
				local cmp_nvim_lsp = require("cmp_nvim_lsp")
				vim.lsp.config("*", {
					capabilities = cmp_nvim_lsp.default_capabilities(),
				})
			end,
		},
		{
			"folke/lazydev.nvim",
			opts = {},
		},
	},
}
