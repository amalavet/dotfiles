return {
	"tpope/vim-surround",
	{
		"windwp/nvim-autopairs",
		event = "InsertEnter",
		opts = {},
	},
	{
		"norcalli/nvim-colorizer.lua",
		opts = { css = { css = true }, rasi = { rgb_fn = true } },
	},
	{
		"folke/todo-comments.nvim",
		dependencies = { "nvim-lua/plenary.nvim" },
		opts = {
			signs = false,
		},
	},
}
