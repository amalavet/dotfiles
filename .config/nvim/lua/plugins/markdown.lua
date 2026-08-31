return {
	{
		src = "https://github.com/iamcco/markdown-preview.nvim",
		cmd = { "MarkdownPreviewToggle", "MarkdownPreview", "MarkdownPreviewStop" },
		ft = { "markdown" },
		config = function()
			local app_dir = vim.fn.stdpath("data") .. "/site/pack/core/opt/markdown-preview.nvim/app"
			if vim.fn.isdirectory(app_dir .. "/node_modules") == 0 then
				vim.fn["mkdp#util#install"]()
			end
			vim.keymap.set("n", "<leader>md", "<cmd>MarkdownPreview<CR>", { desc = "MarkdownPreview" })
		end,
	},
}
