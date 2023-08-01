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
vim.opt.foldmethod = "syntax"
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
vim.api.nvim_create_autocmd("TextYankPost", {
  group = vim.api.nvim_create_augroup("highlight_yank", {}),
  desc = "Hightlight selection on yank",
  pattern = "*",
  callback = function()
    vim.highlight.on_yank { higroup = "IncSearch", timeout = 150 }
  end,
})

vim.api.nvim_set_keymap("i", "jk", "<Esc>", {});
vim.api.nvim_set_keymap("n", "<Leader>x", ":q!<CR>", {});
vim.api.nvim_set_keymap("n", "<Leader>s", ":w<CR>", {});
vim.api.nvim_set_keymap("n", "<Leader>h", ":noh<CR>", {});
vim.api.nvim_set_keymap("n", "[z", "zm", {});
vim.api.nvim_set_keymap("n", "]z", "zr", {});

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
  "folke/tokyonight.nvim",
  "tpope/vim-surround",
  "tpope/vim-repeat",
  "tpope/vim-unimpaired",
  "tpope/vim-abolish",
  "tpope/vim-fugitive",
  "tpope/vim-rhubarb",
  "tpope/vim-commentary",
  {
    "VonHeikemen/lsp-zero.nvim",
    branch = "v2.x",
    dependencies = {
      -- LSP Support
      {"neovim/nvim-lspconfig"},             -- Required
      {"williamboman/mason.nvim"},           -- Optional
      {"williamboman/mason-lspconfig.nvim"}, -- Optional

      -- Autocompletion
      {"hrsh7th/nvim-cmp"},     -- Required
      {"hrsh7th/cmp-nvim-lsp"}, -- Required
      {"L3MON4D3/LuaSnip"},     -- Required
    }
  },
  {
    "nvim-telescope/telescope.nvim", tag = "0.1.2",
     dependencies = { "nvim-lua/plenary.nvim" }
  }
})

-- LSP zero

local lsp = require("lsp-zero").preset({})

lsp.on_attach(function(client, bufnr)
  -- see :help lsp-zero-keybindings
  -- to learn the available actions
  lsp.default_keymaps({buffer = bufnr})
end)

lsp.ensure_installed({
  "tsserver"
})

-- (Optional) Configure lua language server for neovim
require("lspconfig").lua_ls.setup(lsp.nvim_lua_ls())

lsp.setup()

-- LSP zero Elm

local lsp_configurations = require("lspconfig.configs")

if not lsp_configurations.my_elm then
  lsp_configurations.my_elm = {
    default_config = {
      name = "my_elm",
      cmd = {"elm-language-server"},
      filetypes = {"elm"},
      root_dir = require("lspconfig.util").root_pattern("elm.json")
    }
  }
end

require("lspconfig").my_elm.setup({})

-- Tree Sitter

require("lazy").setup({{"nvim-treesitter/nvim-treesitter", build = ":TSUpdate"}})

-- Other stuff

vim.cmd("colorscheme tokyonight")

builtin = require("telescope.builtin")

vim.keymap.set("n", "<Leader>pf", builtin.find_files, {})
vim.keymap.set("n", "<C-p>", builtin.git_files, {})
vim.keymap.set("n", "<Leader>ps", function()
  builtin.grep_string({ search = vim.fn.input("Grep > ") });
end)
