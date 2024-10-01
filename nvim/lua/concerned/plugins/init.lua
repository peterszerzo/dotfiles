return {
	"christoomey/vim-tmux-navigator",
	"nvim-lua/plenary.nvim",
	"tpope/vim-repeat",
	"tpope/vim-abolish",
	"tpope/vim-fugitive",
	"tpope/vim-rhubarb",
	"tidalcycles/vim-tidal",
	"BurntSushi/ripgrep",
	{
		"stevearc/dressing.nvim",
		event = "VeryLazy",
	},
	{
		"kdheepak/lazygit.nvim",
		dependencies = {
			"nvim-lua/plenary.nvim",
		},
		keys = {
			{ "<Leader>l", "<cmd>LazyGit<cr>", desc = "LazyGit" },
		},
	},
	{
		"norcalli/nvim-colorizer.lua",
		config = function()
			require("colorizer").setup({ "css", "javascript", "typescript", "typescriptreact" })
		end,
	},
	{
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
	},
	{
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
				},
				format_after_save = {
					lsp_fallback = true,
				},
			})
		end,
	},
}
