return {
	"mason-org/mason.nvim",
	config = function()
		require("mason").setup()
		vim.api.nvim_create_autocmd({ "VimEnter" }, {
			callback = function()
				local ensure_installed = {
					-- Yaml
					"yamlfmt",
					"yaml-language-server",
					-- Frontend
					"vue-language-server",
					"svelte-language-server",
					"typescript-language-server",
					"prettierd",
					"prettier",
					"html-lsp",
					"css-lsp",
					"json-lsp",
					"css-variables-language-server",
					-- Python
					"python-lsp-server",
					"black",
					"isort",
					-- Rust
					"rustfmt",
					"rust-analyzer",
					-- Protobuf
					"buf",
					-- Lua
					"lua-language-server",
					"stylua",
					-- Go
					"gopls",
					"goimports",
					"gofumpt",
					"golangci-lint-langserver",
					-- Docker
					"dockerfile-language-server",
					"docker-compose-language-service",
					-- Bash
					"bash-language-server",
					"shfmt",
					-- Solidity
					"nomicfoundation-solidity-language-server",
					-- Terraform
					"terraform-ls",
				}
				for _, tool in ipairs(ensure_installed) do
					local tool_name = type(tool) == "string" and tool or tool[1]
					local installed = require("mason-registry").is_installed(tool_name)
					if not installed then
						if type(tool) == "string" then
							vim.cmd("MasonInstall " .. tool)
						else
							vim.cmd(string.format("MasonInstall %s@%s", tool[1], tool.version))
						end
					end
				end
			end,
		})
	end,
}
