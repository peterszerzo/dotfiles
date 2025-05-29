return {
	"pwntester/octo.nvim",
	dependencies = { "nvim-lua/plenary.nvim", "nvim-telescope/telescope.nvim", "nvim-tree/nvim-web-devicons" },
	config = function()
		require("octo").setup()

		-- Octo PRs
		vim.keymap.set("n", "<Leader>tpc", ":Octo pr<CR>", { desc = "Current PR (Octo)" })
		vim.keymap.set("n", "<Leader>tpl", ":Octo pr list<CR>", { desc = "List PR's (Octo)" })
		vim.keymap.set("n", "<Leader>tpn", ":Octo pr create<CR>", { desc = "New PR (Octo)" })
	end,
}
