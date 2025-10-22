return {
	"folke/trouble.nvim",
	config = function()
		local trouble = require("trouble")
		local severity = vim.diagnostic.severity
		local diagnostic = vim.diagnostic
		local keymap = vim.keymap
		local hl = vim.api.nvim_set_hl

		keymap.set("n", "<leader>do", function()
			trouble.toggle("diagnostics")
		end, { desc = "Diagnostics: Open/Close" })
		keymap.set("n", "<leader>dh", diagnostic.open_float, { desc = "Diagnostics: Hover" })

		hl(0, "MyErrorHighlight", { bg = "#2d202a" })
		hl(0, "MyWarnHighlight", { bg = "#2e2a2d" })
		hl(0, "MyInfoHighlight", { bg = "#192b38" })
		hl(0, "MyHintHighlight", { bg = "#1a2b32" })

		diagnostic.config({
			float = {
				source = "if_many",
			},
			severity_sort = true,
			signs = {
				text = {
					[severity.ERROR] = " ",
					[severity.WARN] = " ",
					[severity.HINT] = "󰠠 ",
					[severity.INFO] = " ",
				},
				linehl = {
					[severity.ERROR] = "MyErrorHighlight",
					[severity.WARN] = "MyWarnHighlight",
					[severity.INFO] = "MyInfoHighlight",
					[severity.HINT] = "MyHintHighlight",
				},
				numhl = {
					[severity.ERROR] = "DiagnosticVirtualTextError",
					[severity.WARN] = "DiagnosticVirtualTextWarn",
					[severity.INFO] = "DiagnosticVirtualTextInfo",
					[severity.HINT] = "DiagnosticVirtualTextHint",
				},
			},
		})
	end,
}
