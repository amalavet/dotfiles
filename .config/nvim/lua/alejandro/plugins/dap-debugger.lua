return {
	"mfussenegger/nvim-dap",
	dependencies = {
		"rcarriga/nvim-dap-ui",
		"nvim-neotest/nvim-nio",
		"leoluz/nvim-dap-go",
	},
	config = function()
		local dap = require("dap")
		local dapui = require("dapui")
		local dapgo = require("dap-go")

		dapgo.setup()

		dap.adapters.remote = {
			type = "server",
			host = "127.0.0.1",
			port = 2345,
			options = {
				initialize_timeout_sec = 20,
			},
		}

		local remote = {
			type = "remote",
			name = "Attach to Remote",
			request = "attach",
			mode = "remote",
		}

		dap.configurations.go = { remote }
		dap.configurations.python = { remote }

		-- Function to start remote debugging
		function StartGoRemoteDebug()
			dap.run({
				type = "remote",
				name = "Attach to Remote",
				request = "attach",
				mode = "remote",
			})
		end

		dapui.setup({
			layouts = {
				{
					elements = {
						{
							id = "repl",
							size = 0.25,
						},
						{
							id = "stacks",
							size = 0.25,
						},
						{
							id = "breakpoints",
							size = 0.25,
						},
						{
							id = "scopes",
							size = 0.25,
						},
					},
					position = "left",
					size = 50,
				},
			},
		})

		vim.keymap.set("n", "<F5>", dap.continue, { desc = "Debug: Continue" })
		vim.keymap.set("n", "<F6>", dap.terminate, { desc = "Debug: Terminate" })
		vim.keymap.set("n", "<F10>", dap.step_over, { desc = "Debug: Step Over" })
		vim.keymap.set("n", "<F11>", dap.step_into, { desc = "Debug: Step Into" })
		vim.keymap.set("n", "<F12>", dap.step_out, { desc = "Debug: Step Out" })
		vim.keymap.set("n", "<leader>b", dap.toggle_breakpoint, { desc = "Debug: Toggle breakpoint" })
		vim.keymap.set("n", "<leader>db", dapui.toggle, { desc = "Debug: Toggle console" })
		vim.keymap.set("n", "<leader>dr", StartGoRemoteDebug, { desc = "Debug: Start Go Remote Debug" })

		vim.fn.sign_define("DapBreakpoint", {
			text = "●",
			texthl = "Breakpoint",
			linehl = "BreakpointHighlight",
			numhl = "BreakpointHighlight",
		})

		vim.fn.sign_define("DapBreakpointRejected", { text = "●" })

		vim.fn.sign_define("DapLogPoint", {
			text = "◆",
			texthl = "Logpoint",
			linehl = "BreakpointHighlight",
			numhl = "BreakpointHighlight",
		})

		vim.fn.sign_define("DapStopped", {
			text = "",
			linehl = "StoppedHighlight",
			numhl = "StoppedHighlight",
			texthl = "StoppedHighlight",
		})

		vim.api.nvim_set_hl(0, "Breakpoint", { fg = "#ff0000" })
		vim.api.nvim_set_hl(0, "Logpoint", { fg = "#00ff00" })
		vim.api.nvim_set_hl(0, "BreakpointHighlight", { bg = "#333333" })
		vim.api.nvim_set_hl(0, "StoppedHighlight", { bg = "#7a6220" })
	end,
}
