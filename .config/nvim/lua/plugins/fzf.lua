return {
	"ibhagwan/fzf-lua",
	dependencies = { "nvim-tree/nvim-web-devicons" },
	config = function()
		local fzf = require("fzf-lua")
		fzf.setup({
			"telescope",
		})

		vim.keymap.set("n", "<leader>ff", function()
			fzf.files({
				rg_opts = [[--color=never --files --hidden --follow -g "!.git" --no-ignore]],
				fd_opts = "--color=never --type f --hidden --follow --exclude .git --no-ignore",
				-- This uses lua pattern matching: https://www.lua.org/pil/20.2.html
				file_ignore_patterns = {
					".svg",
					"__pycache__/",
					".git/",
					".ttf",
					".dot",
					"node_modules/",
					".DS_Store",
					"env/",
					".svelte-kit",
				},
			})
		end, { desc = "FZF: Find Files" })
		vim.keymap.set("n", "<leader>fg", fzf.git_files, { desc = "FZF: Git Files" })
		vim.keymap.set("n", "<leader>fb", fzf.buffers, { desc = "FZF: Buffers" })
		vim.keymap.set("n", "<leader>fh", fzf.help_tags, { desc = "FZF: Get Help" })
		vim.keymap.set("n", "<leader>fl", fzf.live_grep, { desc = "FZF: Live Grep" })
		vim.keymap.set("n", "<leader>fk", fzf.keymaps, { desc = "FZF: Keymaps" })
		vim.keymap.set("n", "<leader>fw", fzf.grep_cword, { desc = "FZF: Grep Current Word" })
		vim.keymap.set("n", "<leader>fW", fzf.grep_cWORD, { desc = "FZF: Grep Current WORD" })
	end,
}
