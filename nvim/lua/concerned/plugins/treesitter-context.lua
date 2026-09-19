return {
	"nvim-treesitter/nvim-treesitter-context",
	event = { "BufReadPost", "BufNewFile" },
	opts = {
		max_lines = 8,
		multiline_threshold = 1,
		min_window_height = 20,
		separator = "┄",
	},
	keys = {
		{
			"[c",
			function()
				require("treesitter-context").go_to_context(vim.v.count1)
			end,
			desc = "Jump to context start",
		},
	},
}
