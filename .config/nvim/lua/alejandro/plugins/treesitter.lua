return {
	"nvim-treesitter/nvim-treesitter",
	build = ":TSUpdate",
	dependencies = {
		"nvim-treesitter/nvim-treesitter-textobjects",
		"nvim-treesitter/nvim-treesitter-context",
		"windwp/nvim-ts-autotag",
		{ "ngynkvn/gotmpl.nvim", opts = {} },
	},

	config = function()
		local autotag = require("nvim-ts-autotag")
		autotag.setup()
		local configs = require("nvim-treesitter.configs")
		configs.setup({
			auto_install = true,
			ensure_installed = { "lua" },
			sync_install = false,
			ignore_install = {},
			textobjects = {
				move = {
					enable = true,
					set_jumps = true, -- whether to set jumps in the jumplist
					goto_next_start = {
						["]]"] = { query = "@function.outer", desc = "Goto next function start" },
						["]m"] = { query = "@class.outer", desc = "Goto next class start" },
					},
					goto_next_end = {
						["]["] = { query = "@function.outer", desc = "Goto next function end" },
						["]M"] = { query = "@class.outer", desc = "Goto next class end" },
					},
					goto_previous_start = {
						["[["] = { query = "@function.outer", desc = "Goto previous function start" },
						["[m"] = { query = "@class.outer", desc = "Goto previous class start" },
					},
					goto_previous_end = {
						["[]"] = { query = "@function.outer", desc = "Goto previous function end" },
						["[M"] = { query = "@class.outer", desc = "Goto previous class end" },
					},
				},
				select = {
					enable = true,
					lookahead = true,
					keymaps = {
						["af"] = { query = "@function.outer", desc = "Select around function" },
						["if"] = { query = "@function.inner", desc = "Select inside function" },
						["ac"] = { query = "@class.outer", desc = "Select around class" },
						["ic"] = { query = "@class.inner", desc = "Select inside class" },
					},
				},
			},
			modules = {},
			highlight = { enable = true },
			indent = { enable = true },
		})
	end,
}
