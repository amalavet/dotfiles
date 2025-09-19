return {
	"folke/tokyonight.nvim",
	priority = 1000,
	config = function()
		local colorscheme = require("tokyonight")
		colorscheme.setup({
			transparent = true,
		})
		vim.cmd("colorscheme tokyonight-night")
	end,
}
