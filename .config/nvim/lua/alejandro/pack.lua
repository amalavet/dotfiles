local specs = {}
local root = vim.fn.stdpath("config") .. "/lua/alejandro/plugins"
for _, f in ipairs(vim.fn.globpath(root, "*.lua", false, true)) do
	vim.list_extend(specs, require("alejandro.plugins." .. vim.fn.fnamemodify(f, ":t:r")))
end
require("alejandro.pack_loader").setup(specs)

vim.keymap.set("n", "<leader>z", vim.pack.update, { desc = "Pack: Update" })
