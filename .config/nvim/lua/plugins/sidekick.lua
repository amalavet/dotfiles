local herdr = require("lib.herdr")
local ai_pane

local function find_ai_pane()
	local agents = herdr.call({ "agent", "list" })
	for _, a in ipairs(agents and agents.agents or {}) do
		if a.agent == "pi" and a.workspace_id == vim.env.HERDR_WORKSPACE_ID and a.pane_id ~= vim.env.HERDR_PANE_ID then
			ai_pane = a.pane_id
		end
	end
end

local function stash_ai_pane()
	return herdr.call({ "pane", "move", ai_pane, "--new-tab", "--label", "pi", "--no-focus" })
end

local function restore_ai_pane()
	return herdr.call({
		"pane",
		"move",
		ai_pane,
		"--tab",
		vim.env.HERDR_TAB_ID,
		"--split",
		"right",
		"--ratio",
		"0.5",
		"--focus",
	})
end

local function toggle_ai_pane()
	if not herdr.is_active() then
		require("sidekick.cli").toggle({ name = "pi", focus = true })
		return
	end

	if not ai_pane then
		find_ai_pane()
	end
	local info = ai_pane and herdr.call({ "pane", "get", ai_pane })
	if not info then
		ai_pane = nil
		require("sidekick.cli").toggle({ name = "pi", focus = true })
		return
	end

	local moved
	if info.pane.tab_id == vim.env.HERDR_TAB_ID then
		moved = stash_ai_pane()
	else
		moved = restore_ai_pane()
	end
	if moved and moved.move_result then
		ai_pane = moved.move_result.pane.pane_id
	end
end

local function send_to_pi(opts)
	if herdr.is_active() then
		if not ai_pane then
			find_ai_pane()
		end
		if ai_pane then
			local screen = herdr.run({ "agent", "read", ai_pane, "--lines", "8" })
			if screen and screen:find("─ NORMAL ", 1, true) then
				herdr.call({ "agent", "send-keys", ai_pane, "i" })
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
				require("sidekick.cli").prompt(function(text)
					if text then
						send_to_pi({ text = text })
					end
				end)
			end, { desc = "Sidekick Select Prompt" })
		end,
	},
}
