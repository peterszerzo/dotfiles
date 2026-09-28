-- Loaded on demand as a dependency of the lspconfig spec, plus on `:Mason`, so
-- startup no longer waits on the Mason registry.
return {
	"mason-org/mason.nvim",
	cmd = { "Mason", "MasonInstall", "MasonLog", "MasonUninstall", "MasonUpdate" },
	dependencies = {
		"mason-org/mason-lspconfig.nvim",
		"WhoIsSethDaniel/mason-tool-installer.nvim",
	},
	config = function()
		local mason = require("mason")
		local mason_lspconfig = require("mason-lspconfig")
		local mason_tool_installer = require("mason-tool-installer")

		mason.setup({
			ui = {
				icons = {
					package_installed = "✓",
					package_pending = "➜",
					package_uninstalled = "✗",
				},
			},
		})

		mason_lspconfig.setup({
			-- list of servers for mason to install
			ensure_installed = {
				"ts_ls",
				"html",
				"cssls",
				"elmls",
				"tailwindcss",
				"svelte",
				"lua_ls",
			},
			-- lsp/lspconfig.lua calls `vim.lsp.enable` with its own list. Letting Mason
			-- also enable everything it finds installed would start servers that are
			-- no longer wanted, and would race with the config being set up there.
			automatic_enable = false,
		})

		mason_tool_installer.setup({
			ensure_installed = {
				"prettier", -- prettier formatter
				"stylua", -- lua formatter
				"eslint_d",
			},
		})

		-- mason-tool-installer kicks off its install check from a VimEnter autocmd.
		-- Loading lazily means that event has already fired, so nothing would ever
		-- install; do it by hand instead.
		if vim.v.vim_did_enter == 1 then
			mason_tool_installer.check_install(false)
		end
	end,
}
