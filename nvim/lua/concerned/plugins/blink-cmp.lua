-- Replaces nvim-cmp, which is effectively unmaintained. blink does its fuzzy
-- matching in Rust (downloaded prebuilt, hence the version pin) and needs no
-- separate source plugin per provider: buffer, path, snippets and LSP are all
-- built in, so cmp-buffer, cmp-path, cmp-nvim-lsp and cmp_luasnip are gone.
return {
	"saghen/blink.cmp",
	version = "1.*",
	event = "InsertEnter",
	dependencies = { "L3MON4D3/LuaSnip" },
	opts = {
		snippets = { preset = "luasnip" },

		keymap = {
			-- "none" rather than one of the presets, so nothing is bound beyond what
			-- is listed here. "fallback" lets the key keep its normal insert-mode
			-- meaning when the menu is closed.
			preset = "none",
			["<C-p>"] = { "select_prev", "fallback" },
			["<C-n>"] = { "select_next", "fallback" },
			["<C-y>"] = { "select_and_accept", "fallback" },
			["<C-Space>"] = { "show", "show_documentation", "hide_documentation" },
			["<C-e>"] = { "hide", "fallback" },
			-- LuaSnip's own <C-l>/<C-j> still drive jumps between snippet nodes
		},

		completion = {
			-- Nothing is preselected, so <C-y> only ever accepts something chosen
			-- deliberately with <C-p>/<C-n>, and a bare <CR> stays a newline.
			list = { selection = { preselect = false, auto_insert = false } },
			documentation = { auto_show = true, auto_show_delay_ms = 200 },
			-- Inserts the brackets a function needs on accept. This is why
			-- nvim-autopairs no longer needs a completion hook.
			accept = { auto_brackets = { enabled = true } },
		},

		sources = {
			default = { "lazydev", "lsp", "snippets", "buffer", "path" },
			providers = {
				-- A high score_offset is how blink expresses what group_index = 0 did
				-- under cmp: lazydev's `require` path completions rank above lua_ls's,
				-- which list every module in the workspace.
				lazydev = {
					name = "LazyDev",
					module = "lazydev.integrations.blink",
					score_offset = 100,
				},
			},
		},
	},
}
