local opt = vim.opt

vim.g.netrw_banner = 0
opt.autoindent = true
opt.autoread = true
opt.backspace = "indent,eol,start"
opt.clipboard = "unnamedplus"
opt.colorcolumn = "120"
-- Prompt to save on :q rather than failing with "No write since last change"
opt.confirm = true
opt.cursorline = true
opt.expandtab = true
opt.foldenable = true
opt.foldmethod = "expr"
opt.foldexpr = "v:lua.vim.treesitter.foldexpr()"
opt.foldlevel = 99
opt.ignorecase = true
opt.inccommand = "split"
opt.incsearch = true
-- "view" restores the scroll position when jumping back, not just the cursor line
opt.jumpoptions = "stack,view"
opt.list = true
opt.listchars = { tab = "» ", trail = "·", nbsp = "␣" }
opt.number = true
opt.pumheight = 12
opt.relativenumber = true
opt.scrolloff = 4
opt.shiftwidth = 2
opt.smartcase = true
opt.smarttab = true
opt.softtabstop = 2
opt.splitbelow = true
opt.splitright = true
opt.swapfile = false
opt.tabstop = 2
opt.termguicolors = true
-- Undo history outlives the buffer. Worth more here than usual, since there is
-- no swapfile to fall back on. Written under stdpath("state")/undo.
opt.undofile = true
-- The default 4s makes anything driven off CursorHold -- gitsigns' line blame,
-- treesitter-context -- feel broken rather than deliberate.
opt.updatetime = 250
-- Applies to every float that does not ask for a border of its own: LSP hover,
-- diagnostics, which-key, telescope's previewer.
opt.winborder = "rounded"
opt.wrap = false
opt.signcolumn = "yes:1"

require("vim._core.ui2").enable({})

vim.api.nvim_create_autocmd("TextYankPost", {
	group = vim.api.nvim_create_augroup("highlight_yank", {}),
	desc = "Hightlight selection on yank",
	pattern = "*",
	callback = function()
		vim.hl.on_yank({ higroup = "IncSearch", timeout = 150 })
	end,
})

vim.api.nvim_create_user_command("VSBranch", function(opts)
	local default_branch = "main"
	local branch = opts.args ~= "" and opts.args or default_branch

	vim.cmd(":Gvsplit " .. branch .. ":%")
end, {
	nargs = "?", -- The command takes an optional argument
})
