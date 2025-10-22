return {
	"stevearc/oil.nvim",
	dependencies = {
		"nvim-tree/nvim-web-devicons",
	},
	config = function()
		local oil = require("oil")
		oil.setup({
			default_file_explorer = false,
		})
		require("oil.config").setup({
			view_options = {
				show_hidden = true,
				is_always_hidden = function(name, _)
					return name:match(".DS_Store") or name:match("node_modules") or name:match("__pycache__")
				end,
			},
			delete_to_trash = true,
			default_file_explorer = true,
		})
		if vim.fn.exists("#FileExplorer") then
			vim.api.nvim_create_augroup("FileExplorer", { clear = true })
		end

		vim.keymap.set("n", "<leader>o", oil.toggle_float, { noremap = true, silent = true, desc = "Oil: Toggle" })
		vim.keymap.set("n", "<leader>O", function()
			oil.toggle_float("~")
		end, { noremap = true, silent = true, desc = "Oil: Toggle" })
	end,
}
