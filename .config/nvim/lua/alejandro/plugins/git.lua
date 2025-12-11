return {
	"tpope/vim-fugitive",
	dependencies = {
		"tpope/vim-rhubarb",
		"lewis6991/gitsigns.nvim",
	},

	config = function()
		vim.keymap.set("n", "<leader>gs", "<cmd>Gvdiffsplit<CR>", { desc = "Git: See diff in split view" })
		vim.keymap.set("n", "<leader>go", "<cmd>GBrowse<CR>", { desc = "Git: Open in browser" })

		local signs = {
			add = { text = "█" },
			change = { text = "█" },
			delete = { text = "█" },
			topdelete = { text = "‾" },
			changedelete = { text = "~" },
			untracked = { text = "┆" },
		}

		require("gitsigns").setup({
			signs = signs,
			signs_staged = signs,
			signs_staged_enable = true,
		})
	end,
}
