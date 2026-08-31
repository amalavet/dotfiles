return {
	{
		src = "https://github.com/nvim-lualine/lualine.nvim",
		config = function()
			local lualine = require("lualine")
			lualine.setup({
				sections = {
					lualine_a = {
						{
							"mode",
							fmt = function(mode)
								return ({
									NORMAL = "N",
									INSERT = "I",
									VISUAL = "V",
									["V-LINE"] = "VL",
									["V-BLOCK"] = "VB",
									REPLACE = "R",
									COMMAND = "C",
									TERMINAL = "T",
								})[mode] or mode
							end,
						},
					},
					lualine_b = { "branch" },
					lualine_c = { { "filename", path = 3 }, "diagnostics" },
					lualine_x = {},
					lualine_y = {},
					lualine_z = {},
				},
				options = {
					section_separators = {},
					component_separators = { left = "", right = "" },
				},
			})
		end,
	},
}
