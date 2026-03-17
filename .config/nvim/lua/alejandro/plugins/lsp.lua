return {
	"neovim/nvim-lspconfig",
	dependencies = {
		"hrsh7th/cmp-nvim-lsp",
		"folke/lazydev.nvim",
		"ibhagwan/fzf-lua",
	},

	config = function()
		local cmp = require("cmp_nvim_lsp")
		vim.lsp.config("*", {
			capabilities = cmp.default_capabilities(),
		})
		vim.lsp.inline_completion.enable(true)

		require("lazydev").setup()

		vim.api.nvim_create_autocmd("LspAttach", {
			group = vim.api.nvim_create_augroup("UserLspConfig", {}),
			callback = function(ev)
				local fzf = require("fzf-lua")
				local keymap = vim.keymap
				local opts = { buffer = ev.buf, silent = true }
				local lsp = vim.lsp.buf

				-- Remove default LSP keymaps that conflict with custom ones
				pcall(keymap.del, "n", "gri")
				pcall(keymap.del, "x", "gra")
				pcall(keymap.del, "n", "gra")
				pcall(keymap.del, "n", "grr")
				pcall(keymap.del, "n", "grn")
				pcall(keymap.del, "n", "grt")

				opts.desc = "LSP: Restart LSP"
				keymap.set("n", "<leader>R", "<cmd>LspRestart<CR>", opts)

				opts.desc = "LSP: Rename symbol"
				keymap.set("n", "<leader>r", lsp.rename, opts)

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
				keymap.set("n", "K", lsp.hover, opts)

				opts.desc = "LSP: Code actions"
				keymap.set({ "n", "v" }, "<leader>ca", lsp.code_action, opts)

				vim.keymap.set("i", "<Right>", function()
					if not vim.lsp.inline_completion.get() then
						return "<Right>"
					end
				end, {
					expr = true,
					replace_keycodes = true,
					desc = "Get the current inline completion",
				})

				-- Only accept first word
				--
				-- This is a bit hacky,
				vim.keymap.set("i", "<S-Right>", function()
					if
						not vim.lsp.inline_completion.get({
							on_accept = function(item)
								if type(item.insert_text) == "string" then
									local text = item.insert_text
									local prefix_len = 0
									if item.range then
										local cursor = vim.api.nvim_win_get_cursor(0)
										local cursor_col = cursor[2] -- 0-indexed
										local cursor_row = cursor[1] - 1 -- 0-indexed
										if cursor_row == item.range.start.row then
											prefix_len = math.max(0, cursor_col - item.range.start.col)
										end
									end
									local prefix = text:sub(1, prefix_len)
									local rest = text:sub(prefix_len + 1)
									local first_word = rest:match("^([ \t]*%S+)")
									if not first_word then
										return nil
									end
									item.insert_text = prefix .. first_word
								end
								return item
							end,
						})
					then
						return "<S-Right>"
					end
				end, {
					expr = true,
					replace_keycodes = true,
					desc = "Accept first word of inline completion",
				})
			end,
		})
	end,
}
