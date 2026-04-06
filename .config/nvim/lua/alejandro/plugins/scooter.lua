return {
	"folke/snacks.nvim",
	config = function()
		local _term = nil

		-- Called by  to open the selected file at the correct line from the  search list
		_G.EditLineFromScooter = function(file_path, line)
			if _term and _term:buf_valid() then
				_term:hide()
			end

			local current_path = vim.fn.expand("%:p")
			local target_path = vim.fn.fnamemodify(file_path, ":p")

			if current_path ~= target_path then
				vim.cmd.edit(vim.fn.fnameescape(file_path))
			end

			vim.api.nvim_win_set_cursor(0, { line, 0 })
		end

		local function is_terminal_running(term)
			if not term or not term:buf_valid() then
				return false
			end
			local channel = vim.fn.getbufvar(term.buf, "terminal_job_id")
			return channel and vim.fn.jobwait({ channel }, 0)[1] == -1
		end

		local _base = "scooter --hidden -E '*.svg,__pycache__/**,.git/**,*.ttf,*.dot,node_modules/**,.DS_Store,.svelte-kit/**'"

		local function open_()
			if is_terminal_running(_term) then
				_term:toggle()
			else
				_term = require("snacks").terminal.open(_base, {
					win = { position = "float" },
				})
			end
		end

		local function open__with_text(search_text)
			if _term and _term:buf_valid() then
				_term:close()
			end

			local escaped_text = vim.fn.shellescape(search_text:gsub("\r?\n", " "))
			_term = require("snacks").terminal.open(_base .. " --fixed-strings --search-text " .. escaped_text, {
				win = { position = "float" },
			})
		end

		vim.keymap.set("n", "<leader>fl", open_, { desc = "Open " })
		vim.keymap.set("v", "<leader>fv", function()
			local selection = vim.fn.getreg('"')
			vim.cmd('normal! "ay')
			open__with_text(vim.fn.getreg("a"))
			vim.fn.setreg('"', selection)
		end, { desc = "Search selected text in " })
	end,
}
