return {
	"pwntester/octo.nvim",
	dependencies = { "nvim-lua/plenary.nvim", "nvim-telescope/telescope.nvim", "nvim-tree/nvim-web-devicons" },
	config = function()
		require("octo").setup()

		-- Octo PRs
		vim.keymap.set("n", "<Leader>op", ":Octo pr list<CR>", { desc = "Search PR's (Octo)" })
		vim.keymap.set("n", "<Leader>oi", ":Octo issue list<CR>", { desc = "Search issues (Octo)" })
		vim.keymap.set("n", "<Leader>ocp", ":Octo pr create<CR>", { desc = "Create PR (Octo)" })
		vim.keymap.set("n", "<Leader>oci", ":Octo issue create<CR>", { desc = "Create issue (Octo)" })
	end,
}
