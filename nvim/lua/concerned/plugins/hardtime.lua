return {
	"m4xshen/hardtime.nvim",
	dependencies = { "MunifTanjim/nui.nvim", "nvim-lua/plenary.nvim" },
	opts = {},
	config = function()
		require("hardtime").setup({
			max_count = 1,
			restricted_keys = {
				["w"] = { "n", "x" },
				["W"] = { "n", "x" },
				["b"] = { "n", "x" },
				["B"] = { "n", "x" },
				["h"] = { "n", "x" },
				["j"] = { "n", "x" },
				["k"] = { "n", "x" },
				["l"] = { "n", "x" },
				["-"] = { "n", "x" },
				["+"] = { "n", "x" },
				["gj"] = { "n", "x" },
				["gk"] = { "n", "x" },
				["<CR>"] = { "n", "x" },
				["<C-M>"] = { "n", "x" },
				["<C-N>"] = { "n", "x" },
			},
		})
	end,
}
