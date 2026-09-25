if not vim.env.HERDR_TAB_ID then
	return
end

pcall(vim.fn.serverstart, "/tmp/nvim-herdr-" .. vim.env.HERDR_TAB_ID:gsub("[^%w]", "_") .. ".sock")

local function is_float(win)
	return vim.api.nvim_win_get_config(win).relative ~= ""
end

local function harpoon_add(path)
	local ok, harpoon = pcall(require, "harpoon")
	if not ok then
		return
	end
	local list = harpoon:list()
	local item = list.config.create_list_item(list.config, vim.fn.fnamemodify(path, ":."))
	local items = { item }
	for i = 1, list._length do
		local v = list.items[i]
		if v and #items < 6 and not list.config.equals(v, item) then
			table.insert(items, v)
		end
	end
	list.items, list._length = items, #items
	vim.cmd("doautocmd User")
end

function _G.PiFollowOpen(path)
	if vim.g.pi_follow == false then
		return
	end
	if not is_float(0) then
		vim.cmd("drop " .. vim.fn.fnameescape(path))
		vim.cmd("checktime")
		harpoon_add(path)
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
	harpoon_add(path)
end

function _G.PiFollowSync(files)
	vim.g.pi_follow_seen = os.time()
	vim.g.pi_follow_files = files
end

vim.keymap.set("n", "<leader><leader>P", function()
	local count = 0
	for _, path in ipairs(vim.g.pi_follow_files or {}) do
		if vim.fn.filereadable(path) == 1 then
			local buf = vim.fn.bufadd(path)
			vim.fn.bufload(buf)
			vim.bo[buf].buflisted = true
			count = count + 1
		end
	end
	vim.notify("pi follow: opened " .. count .. " files")
end, { desc = "Open files edited by pi this session" })

vim.keymap.set("n", "<leader><leader>p", function()
	vim.g.pi_follow = vim.g.pi_follow == false
	vim.notify("pi follow " .. (vim.g.pi_follow and "on" or "off"))
end, { desc = "Toggle pi follow" })
