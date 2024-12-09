return {
	"stevearc/conform.nvim",
	opts = {},
	config = function()
		require("conform").setup({
			formatters_by_ft = {
				lua = { "stylua" },
				elm = { "elm-format" },
				-- javascript = { "prettier" },
				typescript = { "prettier" },
				typescriptreact = { "prettier" },
				css = { "prettier" },
				svelte = { "prettier" },
			},
			format_after_save = {
				lsp_fallback = true,
			},
		})
	end,
}
