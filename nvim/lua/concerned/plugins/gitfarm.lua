return {
	url = "ssh://git.amazon.com:2222/pkg/Vim-code-browse",
	branch = "mainline",
	dependencies = "tpope/vim-fugitive",
	event = "VeryLazy",
	-- Only available on Amazon machines, where the builder toolbox is installed.
	enabled = function()
		return vim.uv.fs_stat(vim.fn.expand("~/.toolbox")) ~= nil
	end,
}
