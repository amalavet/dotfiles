vim.api.nvim_create_autocmd("LspAttach", {
	group = vim.api.nvim_create_augroup("UserLspConfig", {}),
	callback = function(ev)
		local fzf = require("fzf-lua")
		local keymap = vim.keymap
		local opts = { buffer = ev.buf, silent = true }

		opts.desc = "LSP: Restart LSP"
		keymap.set("n", "<leader>R", "<cmd>LspRestart<CR>", opts)

		opts.desc = "LSP: Rename symbol"
		keymap.set("n", "<leader>r", vim.lsp.buf.rename, opts)

		opts.desc = "LSP: Type definitions"
		keymap.set("n", "gt", fzf.lsp_typedefs, opts)

		opts.desc = "LSP: Go to definition"
		keymap.set("n", "gd", fzf.lsp_definitions, opts)

		opts.desc = "LSP: Go to implementations"
		keymap.set("n", "gi", fzf.lsp_implementations, opts)

		opts.desc = "LSP: Show references"
		keymap.set("n", "gr", fzf.lsp_references, opts)

		opts.desc = "LSP: Show declarations"
		keymap.set("n", "gD", fzf.lsp_declarations, opts)

		opts.desc = "LSP: Show hover documentation"
		keymap.set("n", "K", vim.lsp.buf.hover, opts)

		opts.desc = "LSP: Code actions"
		keymap.set({ "n", "v" }, "<leader>ca", vim.lsp.buf.code_action, opts)
	end,
})
