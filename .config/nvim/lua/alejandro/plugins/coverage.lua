return {
	{
		src = "https://github.com/andythigpen/nvim-coverage",
		config = function()
			require("coverage").setup({ auto_reload = true })
		end,
	},
}
