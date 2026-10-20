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
			vim.api.nvim_create_autocmd("CmdlineChanged", {
				pattern = { "/", "?" },
				callback = function()
					vim.schedule(function()
						vim.api.nvim__redraw({ valid = false, flush = true })
					end)
				end,
			})
		end,
	},
}
