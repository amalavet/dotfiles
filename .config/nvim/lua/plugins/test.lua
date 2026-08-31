return {
	{
		src = "https://github.com/vim-test/vim-test",
		config = function()
			local dap = require("dap")
			local herdr = require("lib.herdr")
			local test_pane

			local function find_test_pane()
				local result = herdr.call({ "pane", "list", "--workspace", vim.env.HERDR_WORKSPACE_ID })
				for _, pane in ipairs(result and result.panes or {}) do
					if pane.tab_id == vim.env.HERDR_TAB_ID and pane.label == "tests" then
						return pane.pane_id
					end
				end
			end

			local function create_test_pane()
				local result = herdr.call({ "pane", "layout", "--pane", vim.env.HERDR_PANE_ID })
				local top_left
				for _, pane in ipairs(result and result.layout.panes or {}) do
					if
						not top_left
						or pane.rect.y < top_left.rect.y
						or (pane.rect.y == top_left.rect.y and pane.rect.x < top_left.rect.x)
					then
						top_left = pane
					end
				end
				if not top_left then
					return
				end

				result = herdr.call({
					"pane",
					"split",
					top_left.pane_id,
					"--direction",
					"down",
					"--ratio",
					"0.3",
					"--cwd",
					vim.fn.getcwd(),
					"--no-focus",
				})
				local pane_id = result and result.pane.pane_id
				if pane_id then
					herdr.call({ "pane", "rename", pane_id, "tests" })
					herdr.call({ "pane", "swap", "--source-pane", pane_id, "--target-pane", top_left.pane_id })
				end
				return pane_id
			end

			local function run_in_test_pane(cmd)
				local info = test_pane and herdr.call({ "pane", "get", test_pane })
				if not (info and info.pane.tab_id == vim.env.HERDR_TAB_ID) then
					test_pane = find_test_pane() or create_test_pane()
				end
				if test_pane then
					herdr.call({ "pane", "run", test_pane, cmd })
				end
			end

			local function dlv_debug(cmd)
				local _, _, test_name = string.find(cmd, "-run '([^$]+)")
				local _, _, file_path = string.find(cmd, " ([^%s]+)$")

				if file_path and test_name then
					local dlv_cmd = string.format(
						"clear;CGO_ENABLED=0 dlv test --headless --listen=:2345 --api-version=2 %s -- -test.run %s$",
						file_path,
						test_name
					)

					if herdr.is_active() then
						run_in_test_pane(dlv_cmd)
					else
						vim.fn.jobstart({ "sh", "-c", dlv_cmd }, { detach = true })
					end
					dap.run({
						type = "remote",
						name = "Attach to Remote",
						request = "attach",
						mode = "remote",
					})
				end
			end

			vim.g["test#strategy"] = herdr.is_active() and "herdr" or "neovim"
			vim.g["test#go#gotest#options"] = "-v"
			vim.g["test#custom_strategies"] = {
				herdr = run_in_test_pane,
				dlv_debug = dlv_debug,
			}

			local function debug_nearest_test()
				local current_strategy = vim.g["test#strategy"]
				vim.g["test#strategy"] = "dlv_debug"
				vim.cmd("TestNearest")
				vim.g["test#strategy"] = current_strategy
			end

			-- Regular test running
			vim.keymap.set("n", "<leader>t", ":TestNearest<CR>", { desc = "Test: Run nearest" })
			vim.keymap.set("n", "<leader>T", ":TestFile<CR>", { desc = "Test: Run file" })

			-- Debug nearest test
			vim.keymap.set("n", "<leader><leader>t", debug_nearest_test, { desc = "Test: Debug nearest" })
		end,
	},
}
