return {
	"nvim-tree/nvim-tree.lua",
	dependencies = {
		"nvim-tree/nvim-web-devicons",
	},
	config = function()
		local nvim_tree = require("nvim-tree")

		nvim_tree.setup()

		vim.keymap.set({ "n" }, "<Leader>tf", ":NvimTreeFindFile<CR>")
		vim.keymap.set({ "n" }, "<Leader>tt", ":NvimTreeToggle<CR>")
	end,
}
