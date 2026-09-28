local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
	vim.fn.system({
		"git",
		"clone",
		"--filter=blob:none",
		"https://github.com/folke/lazy.nvim.git",
		"--branch=stable", -- latest stable release
		lazypath,
	})
end
vim.opt.rtp:prepend(lazypath)

require("lazy").setup({ { import = "concerned.plugins" }, { import = "concerned.plugins.lsp" } }, {
	checker = {
		enabled = true,
		notify = false,
		-- Default is hourly, which means a `git ls-remote` per plugin on most
		-- launches. Weekly still surfaces updates without the per-launch fetch.
		frequency = 604800,
	},
	change_detection = {
		notify = false,
	},
})
