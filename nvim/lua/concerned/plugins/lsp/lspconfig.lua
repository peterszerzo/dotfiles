return {
	"neovim/nvim-lspconfig",
	event = { "BufReadPre", "BufNewFile" },
	dependencies = {
		"hrsh7th/cmp-nvim-lsp",
		{ "antosha417/nvim-lsp-file-operations", config = true },
		{ "folke/neodev.nvim", opts = {} },
	},
	config = function()
		local lspconfig = require("lspconfig")

		local mason_lspconfig = require("mason-lspconfig")

		local cmp_nvim_lsp = require("cmp_nvim_lsp")

		local keymap = vim.keymap

		vim.api.nvim_create_autocmd("LspAttach", {
			group = vim.api.nvim_create_augroup("UserLspConfig", {}),
			callback = function(ev)
				keymap.set(
					"n",
					"gr",
					"<cmd>Telescope lsp_references<CR>",
					{ buffer = ev.buf, silent = true, desc = "Show LSP references" }
				)

				keymap.set(
					"n",
					"gD",
					vim.lsp.buf.declaration,
					{ buffer = ev.buf, silent = true, desc = "Go to declaration" }
				)

				keymap.set(
					"n",
					"gd",
					"<cmd>Telescope lsp_definitions<CR>",
					{ buffer = ev.buf, silent = true, desc = "Show LSP definitions" }
				)

				keymap.set(
					"n",
					"gi",
					"<cmd>Telescope lsp_implementations<CR>",
					{ buffer = ev.buf, silent = true, desc = "Show LSP implementations" }
				)

				keymap.set(
					"n",
					"gt",
					"<cmd>Telescope lsp_type_definitions<CR>",
					{ buffer = ev.buf, silent = true, desc = "Show LSP type definitions" }
				)

				keymap.set(
					{ "n", "v" },
					"<Leader>a",
					vim.lsp.buf.code_action,
					{ buffer = ev.buf, silent = true, desc = "See available code actions" }
				)

				keymap.set(
					"n",
					"<Leader>r",
					vim.lsp.buf.rename,
					{ buffer = ev.buf, silent = true, desc = "Smart rename" }
				)

				keymap.set(
					"n",
					"<Leader>D",
					"<cmd>Telescope diagnostics bufnr=0<CR>",
					{ buffer = ev.buf, silent = true, desc = "Show buffer diagnostics" }
				)

				keymap.set(
					"n",
					"<Leader>d",
					vim.diagnostic.open_float,
					{ buffer = ev.buf, silent = true, desc = "Show line diagnostics" }
				)

				keymap.set(
					"n",
					"[d",
					vim.diagnostic.goto_prev,
					{ buffer = ev.buf, silent = true, desc = "Go to previous diagnostic" }
				)

				keymap.set(
					"n",
					"]d",
					vim.diagnostic.goto_next,
					{ buffer = ev.buf, silent = true, desc = "Go to next diagnostic" }
				)

				keymap.set(
					"n",
					"<Leader>k",
					vim.lsp.buf.hover,
					{ buffer = ev.buf, silent = true, desc = "Show documentation for what is under cursor" }
				)

				keymap.set(
					"n",
					"<Leader>e",
					vim.diagnostic.open_float,
					{ buffer = ev.buf, silent = true, desc = "Show documentation for what is under cursor" }
				)
			end,
		})

		-- used to enable autocompletion (assign to every lsp server config)
		local capabilities = cmp_nvim_lsp.default_capabilities()

		-- Change the Diagnostic symbols in the sign column (gutter)
		-- (not in youtube nvim video)
		local signs = { Error = " ", Warn = " ", Hint = "󰠠 ", Info = " " }
		for type, icon in pairs(signs) do
			local hl = "DiagnosticSign" .. type
			vim.fn.sign_define(hl, { text = icon, texthl = hl, numhl = "" })
		end

		mason_lspconfig.setup({
			handlers = {
				-- default handler for installed servers
				function(server_name)
					lspconfig[server_name].setup({
						capabilities = capabilities,
					})
				end,
				["tailwindcss"] = function()
					lspconfig["tailwindcss"].setup({
						capabilities = capabilities,
						filetypes = {
							"html",
							"css",
							"typescriptreact",
							"typescript",
							"svelte",
							"elm",
						},
						settings = {
							tailwindCSS = {
								experimental = {
									classRegex = {
										-- Activate autocomplete within all string literals
										'"([^"]*)"',
										"'([^\"]*)'",
									},
								},
							},
						},
					})
				end,
				["lua_ls"] = function()
					-- configure lua server (with special settings)
					lspconfig["lua_ls"].setup({
						capabilities = capabilities,
						settings = {
							Lua = {
								-- make the language server recognize "vim" global
								diagnostics = {
									globals = { "vim" },
								},
								completion = {
									callSnippet = "Replace",
								},
							},
						},
					})
				end,
			},
		})
	end,
}
