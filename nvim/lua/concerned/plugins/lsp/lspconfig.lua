return {
	"neovim/nvim-lspconfig",
	event = { "BufReadPre", "BufNewFile" },
	dependencies = {
		"saghen/blink.cmp",
		-- Mason's `setup()` is what puts the installed server binaries on PATH, and
		-- servers start as soon as the config below runs, so it has to load first.
		"mason-org/mason.nvim",
	},
	config = function()
		local servers = require("concerned.lsp-servers")

		local max_file_size = 512 * 1024

		local max_restarts = 3

		local crash_loop_window = 30 * 1000

		vim.diagnostic.config({
			signs = {
				text = {
					[vim.diagnostic.severity.ERROR] = " ",
					[vim.diagnostic.severity.WARN] = " ",
					[vim.diagnostic.severity.HINT] = "󰠠 ",
					[vim.diagnostic.severity.INFO] = " ",
				},
			},
			severity_sort = true,
			-- No `border` here: 'winborder' supplies it for every float at once.
			float = { source = true, header = "" },
			jump = { float = true, wrap = true },
		})

		-- Crash bookkeeping, keyed by server name. See `on_exit` below.
		local crashes = {}

		vim.lsp.config("*", {
			capabilities = require("blink.cmp").get_lsp_capabilities(),

			-- Only consulted for servers whose own definition sets no root markers:
			-- anchors them at the repository rather than at nvim's working directory.
			root_markers = { ".git" },

			on_init = function(client)
				local state = crashes[client.name] or {}
				crashes[client.name] = state
				state.up_since = vim.uv.now()
			end,

			-- Servers die on their own sometimes: OOM on a large project, a malformed
			-- tsconfig.json, or Mason replacing the binary under a running process.
			-- Core notifies and leaves the buffer with no client attached, which is
			-- easy to miss; bring the server back instead.
			on_exit = function(code, signal, client_id)
				-- Same test core uses to decide an exit was abnormal: exit code 0 with
				-- either no signal or SIGTERM is us stopping the server deliberately.
				-- Note a SIGKILL arrives as code 0 with signal 9, so the signal has to
				-- be checked even when the code looks clean.
				local crashed = code ~= 0 or (signal ~= 0 and signal ~= 15)
				if not crashed then
					return
				end

				local client = vim.lsp.get_client_by_id(client_id)
				local name = client and client.name
				if not name then
					return
				end

				-- on_exit runs in a fast event context, so nothing below may touch the
				-- editor directly.
				vim.schedule(function()
					-- Don't resurrect a server that was disabled in the meantime.
					if not vim.lsp.is_enabled(name) then
						return
					end

					local state = crashes[name] or {}
					crashes[name] = state

					if state.up_since and vim.uv.now() - state.up_since > crash_loop_window then
						state.count = 0
					end
					state.count = (state.count or 0) + 1
					state.up_since = nil

					if state.count > max_restarts then
						vim.notify(
							("%s crashed %d times, leaving it stopped. :LspLog for why, :LspRestart to retry."):format(
								name,
								state.count
							),
							vim.log.levels.ERROR
						)
						return
					end

					-- Re-enabling re-runs the attach check against every open buffer,
					-- which spawns a fresh server for the ones that still want one.
					vim.lsp.enable(name)
				end)
			end,
		})

		vim.lsp.config("tailwindcss", {
			-- `filetypes` is a top-level config key, not a `settings.tailwindCSS` one.
			-- It used to be nested under settings, where the server ignored it, so elm
			-- buffers never actually got tailwind completion. Extend the list
			-- nvim-lspconfig ships rather than replacing it, which would drop
			-- javascript, javascriptreact and friends.
			filetypes = vim.list_extend(vim.deepcopy(vim.lsp.config.tailwindcss.filetypes or {}), { "elm" }),
			settings = {
				tailwindCSS = {
					includeLanguages = {
						elm = "html",
					},
					experimental = {
						classRegex = {
							-- Activate autocomplete within all string literals
							{ '"([^"]*)"' },
							{ "'([^\"]*)'" },
						},
					},
				},
			},
		})

		-- Core maps grn, gra, grr, gri, grt and grx by default. Leaving any of them in
		-- place makes plain `gr` wait a full 'timeoutlen' to see whether a longer
		-- sequence is coming (`:h map-<nowait>`), so they all have to go. The
		-- mappings below cover every one except grx (codelens), which none of these
		-- servers provide.
		for _, lhs in ipairs({ "grn", "gra", "grr", "gri", "grt", "grx" }) do
			pcall(vim.keymap.del, "n", lhs)
		end
		pcall(vim.keymap.del, "x", "gra")

		vim.api.nvim_create_autocmd("LspAttach", {
			group = vim.api.nvim_create_augroup("concerned_lsp_attach", {}),
			callback = function(ev)
				local stat = vim.uv.fs_stat(vim.api.nvim_buf_get_name(ev.buf))
				if stat and stat.size > max_file_size then
					-- Scheduled, not immediate: core marks the buffer as attached *after*
					-- firing LspAttach, so a detach from inside this callback is undone
					-- the moment it returns. The initial didOpen has already gone out
					-- either way; what this saves is the per-keystroke diffing, the
					-- semantic token refreshes and the diagnostic churn that follow.
					vim.schedule(function()
						if vim.lsp.buf_is_attached(ev.buf, ev.data.client_id) then
							vim.lsp.buf_detach_client(ev.buf, ev.data.client_id)
						end
					end)
					return
				end

				-- Buffer-local, so buffers without a language server keep the builtin
				-- meanings of gd, gD and K instead of erroring.
				local function map(mode, lhs, rhs, desc)
					vim.keymap.set(mode, lhs, rhs, { buffer = ev.buf, silent = true, desc = desc })
				end

				map("n", "gr", "<cmd>Telescope lsp_references<CR>", "Show LSP references")
				map("n", "gd", "<cmd>Telescope lsp_definitions<CR>", "Show LSP definitions")
				map("n", "gD", vim.lsp.buf.declaration, "Go to declaration")
				map("n", "gi", "<cmd>Telescope lsp_implementations<CR>", "Show LSP implementations")
				map("n", "gt", "<cmd>Telescope lsp_type_definitions<CR>", "Show LSP type definitions")
				map("n", "K", vim.lsp.buf.hover, "Show type and documentation under cursor")
				map({ "n", "v" }, "<Leader>a", vim.lsp.buf.code_action, "See available code actions")
				map("n", "<Leader>r", vim.lsp.buf.rename, "Smart rename")
				map("n", "<Leader>d", vim.diagnostic.open_float, "Show line diagnostics")
				map("n", "<Leader>D", "<cmd>Telescope diagnostics bufnr=0<CR>", "Show buffer diagnostics")
			end,
		})

		-- Shows the color a value resolves to, for tailwindcss and cssls. "virtual"
		-- keeps it in virtual text instead of recolouring the token itself, which
		-- would fight with treesitter over the highlight.
		vim.lsp.document_color.enable(true, nil, { style = "virtual" })

		vim.lsp.enable(servers)
	end,
}
