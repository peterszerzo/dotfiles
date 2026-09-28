return {
	"christoomey/vim-tmux-navigator",
	"nvim-lua/plenary.nvim",
	"tpope/vim-repeat",
	"tpope/vim-abolish",
	"tpope/vim-fugitive",
	"tpope/vim-rhubarb",
	{
		"tidalcycles/vim-tidal",
		ft = "tidal",
		-- The filetype has to be detectable before lazy's FileType trigger can fire,
		-- and the plugin's own ftdetect is not on the runtimepath until it loads.
		init = function()
			vim.filetype.add({ extension = { tidal = "tidal" } })
		end,
	},
}
