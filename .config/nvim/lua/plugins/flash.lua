return {
	{
		src = "https://github.com/folke/flash.nvim",
		event = "VimEnter",
		config = function()
			require("flash").setup({
				modes = {
					search = {
						enabled = true,
						jump = { nohlsearch = false },
					},
				},
			})
		end,
	},
}
