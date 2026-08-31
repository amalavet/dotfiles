return {
	{ src = "https://github.com/tpope/vim-surround" },
	{
		src = "https://github.com/windwp/nvim-autopairs",
		event = "InsertEnter",
		config = function()
			require("nvim-autopairs").setup()
		end,
	},
	{
		src = "https://github.com/norcalli/nvim-colorizer.lua",
		config = function()
			require("colorizer").setup({ css = { css = true }, rasi = { rgb_fn = true }, lua = { lua = true } })
		end,
	},
	{
		src = "https://github.com/folke/todo-comments.nvim",
		config = function()
			require("todo-comments").setup({ signs = false })
		end,
	},
}
