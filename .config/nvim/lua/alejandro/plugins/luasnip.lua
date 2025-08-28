return {
	"L3MON4D3/LuaSnip",

	config = function()
		local ls = require("luasnip")
		local s = ls.snippet
		local t = ls.text_node
		local i = ls.insert_node

		vim.keymap.set({ "i", "s" }, "<c-k>", function()
			if ls.expand_or_jumpable() then
				ls.expand_or_jump()
			end
		end, { silent = true, desc = "LuaSnip: Expand or jump" })

		vim.keymap.set({ "i", "s" }, "<c-j>", function()
			if ls.jumpable(-1) then
				ls.jump(-1)
			end
		end, { silent = true, desc = "LuaSnip: Jump backwards" })

		vim.keymap.set("i", "<c-l>", function()
			if ls.choice_active() then
				ls.change_choice(1)
			end
		end, { silent = true, desc = "LuaSnip: Change choice" })

		ls.add_snippets("go", {
			s("no", {
				t("//nolint:"),
				i(1),
			}),
			s("ie", {
				t("if err != nil {"),
				t({ "", "\treturn " }),
				i(1),
				t("err"),
				t({ "", "}" }),
			}),
			s("func", {
				t("func "),
				i(1),
				t("("),
				i(2),
				t(") "),
				i(3),
				t("{"),
				t({ "", "\t" }),
				i(0),
				t({ "", "}" }),
			}),
		})
	end,
}
