return {
	"pwntester/octo.nvim",
	dependencies = { "nvim-lua/plenary.nvim", "nvim-telescope/telescope.nvim", "nvim-tree/nvim-web-devicons" },
	config = function()
		require("octo").setup()

		-- Octo PRs
		vim.keymap.set("n", "<Leader>fp", ":Octo pr list<CR>")
		vim.keymap.set("n", "<Leader>fi", ":Octo issue list<CR>")
		vim.keymap.set("n", "<Leader>oic", ":Octo issue create<CR>")
		vim.keymap.set("n", "<Leader>opc", ":Octo pr create<CR>")
		vim.keymap.set("n", "<Leader>opm", ":Octo pr merge<CR>")
		vim.keymap.set("n", "<Leader>ors", ":Octo review start<CR>")
		vim.keymap.set("n", "<Leader>oru", ":Octo review submit<CR>")
	end,
}
