require("concerned.core")

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
	"tpope/vim-abolish",
	"tpope/vim-fugitive",
	"tpope/vim-rhubarb",
	"tpope/vim-commentary",
	"tidalcycles/vim-tidal",
	"tommcdo/vim-exchange",
	{
		"kevinhwang91/nvim-ufo",
		dependencies = { "kevinhwang91/promise-async" },
		config = function()
			local ufo = require("ufo")
			ufo.setup({
				provider_selector = function(bufnr, filetype, buftype)
					return { "treesitter", "indent" }
				end,
			})
			vim.keymap.set("n", "[z", ufo.closeAllFolds)
			vim.keymap.set("n", "]z", ufo.openAllFolds)
		end,
	},
	{

		"lewis6991/gitsigns.nvim",
		config = function()
			require("gitsigns").setup({
				on_attach = function(bufnr)
					local gitsigns = require("gitsigns")
					local function map(mode, l, r, opts)
						opts = opts or {}
						opts.buffer = bufnr
						vim.keymap.set(mode, l, r, opts)
					end

					vim.keymap.set("n", "<leader>ip", ":Gitsigns preview_hunk<CR>")
					vim.keymap.set("n", "<leader>it", ":Gitsigns toggle_current_line_blame<CR>")

					-- Navigation
					map("n", "]m", function()
						if vim.wo.diff then
							vim.cmd.normal({ "]m", bang = true })
						else
							gitsigns.nav_hunk("next")
						end
					end)

					map("n", "[m", function()
						if vim.wo.diff then
							vim.cmd.normal({ "[m", bang = true })
						else
							gitsigns.nav_hunk("prev")
						end
					end)
				end,
			})
		end,
	},
	{
		"echasnovski/mini.bracketed",
		config = function()
			require("mini.bracketed").setup()
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
		"folke/tokyonight.nvim",
		lazy = false,
		priority = 1000,
		opts = {},
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
	{
		"VonHeikemen/lsp-zero.nvim",
		branch = "v3.x",
	},
	{
		"nvim-telescope/telescope.nvim",
		dependencies = { "nvim-lua/plenary.nvim" },
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
		"nvim-lualine/lualine.nvim",
		dependencies = { "nvim-tree/nvim-web-devicons" },
		config = function()
			require("lualine").setup({
				options = {
					section_separators = { left = "", right = "" },
					component_separators = { left = "|", right = "|" },
					theme = "tokyonight",
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
	{
		"nvim-treesitter/nvim-treesitter-context",
		config = function()
			require("treesitter-context").setup({
				enable = true, -- Enable this plugin (Can be enabled/disabled later via commands)
				max_lines = 2, -- How many lines the window should span. Values <= 0 mean no limit.
				min_window_height = 0, -- Minimum editor window height to enable context. Values <= 0 mean no limit.
				line_numbers = true,
				multiline_threshold = 20, -- Maximum number of lines to show for a single context
				trim_scope = "inner", -- Which context lines to discard if `max_lines` is exceeded. Choices: 'inner', 'outer'
				mode = "cursor", -- Line used to calculate context. Choices: 'cursor', 'topline'
				-- Separator between context and content. Should be a single character string, like '-'.
				-- When separator is set, the context will only show up when there are at least 2 lines above cursorline.
				separator = nil,
				zindex = 20, -- The Z-index of the context window
				on_attach = nil, -- (fun(buf: integer): boolean) return false to disable attaching
			})
		end,
	},
})

require("luasnip.loaders.from_snipmate").lazy_load()

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

vim.cmd("colorscheme tokyonight-night")

local builtin = require("telescope.builtin")

vim.keymap.set("n", "<Leader>ff", builtin.find_files, { desc = "Search files" })
vim.keymap.set("n", "<C-p>", builtin.git_files, {})
vim.keymap.set("n", "<Leader>fg", builtin.live_grep, { desc = "Live grep" })
vim.keymap.set("n", "<Leader>fs", builtin.grep_string, { desc = "Search under cursor" })
vim.keymap.set("n", "<Leader>fc", builtin.git_commits, { desc = "Search commits" })
vim.keymap.set("n", "<Leader>fh", builtin.help_tags, { desc = "Search help tags" })
vim.keymap.set("n", "<Leader>fr", builtin.registers, { desc = "Search registers" })
vim.keymap.set("n", "<Leader>fm", builtin.marks, { desc = "Search marks" })
vim.keymap.set("n", "<Leader>ft", builtin.treesitter, { desc = "Search treesitter" })
vim.keymap.set("n", "<Leader>fn", builtin.man_pages, { desc = "Search man pages" })
vim.keymap.set("n", "<Leader>fp", ":Octo pr list<CR>")
vim.keymap.set("n", "<Leader>fi", ":Octo issue list<CR>")

-- Octo PRs
vim.keymap.set("n", "<Leader>oic", ":Octo issue create<CR>")
vim.keymap.set("n", "<Leader>opc", ":Octo pr create<CR>")
vim.keymap.set("n", "<Leader>opm", ":Octo pr merge<CR>")
vim.keymap.set("n", "<Leader>ors", ":Octo review start<CR>")
vim.keymap.set("n", "<Leader>oru", ":Octo review submit<CR>")

local trouble = require("trouble")

vim.keymap.set("n", "<Leader>xx", function()
	trouble.toggle()
end, { desc = "Trouble" })
vim.keymap.set("n", "<Leader>xw", function()
	trouble.toggle("workspace_diagnostics")
end, { desc = "Trouble workspace" })
vim.keymap.set("n", "<Leader>xd", function()
	trouble.toggle("document_diagnostics")
end, { desc = "Trouble document" })
vim.keymap.set("n", "<Leader>xq", function()
	trouble.toggle("quickfix")
end, { desc = "Trouble quickfix" })
vim.keymap.set("n", "<Leader>xl", function()
	trouble.toggle("loclist")
end, { desc = "Trouble location list" })
vim.keymap.set("n", "gR", function()
	trouble.toggle("lsp_references")
end)

-- Git shortcuts
vim.keymap.set({ "n", "v", "l" }, "<Leader>ib", ":GBrowse!<CR>")
vim.keymap.set({ "n", "v", "l" }, "<Leader>id", ":Gdiff<CR>")
vim.keymap.set({ "n" }, "<Leader>b", "<C-^>")

vim.keymap.set({ "n" }, "<Leader>w", ":NvimTreeFindFile<CR>")

vim.keymap.set("n", "gd", vim.lsp.buf.definition)
vim.keymap.set("n", "gr", vim.lsp.buf.references)
vim.keymap.set("n", "K", vim.lsp.buf.hover)

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
