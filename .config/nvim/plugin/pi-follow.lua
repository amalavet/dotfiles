if not vim.env.HERDR_TAB_ID then
	return
end

local sock = "/tmp/nvim-herdr-" .. vim.env.HERDR_TAB_ID:gsub("[^%w]", "_") .. ".sock"
if not pcall(vim.fn.serverstart, sock) then
	vim.fn.delete(sock)
	pcall(vim.fn.serverstart, sock)
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
		if v and #items < 9 and not list.config.equals(v, item) then
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
	vim.schedule(function()
		vim.cmd("checktime")
		pcall(harpoon_add, path)
	end)
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
