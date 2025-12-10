return {
	"stevearc/conform.nvim",
	config = function()
		local conform = require("conform")
		conform.setup({
			formatters_by_ft = {
				lua = { "stylua" },
				python = { "isort", "black" },
				go = { "gofumpt", "goimports", "golines" },
				bash = { "shfmt" },
				zsh = { "shfmt" },
				typescript = { "prettierd" },
				typescriptreact = { "prettierd" },
				javascriptreact = { "prettierd" },
				javascript = { "prettierd" },
				json = { "prettierd" },
				jsonc = { "prettierd" },
				css = { "prettierd" },
				html = { "prettierd" },
				yaml = { "prettierd" },
				markdown = { "prettierd" },
				proto = { "buf" },
				rust = { "rustfmt" },
				terraform = { "terraform_fmt" },
				svelte = { "prettier" },
				ruby = { "rubyfmt" },
				vue = { "prettierd" },
				solidity = { "solidity" },
				cue = { "cue_fmt" },
				jsonnet = { "jsonnetfmt" },
			},
			formatters = {
				solidity = {
					command = "prettier",
					args = { "--write", "--plugin=prettier-plugin-solidity", "$FILENAME" },
					stdin = false,
				},
				golines = {
					args = { "--max-len=130" },
				},
			},
		})

		local goFormat = true

		vim.keymap.set("n", "<leader>fm", conform.format, { desc = "Conform: Format" })
		vim.keymap.set("n", "<leader><leader>f", function()
			if goFormat then
				goFormat = false
				conform.formatters_by_ft.go = { "gofmt", "goimports" }
			else
				goFormat = true
				conform.formatters_by_ft.go = { "gofumpt", "goimports", "golines" }
			end
		end, { desc = "Conform: Toggle gofumpt and golines" })
	end,
}
