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

			local worktree_name = ""
			local function update_worktree()
				if vim.fn.findfile(".git", ".;") ~= "" then
					worktree_name = ""
				else
					worktree_name = ""
				end
			end
			update_worktree()
			vim.api.nvim_create_autocmd("DirChanged", { callback = update_worktree })

			lualine.setup({
				sections = {
					lualine_a = { "mode" },
					lualine_b = {
						"branch",
						function()
							return worktree_name
						end,
					},
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
