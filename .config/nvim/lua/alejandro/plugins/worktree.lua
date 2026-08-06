return {
	{
		src = "https://github.com/ThePrimeagen/git-worktree.nvim",
		config = function()
			local worktree = require("git-worktree")
			worktree.setup()

			-- vim.keymap.set("n", "<leader>ws", function()
			-- 	local worktrees = {}
			-- 	for line in vim.fn.system("git worktree list"):gmatch("[^\n]+") do
			-- 		table.insert(worktrees, line:match("^(%S+)"))
			-- 	end
			-- 	vim.ui.select(worktrees, { prompt = "Switch worktree" }, function(choice)
			-- 		if choice then
			-- 			worktree.switch_worktree(choice)
			-- 		end
			-- 	end)
			-- end, { desc = "Worktree: Switch" })
			--
			-- vim.keymap.set("n", "<leader>wc", function()
			-- 	vim.ui.input({ prompt = "Branch name: " }, function(branch)
			-- 		if branch and branch ~= "" then
			-- 			local repo = vim.fn.fnamemodify(vim.fn.system("git rev-parse --show-toplevel"):gsub("%s+$", ""), ":t")
			-- 			worktree.create_worktree(vim.fn.expand("~/GitHub/worktrees/") .. repo .. "/" .. branch, branch)
			-- 		end
			-- 	end)
			-- end, { desc = "Worktree: Create" })
		end,
	},
}
