return {
	"github/copilot.vim",
	config = function()
		-- Old keymap to open in Cursor IDE
		-- vim.keymap.set("n", "<leader>ai", function()
		-- 	-- Get current buffer info
		-- 	local bufnr = vim.api.nvim_get_current_buf()
		-- 	local filename = vim.api.nvim_buf_get_name(bufnr)
		--
		-- 	-- Construct and execute the cursor CLI command
		-- 	local cmd = string.format(
		-- 		"cursor --reuse-window . %s",
		-- 		filename -- Full path to file
		-- 	)
		--
		-- 	vim.fn.system(cmd)
		-- 	print("Opening in Cursor App...")
		-- end, { noremap = true, silent = true, desc = "Open in Cursor IDE" })

		vim.keymap.set("i", "<S-Right>", 'copilot#AcceptWord("\\<Tab>")', {
			expr = true,
			replace_keycodes = false,
			desc = "Copilot: Accept word",
		})

		vim.keymap.set("i", "<Right>", 'copilot#Accept("\\<Right>")', {
			expr = true,
			replace_keycodes = false,
			desc = "Copilot: Accept all",
		})
	end,
}
