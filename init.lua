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
vim.opt.foldmethod = "indent"
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
vim.api.nvim_set_keymap("n", "<Leader>r", ":LspRestart<CR>", {});
vim.api.nvim_set_keymap("n", "[z", "zM", {});
vim.api.nvim_set_keymap("n", "]z", "zR", {});

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
  "tommcdo/vim-exchange",
  "BurntSushi/ripgrep",
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
  "saadparwaiz1/cmp_luasnip",
  {
    "nvim-telescope/telescope.nvim", tag = "0.1.2",
     dependencies = { "nvim-lua/plenary.nvim" }
  },
  {
    "folke/todo-comments.nvim",
    dependencies = { "nvim-lua/plenary.nvim" },
    opts = {
      search = {
        command = "grep",
      }
    }
  },
  {
    "folke/trouble.nvim",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    opts = {},
  },
  {
    "zbirenbaum/copilot.lua",
    cmd = "Copilot",
    event = "InsertEnter",
    config = function()
      require("copilot").setup({
        suggestion = { enabled = false },
        panel = { enabled = false },
      })
    end,
  },
  {
    "zbirenbaum/copilot-cmp",
    config = function ()
      require("copilot_cmp").setup()
    end
  }
})

require("luasnip.loaders.from_snipmate").lazy_load()

-- LSP zero

local lsp = require("lsp-zero").preset({})

lsp.on_attach(function(client, bufnr)
  -- see :help lsp-zero-keybindings to learn the available actions
  lsp.default_keymaps({buffer = bufnr})
end)

lsp.ensure_installed({
  "tsserver"
})


-- Configure lua language server for neovim
require("lspconfig").lua_ls.setup(lsp.nvim_lua_ls())

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

lsp.format_on_save({
  format_opts = {
    async = false,
    timeout_ms = 10000,
  },
  servers = {
    ["my_elm"] = {"elm"},
    ["tsserver"] = {"ts", "tsx"},
  }
})

-- Autocomplete 

local cmp = require('cmp')
local cmp_select = {behavior = cmp.SelectBehavior.Select}
local cmp_mappings = lsp.defaults.cmp_mappings({
  ["<C-p>"] = cmp.mapping.select_prev_item(cmp_select),
  ["<C-n>"] = cmp.mapping.select_next_item(cmp_select),
  ["<CR>"] = cmp.mapping.confirm({ select = false })
})

lsp.setup_nvim_cmp({
  mapping = cmp_mappings,
  sources = {
    { name = "copilot", group_index = 2 },
    { name = 'path'},
    { name = 'nvim_lsp'},
    { name = 'buffer', keyword_length = 3},
    { name = 'luasnip', keyword_length = 2},
  }
})

lsp.setup()

-- Tree Sitter

require("lazy").setup({
  {
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate",
    config = function ()
      local configs = require("nvim-treesitter.configs")

      configs.setup({
          ensure_installed = { "c", "lua", "vim", "vimdoc", "query", "elixir", "heex", "javascript", "html", "elm" },
          sync_install = false,
          highlight = { enable = true, additional_vim_regex_highlighting = false },
          indent = { enable = true },
        })
    end
  }
})

-- Other stuff

vim.cmd("colorscheme tokyonight-night")

local builtin = require("telescope.builtin")

vim.keymap.set("n", "<Leader>ff", builtin.find_files, {})
vim.keymap.set("n", "<C-p>", builtin.git_files, {})
vim.keymap.set('n', '<Leader>fg', builtin.live_grep, {})
vim.keymap.set('n', '<Leader>ft', builtin.help_tags, {})

vim.api.nvim_create_user_command(
  'Grp',
  function(opts)
    vim.cmd(string.format("Git grep -q \"%s\"", opts.fargs[1]));
  end,
  { nargs = 1 }
)

vim.keymap.set("n", "<Leader>trx", function() require("trouble").open() end)
vim.keymap.set("n", "<Leader>trw", function() require("trouble").open("workspace_diagnostics") end)
vim.keymap.set("n", "<Leader>trd", function() require("trouble").open("document_diagnostics") end)
vim.keymap.set("n", "<Leader>trq", function() require("trouble").open("quickfix") end)
vim.keymap.set("n", "<Leader>trl", function() require("trouble").open("loclist") end)

vim.keymap.set("n", "<Leader>c", function()
  vim.cmd("e ~/.config/nvim/init.lua")
end)

vim.keymap.set("n", "<Leader>p", function()
  if (vim.bo.filetype == "elm") then
    vim.cmd("!elm-format % --yes")
  elseif (vim.bo.filetype == "typescript" or vim.bo.filetype == "typescriptreact") then
    vim.cmd("!prettier % --write")
  end
end)
