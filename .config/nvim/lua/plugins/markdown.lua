return {
	{
		src = "https://github.com/MeanderingProgrammer/render-markdown.nvim",
		ft = { "markdown" },
		config = function()
			require("render-markdown").setup({})
			vim.keymap.set("n", "<leader>md", "<cmd>RenderMarkdown toggle<CR>", { desc = "Toggle markdown render" })
		end,
	},
}
