return {
	"pwntester/octo.nvim",
	dependencies = { "nvim-lua/plenary.nvim", "nvim-telescope/telescope.nvim", "nvim-tree/nvim-web-devicons" },
	config = function()
		require("octo").setup()

		-- Octo PRs
		vim.keymap.set("n", "<Leader>fp", ":Octo pr list<CR>", { desc = "Search PR's (Octo)" })
		vim.keymap.set("n", "<Leader>fi", ":Octo issue list<CR>", { desc = "Search issues (Octo)" })
		vim.keymap.set("n", "<Leader>oic", ":Octo issue create<CR>", { desc = "Create issue (Octo)" })
		vim.keymap.set("n", "<Leader>opc", ":Octo pr create<CR>", { desc = "Create PR (Octo)" })
		vim.keymap.set("n", "<Leader>oph", ":Octo pr checks<CR>", { desc = "Show PR checks (Octo)" })
	end,
}
