return {
	"pwntester/octo.nvim",
	cmd = "Octo",
	opts = {
		-- or "fzf-lua" or "snacks" or "default"
		picker = "telescope",
		-- bare Octo command opens picker of commands
		enable_builtin = true,
	},
	keys = {
		{
			"<Leader>oi",
			"<cmd>Octo issue list<CR>",
			desc = "List GitHub issues",
		},
		{
			"<Leader>op",
			"<cmd>Octo pr list<CR>",
			desc = "List GitHub pull requests",
		},
		{
			"<Leader>oc",
			"<cmd>Octo pr create<CR>",
			desc = "Create GitHub pull request",
		},
		{
			"<Leader>od",
			"<cmd>Octo discussion list<CR>",
			desc = "List GitHub discussions",
		},
		{
			"<Leader>on",
			"<cmd>Octo notification list<CR>",
			desc = "List GitHub notifications",
		},
		{
			"<Leader>os",
			function()
				require("octo.utils").create_base_search_command({ include_current_repo = true })
			end,
			desc = "Search GitHub",
		},
	},
	dependencies = {
		"nvim-lua/plenary.nvim",
		"nvim-telescope/telescope.nvim",
		-- OR "ibhagwan/fzf-lua",
		-- OR "folke/snacks.nvim",
		"nvim-tree/nvim-web-devicons",
	},
}
