return {
	"olimorris/codecompanion.nvim",
	dependencies = {
		"nvim-lua/plenary.nvim",
		"nvim-treesitter/nvim-treesitter",
		"hrsh7th/nvim-cmp",
		"nvim-telescope/telescope.nvim",
		{ "stevearc/dressing.nvim", opts = {} },
	},
	config = function()
		require("codecompanion").setup({
			strategies = {
				chat = {
					adapter = "copilot",
				},
				inline = {
					adapter = "copilot",
				},
			},
		})

		vim.keymap.set("n", "<Leader>m", ":CodeCompanionChat<CR>", { desc = "Code companion chat" })
	end,
}
