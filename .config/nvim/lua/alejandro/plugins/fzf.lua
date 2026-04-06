return {
	"ibhagwan/fzf-lua",
	dependencies = { "nvim-tree/nvim-web-devicons" },
	config = function()
		local fzf = require("fzf-lua")
		fzf.setup({
			"telescope",
		})
		local ignore_patterns = {
			".svg",
			"__pycache__/",
			".git/",
			".ttf",
			".dot",
			"node_modules/",
			".DS_Store",
			".svelte-kit",
		}

		vim.keymap.set("n", "<leader>ff", function()
			fzf.files({
				file_ignore_patterns = ignore_patterns,
			})
		end, { desc = "FZF: Find Files" })
		vim.keymap.set("n", "<leader>fg", fzf.git_files, { desc = "FZF: Git Files" })
		vim.keymap.set("n", "<leader>fb", fzf.buffers, { desc = "FZF: Buffers" })
		vim.keymap.set("n", "<leader>fh", fzf.help_tags, { desc = "FZF: Get Help" })
		vim.keymap.set("n", "<leader>fk", fzf.keymaps, { desc = "FZF: Keymaps" })
		vim.keymap.set("n", "<leader>fw", fzf.grep_cword, { desc = "FZF: Grep Current Word" })
		vim.keymap.set("n", "<leader>fW", fzf.grep_cWORD, { desc = "FZF: Grep Current WORD" })
	end,
}
