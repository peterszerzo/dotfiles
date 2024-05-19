local opt = vim.opt

vim.g.netrw_banner = 0
opt.autoindent = true
opt.autoread = true
opt.backspace = "indent,eol,start"
opt.clipboard = "unnamed"
opt.colorcolumn = "100"
opt.cursorline = true
opt.expandtab = true
opt.foldenable = true
opt.foldlevel = 99
opt.foldlevelstart = 99
opt.ignorecase = true
opt.inccommand = "split"
opt.incsearch = true
opt.number = true
opt.relativenumber = true
opt.scrolloff = 4
opt.shiftwidth = 2
opt.smartcase = true
opt.smarttab = true
opt.softtabstop = 2
opt.swapfile = false
opt.termguicolors = true
opt.wrap = false

vim.api.nvim_create_autocmd("TextYankPost", {
	group = vim.api.nvim_create_augroup("highlight_yank", {}),
	desc = "Hightlight selection on yank",
	pattern = "*",
	callback = function()
		vim.highlight.on_yank({ higroup = "IncSearch", timeout = 150 })
	end,
})
