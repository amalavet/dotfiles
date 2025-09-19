return {
	"folke/trouble.nvim",
	config = function()
		local trouble = require("trouble")

		vim.keymap.set("n", "<leader>dt", function()
			trouble.toggle()
		end, { desc = "Diagnostics: Toggle" })
		vim.keymap.set("n", "<leader>do", function()
			trouble.open({ mode = "diagnostics" })
		end, { desc = "Diagnostics: Open" })
		vim.keymap.set("n", "<leader>dc", trouble.close, { desc = "Diagnostics: Close" })
		vim.keymap.set("n", "<leader>dh", vim.diagnostic.open_float, { desc = "Diagnostics: Hover" })

		-- DiagnosticVirtualTextError xxx guifg=#db4b4b guibg=#2d202a
		-- DiagnosticVirtualTextWarn xxx guifg=#e0af68 guibg=#2e2a2d
		-- DiagnosticVirtualTextInfo xxx guifg=#0db9d7 guibg=#192b38
		-- DiagnosticVirtualTextHint xxx guifg=#1abc9c guibg=#1a2b32

		vim.api.nvim_set_hl(0, "MyErrorHighlight", { bg = "#2d202a" })
		vim.api.nvim_set_hl(0, "MyWarnHighlight", { bg = "#2e2a2d" })
		vim.api.nvim_set_hl(0, "MyInfoHighlight", { bg = "#192b38" })
		vim.api.nvim_set_hl(0, "MyHintHighlight", { bg = "#1a2b32" })

		vim.diagnostic.config({
			float = {
				source = "if_many",
			},
			severity_sort = true,
			signs = {
				text = {
					[vim.diagnostic.severity.ERROR] = "■",
					[vim.diagnostic.severity.WARN] = "■",
					[vim.diagnostic.severity.INFO] = "■",
					[vim.diagnostic.severity.HINT] = "■",
				},
				linehl = {
					[vim.diagnostic.severity.ERROR] = "MyErrorHighlight",
					[vim.diagnostic.severity.WARN] = "MyWarnHighlight",
					[vim.diagnostic.severity.INFO] = "MyInfoHighlight",
					[vim.diagnostic.severity.HINT] = "MyHintHighlight",
				},
				numhl = {
					[vim.diagnostic.severity.ERROR] = "DiagnosticVirtualTextError",
					[vim.diagnostic.severity.WARN] = "DiagnosticVirtualTextWarn",
					[vim.diagnostic.severity.INFO] = "DiagnosticVirtualTextInfo",
					[vim.diagnostic.severity.HINT] = "DiagnosticVirtualTextHint",
				},
			},
		})
	end,
}
