return {
	{
		src = "https://github.com/folke/flash.nvim",
		event = "VimEnter",
		config = function()
			require("flash").setup()
			vim.keymap.set({ "n", "x", "o" }, "s", function()
				require("flash").jump()
			end, { desc = "Flash" })
		end,
	},
}
