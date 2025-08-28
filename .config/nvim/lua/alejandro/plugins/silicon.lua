return {
	"michaelrommel/nvim-silicon",
	config = function()
		require("nvim-silicon").setup({
			font = "JetBrainsMono NF=34",
			to_clipboard = true,
			no_window_controls = true,
			window_title = function()
				return vim.fn.fnamemodify(vim.api.nvim_buf_get_name(vim.api.nvim_get_current_buf()), ":.")
			end,
		})
		vim.keymap.set("v", "<leader>s", ":Silicon<CR>", { desc = "Silicon: Screenshot" })
	end,
}
