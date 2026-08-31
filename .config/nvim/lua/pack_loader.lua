-- Thin wrapper over vim.pack. Spec: { src, version, config, event, cmd, ft }
local M = {}

function M.setup(specs)
	local eager = {}
	for _, s in ipairs(specs) do
		if not (s.event or s.cmd or s.ft) then
			table.insert(eager, { src = s.src, version = s.version })
		end
	end
	vim.pack.add(eager, { confirm = false })

	for _, s in ipairs(specs) do
		local loaded = false
		local function load()
			if loaded then
				return
			end
			loaded = true
			vim.pack.add({ { src = s.src, version = s.version } }, { confirm = false })
			if s.config then
				s.config()
			end
		end
		if s.event then
			vim.api.nvim_create_autocmd(s.event, { once = true, callback = vim.schedule_wrap(load) })
		end
		if s.cmd then
			local cmds = type(s.cmd) == "table" and s.cmd or { s.cmd }
			for _, c in ipairs(cmds) do
				vim.api.nvim_create_user_command(c, function(a)
					for _, x in ipairs(cmds) do
						pcall(vim.api.nvim_del_user_command, x)
					end
					load()
					vim.cmd({
						cmd = c,
						bang = a.bang,
						args = a.fargs,
						range = a.range > 0 and { a.line1, a.line2 } or nil,
					})
				end, { nargs = "*", bang = true, range = true })
			end
		end
		if s.ft then
			vim.api.nvim_create_autocmd("FileType", { pattern = s.ft, once = true, callback = load })
		end
		if not (s.event or s.cmd or s.ft) and s.config then
			s.config()
		end
	end
end

return M
