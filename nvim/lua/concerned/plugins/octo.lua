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
			"<CMD>Octo issue list<CR>",
			desc = "List GitHub issues",
		},
		{
			"<Leader>op",
			"<CMD>Octo pr list<CR>",
			desc = "List GitHub pull requests",
		},
		{
			"<Leader>oc",
			"<CMD>Octo pr create<CR>",
			desc = "List GitHub pull requests",
		},
		{
			"<Leader>od",
			"<CMD>Octo discussion list<CR>",
			desc = "List GitHub discussions",
		},
		{
			"<Leader>on",
			"<CMD>Octo notification list<CR>",
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
