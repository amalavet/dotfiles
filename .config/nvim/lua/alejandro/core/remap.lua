vim.g.mapleader = " "

-- Resize mappings
vim.keymap.set("n", "<S-Down>", "<cmd>resize -3<CR>", { silent = true, desc = "Horizontal window resize" })
vim.keymap.set("n", "<S-Up>", "<cmd>resize +3<CR>", { silent = true, desc = "Horizontal window resize" })
vim.keymap.set("n", "<S-Left>", "<cmd>vertical resize -10<CR>", { silent = true, desc = "Vertical window resize" })
vim.keymap.set("n", "<S-Right>", "<cmd>vertical resize +10<CR>", { silent = true, desc = "Vertical window resize" })

-- Window mappings
vim.keymap.set("n", "<leader>v", "<cmd>vsp<CR>", { noremap = true, desc = "Vertical split" })
vim.keymap.set("n", "<leader>h", "<cmd>sp<CR>", { noremap = true, desc = "Horizontal split" })

-- Move around faster
vim.keymap.set("n", "<Down>", "5j", { noremap = true, silent = true })
vim.keymap.set("n", "<Up>", "5k", { noremap = true, silent = true })
vim.keymap.set("n", "<Left>", "5h", { noremap = true, silent = true })
vim.keymap.set("n", "<Right>", "5l", { noremap = true, silent = true })

vim.keymap.set("v", "<Down>", "5j", { noremap = true, silent = true })
vim.keymap.set("v", "<Up>", "5k", { noremap = true, silent = true })
vim.keymap.set("v", "<Left>", "5h", { noremap = true, silent = true })
vim.keymap.set("v", "<Right>", "5l", { noremap = true, silent = true })

-- Write/Quit
vim.keymap.set("n", "<leader>w", "<cmd>w<CR>", { noremap = true, silent = true, desc = "Write file" })
vim.keymap.set("n", "<leader>W", "<cmd>wa<CR>", { noremap = true, silent = true, desc = "Write all files" })
vim.keymap.set("n", "<leader>q", "<cmd>q<CR>", { noremap = true, silent = true, desc = "Quit" })
vim.keymap.set("n", "<leader>Q", "<cmd>qa!<CR>", { noremap = true, silent = true, desc = "Quit all files" })

-- Go to previous buffer
vim.keymap.set("n", "<leader>gp", "<cmd>b#<CR>", { noremap = true, silent = true, desc = "Goto previous buffer" })

-- Map redo to U
vim.keymap.set("n", "U", "<C-r>", { desc = "Redo" })

-- Map <leader>m to macro
vim.keymap.set("n", "<leader>M", "q", { silent = true, desc = "Start recording a macro" })
vim.keymap.set("n", "q", "<Nop>", { noremap = true, silent = true })

-- Map d and x to black hole register
vim.keymap.set("n", "x", '"_x', { noremap = true, silent = true })
vim.keymap.set("v", "x", '"_x', { noremap = true, silent = true })

-- Map <leader>c to clear highlight
vim.keymap.set("n", "<leader>ch", "<cmd>noh<CR>", { noremap = true, silent = true, desc = "Clear search highlight" })

-- Add //nolint: to the end of the line in normal mode
vim.keymap.set("n", "<leader>nl", "A //nolint:", { noremap = true, silent = true, desc = "Add //nolint: to end of line" })
