vim.o.nu = true
vim.o.relativenumber = true
vim.o.expandtab = true
vim.o.smartindent = true
vim.o.scrolloff = 20
vim.o.splitbelow = true
vim.o.cursorline = true
vim.o.splitright = true
vim.o.laststatus = 3
vim.o.showmode = false
vim.o.showcmd = false
vim.o.hidden = true
vim.o.foldmethod = "expr"
vim.o.foldexpr = "nvim_treesitter#foldexpr()"
vim.o.foldenable = false
vim.o.clipboard = "unnamedplus"
vim.opt.fillchars = { eob = " " }
vim.opt.signcolumn = "yes"
vim.opt.wrap = true
vim.opt.breakindent = true
vim.opt.linebreak = true
vim.o.winborder = "single"

-- Set cursor in command mode to a vertical bar
vim.opt.guicursor:append("c:ver25")

-- autoread the file when changed outside of vim
vim.o.autoread = true
vim.api.nvim_create_autocmd({ "BufEnter", "CursorHold", "CursorHoldI", "FocusGained" }, {
	command = "if mode() != 'c' | checktime | endif",
	pattern = { "*" },
})

vim.o.tabstop = 4
vim.o.shiftwidth = 4
vim.api.nvim_create_autocmd({ "BufEnter", "BufNewFile" }, {
	command = "setlocal shiftwidth=2 tabstop=2",
	pattern = { "*.tf", "*.json" },
})
