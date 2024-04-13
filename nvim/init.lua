-- Base settings
vim.opt.number = true
vim.opt.incsearch = true
vim.opt.ignorecase = true
vim.opt.smartcase = true
vim.opt.scrolloff = 4
vim.opt.backspace = "indent,eol,start"
vim.opt.wrap = false
vim.opt.inccommand = "split"
vim.opt.swapfile = false
vim.opt.relativenumber = true
-- vim.opt.foldmethod = "expr"
vim.opt.foldmethod = "indent"
vim.opt.foldexpr = "nvim_treesitter#foldexpr()"
vim.opt.foldlevel = 99
vim.opt.termguicolors = true
vim.opt.colorcolumn = "100"
vim.opt.autoindent = true
vim.opt.autoread = true
vim.opt.expandtab = true
vim.opt.shiftwidth = 2
vim.opt.softtabstop = 2
vim.opt.smarttab = true
vim.opt.clipboard = "unnamed"
vim.opt.wildmenu = true
vim.opt.wildignore = { "*/node_modules/*", "*/elm-stuff/*", "*/public/*" }
vim.g.netrw_banner = 0

vim.api.nvim_create_autocmd("TextYankPost", {
	group = vim.api.nvim_create_augroup("highlight_yank", {}),
	desc = "Hightlight selection on yank",
	pattern = "*",
	callback = function()
		vim.highlight.on_yank({ higroup = "IncSearch", timeout = 150 })
	end,
})

vim.api.nvim_set_keymap("i", "jk", "<Esc>", {})
vim.api.nvim_set_keymap("n", "<Leader>x", ":q!<CR>", {})
vim.api.nvim_set_keymap("n", "<Leader>s", ":w<CR>", {})
vim.api.nvim_set_keymap("n", "<Leader>h", ":noh<CR>", {})
vim.api.nvim_set_keymap("n", "<Leader>r", ":LspRestart<CR>", {})
vim.api.nvim_set_keymap("n", "[z", "zM", {})
vim.api.nvim_set_keymap("n", "]z", "zR", {})

-- Package manager

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

require("lazy").setup({
	"christoomey/vim-tmux-navigator",
	"tpope/vim-surround",
	"tpope/vim-repeat",
	"tpope/vim-unimpaired",
	"tpope/vim-abolish",
	"tpope/vim-fugitive",
	"tpope/vim-rhubarb",
	"tpope/vim-commentary",
	"tidalcycles/vim-tidal",
	"tommcdo/vim-exchange",
	{
		"lewis6991/gitsigns.nvim",
		config = function()
			require("gitsigns").setup()
			vim.keymap.set("n", "<leader>ip", ":Gitsigns preview_hunk<CR>")
			vim.keymap.set("n", "<leader>it", ":Gitsigns toggle_current_line_blame<CR>")
		end,
	},
	{
		"kdheepak/lazygit.nvim",
		dependencies = {
			"nvim-lua/plenary.nvim",
		},
		keys = {
			{ "<Leader>ii", "<cmd>LazyGit<cr>", desc = "LazyGit" },
		},
	},
	{
		"nvim-tree/nvim-tree.lua",
		dependencies = {
			"nvim-tree/nvim-web-devicons",
		},
		config = function()
			require("nvim-tree").setup()
		end,
	},
	{
		"catppuccin/nvim",
		name = "catppuccin",
		priority = 1000,
	},
	{
		"norcalli/nvim-colorizer.lua",
		config = function()
			require("colorizer").setup({ "css", "javascript", "typescript", "typescriptreact" })
		end,
	},
	"BurntSushi/ripgrep",
	{ "neovim/nvim-lspconfig" },
	{ "williamboman/mason.nvim" },
	{ "williamboman/mason-lspconfig.nvim" },
	{
		"hrsh7th/nvim-cmp",
		event = "InsertEnter",
		dependencies = {
			"hrsh7th/cmp-buffer",
			"hrsh7th/cmp-path",
			"hrsh7th/cmp-nvim-lsp",
			"L3MON4D3/LuaSnip",
			"saadparwaiz1/cmp_luasnip",
			"rafamadriz/friendly-snippets",
		},
		config = function()
			local cmp = require("cmp")

			cmp.setup({
				completion = {
					completeopt = "menu,menuone,preview,noselect",
				},
				snippet = {
					expand = function(args)
						require("luasnip").lsp_expand(args.body)
					end,
				},
				mapping = {
					["<C-p>"] = cmp.mapping.select_prev_item(),
					["<C-n>"] = cmp.mapping.select_next_item(),
					["<C-y>"] = cmp.mapping.confirm({ select = true }),
					["<C-Space>"] = cmp.mapping.complete(),
					["<C-e>"] = cmp.mapping.abort(),
				},
				sources = cmp.config.sources({
					{ name = "nvim_lsp" },
					{ name = "luasnip" },
					{ name = "buffer" },
					{ name = "path" },
				}),
			})
		end,
	},
	-- {
	-- 	"github/copilot.vim",
	-- },
	{
		"VonHeikemen/lsp-zero.nvim",
		branch = "v3.x",
	},
	{
		"nvim-telescope/telescope.nvim",
		dependencies = { "nvim-lua/plenary.nvim" },
	},
	{
		"karb94/neoscroll.nvim",
		config = function()
			require("neoscroll").setup({
				-- Set any options as needed
			})

			local t = {}
			t["<C-u>"] = { "scroll", { "-vim.wo.scroll", "true", "100" } }
			t["<C-d>"] = { "scroll", { "vim.wo.scroll", "true", "100" } }
			t["<C-b>"] = { "scroll", { "-vim.api.nvim_win_get_height(0)", "true", "200" } }
			t["<C-f>"] = { "scroll", { "vim.api.nvim_win_get_height(0)", "true", "200" } }
			t["<C-y>"] = { "scroll", { "-0.10", "false", "50" } }
			t["<C-e>"] = { "scroll", { "0.10", "false", "50" } }
			t["zt"] = { "zt", { "125" } }
			t["zz"] = { "zz", { "125" } }
			t["zb"] = { "zb", { "125" } }

			require("neoscroll.config").set_mappings(t)
		end,
	},
	{
		"folke/todo-comments.nvim",
		dependencies = { "nvim-lua/plenary.nvim" },
		opts = {
			search = {
				command = "grep",
			},
		},
	},
	{
		"epwalsh/pomo.nvim",
		version = "*", -- Recommended, use latest release instead of latest commit
		lazy = true,
		cmd = { "TimerStart", "TimerRepeat" },
		dependencies = {
			-- Optional, but highly recommended if you want to use the "Default" timer
			"rcarriga/nvim-notify",
		},
		opts = {
			-- See below for full list of options 👇
		},
	},
	{
		"nvim-lualine/lualine.nvim",
		dependencies = { "nvim-tree/nvim-web-devicons" },
		config = function()
			require("lualine").setup({
				options = {
					section_separators = { left = "", right = "" },
					component_separators = { left = "|", right = "|" },
				},
				sections = {
					lualine_c = { "filename" },
				},
			})
		end,
	},
	{
		"folke/trouble.nvim",
		dependencies = { "nvim-tree/nvim-web-devicons" },
		opts = {},
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
	{
		"pwntester/octo.nvim",
		dependencies = { "nvim-lua/plenary.nvim", "nvim-telescope/telescope.nvim", "nvim-tree/nvim-web-devicons" },
		config = function()
			require("octo").setup()
		end,
	},
	{
		"nvim-treesitter/nvim-treesitter",
		build = ":TSUpdate",
		dependencies = { "nvim-treesitter/nvim-treesitter-textobjects" },
	},
})

require("luasnip.loaders.from_snipmate").lazy_load()

-- Fix 'prev_line' runtime error with copilot per https://github.com/ayamir/nvimdots/issues/365#issuecomment-1353351666
-- vim.cmd([[
--   let g:copilot_filetypes = {
--      \ 'dap-repl': v:false,
--      \ }
-- ]])

-- Treesitter

require("nvim-treesitter.configs").setup({
	ensure_installed = {
		"c",
		"lua",
		"vim",
		"vimdoc",
		"query",
		"elixir",
		"heex",
		"javascript",
		"html",
		"elm",
		"typescript",
		"tsx",
	},
	auto_install = true,
	sync_install = false,
	highlight = { enable = true, additional_vim_regex_highlighting = false },
	indent = { enable = true },
	textobjects = {
		selects = {
			enable = true,
			lookahead = true,
			keymaps = {
				-- You can use the capture groups defined in textobjects.scm
				["af"] = "@function.outer",
				["if"] = "@function.inner",
			},
		},
	},
})

-- LSP zero

local lsp = require("lsp-zero")

lsp.on_attach(function(client, bufnr)
	lsp.default_keymaps({ buffer = bufnr })
end)

-- Configure lua language server for neovim
local lspconfig = require("lspconfig")

lspconfig.svelte.setup({})
lspconfig.elmls.setup({})
lspconfig.tsserver.setup({})
lspconfig.rust_analyzer.setup({})
lspconfig.lua_ls.setup(lsp.nvim_lua_ls())
lspconfig.tailwindcss.setup({
	filetypes = { "elm", "typescript", "typescriptreact" },
})

-- Autocomplete

lsp.setup()

-- Other stuff

vim.cmd("colorscheme catppuccin-mocha")

local builtin = require("telescope.builtin")

vim.keymap.set("n", "<Leader>ff", builtin.find_files, {})
vim.keymap.set("n", "<C-p>", builtin.git_files, {})
vim.keymap.set("n", "<Leader>fg", builtin.live_grep, {})
vim.keymap.set("n", "<Leader>fs", builtin.grep_string, {})
vim.keymap.set("n", "<Leader>fc", builtin.git_commits, {})
vim.keymap.set("n", "<Leader>fbc", builtin.git_bcommits, {})
vim.keymap.set("n", "<Leader>ft", builtin.help_tags, {})
vim.keymap.set("n", "<Leader>fr", builtin.treesitter, {})
vim.keymap.set("n", "<Leader>fpr", ":Octo pr list<CR>")
vim.keymap.set("n", "<Leader>fi", ":Octo issue list<CR>")
vim.keymap.set("n", "<Leader>fnpr", ":Octo pr create<CR>")
vim.keymap.set("n", "<Leader>fni", ":Octo issue create<CR>")

vim.api.nvim_create_user_command("Grp", function(opts)
	vim.cmd(string.format('Git grep -q "%s"', opts.fargs[1]))
end, { nargs = 1 })

local trouble = require("trouble")

vim.keymap.set("n", "<Leader>to", function()
	trouble.open()
end)
vim.keymap.set("n", "<Leader>tw", function()
	trouble.open("workspace_diagnostics")
end)
vim.keymap.set("n", "<Leader>td", function()
	trouble.open("document_diagnostics")
end)
vim.keymap.set("n", "<Leader>tq", function()
	trouble.open("quickfix")
end)
vim.keymap.set("n", "<Leader>tl", function()
	trouble.open("loclist")
end)
vim.keymap.set("n", "<Leader>tn", function()
	trouble.next({ skip_groups = true, jump = true })
end)
vim.keymap.set("n", "<Leader>tp", function()
	trouble.previous({ skip_groups = true, jump = true })
end)

vim.keymap.set({ "n" }, "<Leader>ds", ":TimerStart 25m Work<CR>")
vim.keymap.set({ "n" }, "<Leader>dh", ":TimerHide<CR>")
vim.keymap.set({ "n" }, "<Leader>dw", ":TimerShow<CR>")

-- Git shortcuts
vim.keymap.set({ "n", "v", "l" }, "<Leader>ib", ":GBrowse<CR>")
vim.keymap.set({ "n", "v", "l" }, "<Leader>id", ":Gdiff<CR>")
vim.keymap.set({ "n" }, "<Leader>b", "<C-^>")

vim.keymap.set({ "n" }, "<Leader>o", ":NvimTreeFindFile<CR>")

vim.keymap.set("n", "<Leader>c", function()
	vim.cmd("e ~/.config/nvim/init.lua")
end)

vim.keymap.set("n", "<Leader>p", function()
	local ft = vim.bo.filetype
	if ft == "elm" then
		vim.cmd("!elm-format % --yes")
	elseif
		ft == "javascript"
		or ft == "typescript"
		or ft == "typescriptreact"
		or ft == "html"
		or ft == "json"
		or ft == "markdown"
		or ft == "css"
	then
		vim.cmd("!prettier % --write")
	end
end)
