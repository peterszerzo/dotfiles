local opt = vim.opt

vim.g.mapleader = "\\"
vim.g.netrw_banner = 0
opt.autoindent = true
opt.autoread = true
opt.backspace = "indent,eol,start"
opt.clipboard = "unnamed"
opt.colorcolumn = "120"
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
opt.signcolumn = "yes:1"

vim.api.nvim_create_autocmd("TextYankPost", {
	group = vim.api.nvim_create_augroup("highlight_yank", {}),
	desc = "Hightlight selection on yank",
	pattern = "*",
	callback = function()
		vim.highlight.on_yank({ higroup = "IncSearch", timeout = 150 })
	end,
})

local function open_package_json()
	local current_dir = vim.fn.getcwd()
	local package_json_path = current_dir .. "/package.json"
	local readme_path = current_dir .. "/README.md"

	if vim.fn.filereadable(package_json_path) == 1 then
		vim.cmd("edit " .. package_json_path)
	elseif vim.fn.filereadable(readme_path) == 1 then
		vim.cmd("edit " .. readme_path)
	end
end

-- Autocommand to run the function when Neovim starts
vim.api.nvim_create_autocmd("VimEnter", {
	callback = open_package_json,
	nested = true,
})

vim.api.nvim_create_user_command("VSBranch", function(opts)
	local default_branch = "main"
	local branch = opts.args ~= "" and opts.args or default_branch

	vim.cmd(":Gvsplit " .. branch .. ":%")
end, {
	nargs = "?", -- The command takes an optional argument
})
