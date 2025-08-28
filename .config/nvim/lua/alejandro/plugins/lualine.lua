return {
	"nvim-lualine/lualine.nvim",
	dependencies = {
		"stevearc/conform.nvim",
		"nvim-tree/nvim-web-devicons",
		"mfussenegger/nvim-dap",
		"mfussenegger/nvim-lint",
	},
	config = function()
		local lualine = require("lualine")
		local conform = require("conform")
		local lint = require("lint")
		local dap = require("dap")

		local function cwd()
			local home_dir = vim.fn.expand("~")
			local current_dir = vim.fn.getcwd()
			if current_dir:sub(1, #home_dir) == home_dir then
				return "~" .. current_dir:sub(#home_dir + 1)
			else
				return current_dir
			end
		end

		local function dap_status()
			if dap.session() then
				return "󰨰"
			else
				return ""
			end
		end

		local function lsps()
			local bufnr = vim.api.nvim_get_current_buf()

			local clients = vim.lsp.get_clients({ bufnr = bufnr })
			if next(clients) == nil then
				return ""
			end

			local c = {}
			for _, client in pairs(clients) do
				if client.name == "GitHub Copilot" then
					table.insert(c, " ")
				else
					table.insert(c, client.name)
				end
			end
			return table.concat(c, " / ")
		end

		local function formatter()
			local formatters = {}
			for _, f in ipairs(conform.list_formatters()) do
				table.insert(formatters, f.name)
			end
			return table.concat(formatters, " / ")
		end

		local function linter()
			local linters = lint.linters_by_ft[vim.bo.filetype] or {}
			return table.concat(linters, " / ")
		end

		lualine.setup({
			sections = {
				lualine_a = { "mode" },
				lualine_b = { "branch" },
				lualine_c = { cwd, { "filename", path = 1 }, "diagnostics" },
				lualine_x = {},
				lualine_y = { lsps, formatter, linter },
				lualine_z = { dap_status, "progress" },
			},
			options = {
				section_separators = {},
				component_separators = { left = "/", right = "/" },
			},
		})
	end,
}
