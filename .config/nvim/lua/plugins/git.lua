return {
	{ src = "https://github.com/tpope/vim-rhubarb" },
	{ src = "https://github.com/lewis6991/gitsigns.nvim" },
	{
		src = "https://github.com/tpope/vim-fugitive",
		config = function()
			vim.keymap.set("n", "<leader>gs", "<cmd>Gvdiffsplit<CR>", { desc = "Git: See diff in split view" })
			vim.keymap.set("n", "<leader>go", "<cmd>.GBrowse<CR>", { desc = "Git: Open in browser" })
			vim.keymap.set("v", "<leader>go", ":GBrowse<CR>", { desc = "Git: Open in browser" })

			require("gitsigns").setup({
				linehl = true,
				signs = {
					delete = { text = "┃" },
					topdelete = { text = "┃" },
				},
				signs_staged = {
					delete = { text = "┃" },
					topdelete = { text = "┃" },
				},
			})

			vim.keymap.set("n", "<leader>k", function()
					require("gitsigns").nav_hunk("next")
			end, { desc = "Git: Next hunk" })
			vim.keymap.set("n", "<leader>K", function()
					require("gitsigns").nav_hunk("prev")
			end, { desc = "Git: Prev hunk" })
			vim.keymap.set("n", "<leader><leader>k", function()
				require("gitsigns").toggle_deleted()
			end, { desc = "Git: Toggle deleted lines" })
		end,
	},
}
