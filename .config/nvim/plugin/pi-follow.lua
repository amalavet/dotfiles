if not vim.env.HERDR_TAB_ID then
	return
end

pcall(vim.fn.serverstart, "/tmp/nvim-herdr-" .. vim.env.HERDR_TAB_ID:gsub("[^%w]", "_") .. ".sock")

local function is_float(win)
	return vim.api.nvim_win_get_config(win).relative ~= ""
end

function _G.PiFollowOpen(path)
	if vim.g.pi_follow == false then
		return
	end
	if not is_float(0) then
		vim.cmd("drop " .. vim.fn.fnameescape(path))
		vim.cmd("checktime")
		return
	end
	local buf = vim.fn.bufadd(path)
	vim.fn.bufload(buf)
	vim.bo[buf].buflisted = true
	local target = vim.fn.win_getid(vim.fn.winnr("#"))
	for _, win in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
		if not is_float(win) and (vim.api.nvim_win_get_buf(win) == buf or target == 0 or is_float(target)) then
			target = win
		end
	end
	vim.api.nvim_win_set_buf(target, buf)
	vim.cmd("checktime " .. buf)
end

vim.keymap.set("n", "<leader><leader>p", function()
	vim.g.pi_follow = vim.g.pi_follow == false
	vim.notify("pi follow " .. (vim.g.pi_follow and "on" or "off"))
end, { desc = "Toggle pi follow" })
