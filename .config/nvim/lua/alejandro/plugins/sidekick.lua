local ai_pane

local function herdr(args)
	local out = vim.fn.system("herdr " .. args)
	local ok, decoded = pcall(vim.json.decode, out)
	return ok and decoded or nil
end

local function find_ai_pane()
	local agents = herdr("agent list")
	for _, a in ipairs(agents and agents.result.agents or {}) do
		if a.agent == "pi" and a.workspace_id == vim.env.HERDR_WORKSPACE_ID and a.pane_id ~= vim.env.HERDR_PANE_ID then
			ai_pane = a.pane_id
		end
	end
end

local function stash_ai_pane()
	return herdr("pane move " .. ai_pane .. " --new-tab --label pi --no-focus")
end

local function restore_ai_pane()
	return herdr("pane move " .. ai_pane .. " --tab " .. vim.env.HERDR_TAB_ID .. " --split right --ratio 0.5 --focus")
end

local function toggle_ai_pane()
	if vim.env.HERDR_ENV ~= "1" then
		require("sidekick.cli").toggle({ name = "pi", focus = true })
		return
	end

	if not ai_pane then
		find_ai_pane()
	end
	local info = ai_pane and herdr("pane get " .. ai_pane)
	if not (info and info.result) then
		ai_pane = nil
		require("sidekick.cli").toggle({ name = "pi", focus = true })
		return
	end

	local moved
	if info.result.pane.tab_id == vim.env.HERDR_TAB_ID then
		moved = stash_ai_pane()
	else
		moved = restore_ai_pane()
	end
	if moved and moved.result and moved.result.move_result then
		ai_pane = moved.result.move_result.pane.pane_id
	end
end

local function send_to_pi(opts)
	if vim.env.HERDR_ENV == "1" then
		if not ai_pane then
			find_ai_pane()
		end
		if ai_pane then
			local screen = vim.fn.system({ "herdr", "agent", "read", ai_pane, "--lines", "8" })
			if screen:find("─ NORMAL ", 1, true) then
				vim.fn.system({ "herdr", "agent", "send-keys", ai_pane, "i" })
			end
		end
	end
	opts.name = "pi"
	require("sidekick.cli").send(opts)
end

return {
	{
		src = "https://github.com/rmarganti/sidekick.nvim",
		version = "herdr",
		config = function()
			require("sidekick").setup({
				nes = { enabled = false },
				cli = {
					mux = {
						enabled = true,
						create = "split",
					},
				},
			})
			vim.keymap.set("n", "<leader>ai", toggle_ai_pane, { desc = "Sidekick Toggle CLI" })
			vim.keymap.set({ "x", "n" }, "<leader>at", function()
				send_to_pi({ msg = "{this}" })
			end, { desc = "Send This" })
			vim.keymap.set("n", "<leader>af", function()
				send_to_pi({ msg = "{file}" })
			end, { desc = "Send File" })
			vim.keymap.set("x", "<leader>av", function()
				send_to_pi({ msg = "{selection}" })
			end, { desc = "Send Visual Selection" })
			vim.keymap.set({ "n", "x" }, "<leader>ap", function()
				require("sidekick.cli").prompt(function(_, text)
					if text then
						send_to_pi({ text = text })
					end
				end)
			end, { desc = "Sidekick Select Prompt" })
		end,
	},
}
