return {
	{ src = "https://github.com/nvim-treesitter/nvim-treesitter-textobjects", version = "main" },
	{ src = "https://github.com/nvim-treesitter/nvim-treesitter-context" },
	{ src = "https://github.com/windwp/nvim-ts-autotag" },
	{
		src = "https://github.com/ngynkvn/gotmpl.nvim",
		config = function()
			require("gotmpl").setup()
		end,
	},
	{
		src = "https://github.com/nvim-treesitter/nvim-treesitter",
		version = "main",
		config = function()
			require("nvim-ts-autotag").setup()
			require("nvim-treesitter").setup()

			local parsers = {
				"bash",
				"c",
				"cpp",
				"css",
				"cue",
				"dockerfile",
				"go",
				"gomod",
				"gosum",
				"gotmpl",
				"html",
				"javascript",
				"json",
				"jsonnet",
				"lua",
				"luadoc",
				"markdown",
				"markdown_inline",
				"proto",
				"python",
				"query",
				"ruby",
				"rust",
				"solidity",
				"svelte",
				"terraform",
				"toml",
				"tsx",
				"typescript",
				"vim",
				"vimdoc",
				"yaml",
			}
			require("nvim-treesitter").install(parsers)

			vim.api.nvim_create_autocmd("FileType", {
				callback = function(ev)
					local ok = pcall(vim.treesitter.start, ev.buf)
					if ok then
						vim.bo[ev.buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
					end
				end,
			})

			require("nvim-treesitter-textobjects").setup({
				select = { lookahead = true },
				move = { set_jumps = true },
			})

			local sel = require("nvim-treesitter-textobjects.select")
			local mv = require("nvim-treesitter-textobjects.move")
			local function map(modes, lhs, fn, desc)
				vim.keymap.set(modes, lhs, fn, { desc = desc, silent = true })
			end

			map({ "x", "o" }, "af", function()
				sel.select_textobject("@function.outer", "textobjects")
			end, "Select around function")
			map({ "x", "o" }, "if", function()
				sel.select_textobject("@function.inner", "textobjects")
			end, "Select inside function")
			map({ "x", "o" }, "ac", function()
				sel.select_textobject("@class.outer", "textobjects")
			end, "Select around class")
			map({ "x", "o" }, "ic", function()
				sel.select_textobject("@class.inner", "textobjects")
			end, "Select inside class")

			map("n", "]]", function()
				mv.goto_next_start("@function.outer", "textobjects")
			end, "Goto next function start")
			map("n", "]m", function()
				mv.goto_next_start("@class.outer", "textobjects")
			end, "Goto next class start")
			map("n", "][", function()
				mv.goto_next_end("@function.outer", "textobjects")
			end, "Goto next function end")
			map("n", "]M", function()
				mv.goto_next_end("@class.outer", "textobjects")
			end, "Goto next class end")
			map("n", "[[", function()
				mv.goto_previous_start("@function.outer", "textobjects")
			end, "Goto prev function start")
			map("n", "[m", function()
				mv.goto_previous_start("@class.outer", "textobjects")
			end, "Goto prev class start")
			map("n", "[]", function()
				mv.goto_previous_end("@function.outer", "textobjects")
			end, "Goto prev function end")
			map("n", "[M", function()
				mv.goto_previous_end("@class.outer", "textobjects")
			end, "Goto prev class end")
		end,
	},
}
