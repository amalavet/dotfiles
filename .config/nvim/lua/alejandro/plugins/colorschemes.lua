return {
	"folke/tokyonight.nvim",
	priority = 1000,
	config = function()
		local colorscheme = require("tokyonight")
		colorscheme.setup({
			transparent = true,
			on_highlights = function(hl)
				-- Dim inactive windows by setting NormalNC to a darker background
				hl.NormalNC = {
					bg = "#000000",
				}
			end,
		})
		vim.cmd("colorscheme tokyonight-night")
	end,
}
