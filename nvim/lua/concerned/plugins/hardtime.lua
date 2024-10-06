return {
	"m4xshen/hardtime.nvim",
	dependencies = { "MunifTanjim/nui.nvim", "nvim-lua/plenary.nvim" },
	opts = {},
	config = function()
		require("hardtime").setup({
			restricted_keys = {
				["+"] = {},
				["-"] = {},
				["<C-p>"] = {},
			},
		})
	end,
}
