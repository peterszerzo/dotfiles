-- Replaces neodev.nvim, which is archived and pushed the whole Neovim runtime
-- plus every installed plugin into lua_ls's workspace up front. lazydev feeds
-- lua_ls only the library paths a buffer actually references, which is the
-- difference between lua_ls indexing all of ~/.local/share/nvim/lazy on startup
-- and indexing nothing until a `require` asks for it.
return {
	"folke/lazydev.nvim",
	ft = "lua",
	opts = {
		library = {
			-- vim.uv typings are worth loading only for the files that use them
			{ path = "${3rd}/luv/library", words = { "vim%.uv" } },
		},
	},
}
