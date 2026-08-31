local specs = {}
local root = vim.fn.stdpath("config") .. "/lua/plugins"
for _, f in ipairs(vim.fn.globpath(root, "*.lua", false, true)) do
	vim.list_extend(specs, require("plugins." .. vim.fn.fnamemodify(f, ":t:r")))
end
require("pack_loader").setup(specs)

vim.keymap.set("n", "<leader>z", vim.pack.update, { desc = "Pack: Update" })
