local M = {}

function M.is_active()
	return vim.env.HERDR_ENV == "1"
end

function M.run(args)
	local command = vim.list_extend({ "herdr" }, args)
	local output = vim.fn.system(command)
	if vim.v.shell_error ~= 0 then
		return nil, output
	end
	return output
end

function M.call(args)
	local output, err = M.run(args)
	if not output then
		return nil, err
	end
	local ok, response = pcall(vim.json.decode, output)
	if not ok then
		return nil, output
	end
	return response.result
end

return M
