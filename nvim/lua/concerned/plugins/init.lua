return {
	"christoomey/vim-tmux-navigator",
	"nvim-lua/plenary.nvim",
	"tpope/vim-repeat",
	"tpope/vim-abolish",
	"tpope/vim-fugitive",
	"tpope/vim-rhubarb",
	"tidalcycles/vim-tidal",
	{
		"catgoose/nvim-colorizer.lua",
		-- Same list as `filetypes` below: it has nothing to attach to elsewhere.
		ft = { "css", "javascript", "typescript", "typescriptreact" },
		opts = {
			filetypes = { "css", "javascript", "typescript", "typescriptreact" },
		},
	},
}
