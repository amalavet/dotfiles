return {
	"vim-test/vim-test",
	dependencies = {
		"jgdavey/tslime.vim",
		"mfussenegger/nvim-dap",
	},
	config = function()
		local dap = require("dap")

		vim.g["test#strategy"] = "tslime"
		vim.g.tslime_always_current_session = 1
		vim.g.tslime_always_current_window = 1
		vim.g.tslime_autoset_pane = 1

		-- Function to debug nearest test with dlv
		local function debug_nearest_test()
			-- Store current strategy
			local current_strategy = vim.g["test#strategy"]

			-- Create custom strategy for dlv debug
			vim.g["test#custom_strategies"] = {
				dlv_debug = function(cmd)
					local _, _, test_name = string.find(cmd, "-run '([^$]+)")
					local _, _, file_path = string.find(cmd, " ([^%s]+)$")

					if file_path and test_name then
						-- Construct dlv debug command
						local dlv_cmd = string.format(
							"clear;CGO_ENABLED=0 dlv test --headless --listen=:12345 --api-version=2 %s -- -test.run %s$",
							file_path,
							test_name
						)

						vim.fn.Send_to_Tmux(dlv_cmd .. "\n")
						dap.run({
							type = "remote",
							name = "Attach to Remote",
							request = "attach",
							mode = "remote",
						})
					end
				end,
			}

			-- Temporarily set strategy to our custom one
			vim.g["test#strategy"] = "dlv_debug"

			-- Run the test
			vim.cmd("TestNearest")

			-- Restore original strategy
			vim.g["test#strategy"] = current_strategy
		end

		-- Regular test running
		vim.keymap.set("n", "<leader>t", ":TestNearest<CR>", { desc = "Test: Run nearest" })
		vim.keymap.set("n", "<leader>T", ":TestFile<CR>", { desc = "Test: Run file" })

		-- Debug nearest test
		vim.keymap.set("n", "<leader><leader>t", debug_nearest_test, { desc = "Test: Debug nearest" })
	end,
}
