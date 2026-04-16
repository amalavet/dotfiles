return {
	{
		src = "https://github.com/folke/sidekick.nvim",
		config = function()
			require("sidekick").setup({ nes = { enabled = false } })
			vim.keymap.set("n", "<leader>ai", function()
				require("sidekick.cli").toggle({ focus = true })
			end, { desc = "Sidekick Toggle CLI" })
			vim.keymap.set({ "x", "n" }, "<leader>at", function()
				require("sidekick.cli").send({ msg = "{this}" })
			end, { desc = "Send This" })
			vim.keymap.set("n", "<leader>af", function()
				require("sidekick.cli").send({ msg = "{file}" })
			end, { desc = "Send File" })
			vim.keymap.set("x", "<leader>av", function()
				require("sidekick.cli").send({ msg = "{selection}" })
			end, { desc = "Send Visual Selection" })
			vim.keymap.set({ "n", "x" }, "<leader>ap", function()
				require("sidekick.cli").prompt()
			end, { desc = "Sidekick Select Prompt" })
		end,
	},
}
