return {
	"mbbill/undotree",
	config = function()
		vim.opt.undofile = true
		vim.keymap.set(
			"n",
			"<leader>u",
			vim.cmd.UndotreeToggle,
			{ noremap = true, silent = true, desc = "Undotree: Toggle" }
		)
	end,
}
