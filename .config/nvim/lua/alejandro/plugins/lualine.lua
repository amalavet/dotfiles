return {
	{ src = "https://github.com/mfussenegger/nvim-lint" },
	{
		src = "https://github.com/nvim-lualine/lualine.nvim",
		config = function()
			local lualine = require("lualine")
			local dap = require("dap")

			local function dap_status()
				if dap.session() then
					return "󰨰"
				else
					return ""
				end
			end

			lualine.setup({
				sections = {
					lualine_a = { "mode" },
					lualine_b = { "branch" },
					lualine_c = { { "filename", path = 3 }, "diagnostics" },
					lualine_x = {},
					lualine_y = {},
					lualine_z = { dap_status },
				},
				options = {
					section_separators = {},
					component_separators = { left = "", right = "" },
				},
			})
		end,
	},
}
