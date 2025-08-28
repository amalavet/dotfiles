return {
	"tpope/vim-fugitive",
	dependencies = {
		"tpope/vim-rhubarb",
		"airblade/vim-gitgutter",
	},

	config = function()
		vim.o.updatetime = 100
		vim.g.gitgutter_map_keys = false
		vim.keymap.set("n", "<leader>gs", "<cmd>Gvdiffsplit<CR>", { desc = "Git: See diff in split view" })
		vim.keymap.set("n", "<leader>go", "<cmd>GBrowse<CR>", { desc = "Git: Open in browser" })
		vim.g.github_enterprise_urls = { "https://github.cbhq.net" }
	end,
}
