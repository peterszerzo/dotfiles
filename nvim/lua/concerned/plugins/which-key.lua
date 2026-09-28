return {
	"folke/which-key.nvim",
	event = "VeryLazy",
	init = function()
		vim.o.timeout = true
		vim.o.timeoutlen = 500
	end,
	opts = {
		-- Names for the leader prefixes, so the popup reads as a menu instead of a
		-- flat list of every key that happens to start with <Leader>g
		spec = {
			{ "<Leader>e", group = "edit/open" },
			{ "<Leader>g", group = "git" },
			{ "<Leader>h", group = "hunks" },
			{ "<Leader>l", group = "links/lists" },
			{ "<Leader>n", group = "numbering" },
			{ "<Leader>o", group = "github (octo)" },
			{ "<Leader>x", group = "diagnostics (trouble)" },
			{ "gs", group = "exchange" },
		},
	},
}
