return {
	"olimorris/codecompanion.nvim",
	opts = {},
	dependencies = {
		"nvim-lua/plenary.nvim",
	},
	config = function()
		require("codecompanion").setup({
			strategies = {
				chat = {
					adapter = "anthropic",
					model = "claude-sonnet-4",
				},
				inline = {
					adapter = "anthropic",
				},
			},
			adapters = {
				http = {
					anthropic = function()
						return require("codecompanion.adapters").extend("anthropic", {
							env = {
								api_key = "cmd:op read 'op://Personal/Claude Vim/credential' --no-newline",
							},
						})
					end,
				},
			},
			display = {
				chat = { window = { layout = "vertical", position = "right", width = 0.4, full_height = true } },
			},
		})

		vim.keymap.set("n", "<Leader>c", ":CodeCompanionChat Toggle<CR>", { desc = "Toggle CodeCompanionChat chat" })
	end,
}
