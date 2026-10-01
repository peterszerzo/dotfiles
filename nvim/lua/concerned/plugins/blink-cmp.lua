return {
	"saghen/blink.cmp",
	version = "1.*",
	event = "InsertEnter",
	dependencies = { "L3MON4D3/LuaSnip" },
	opts = {
		snippets = { preset = "luasnip" },

		keymap = {
			preset = "none",
			["<C-p>"] = { "select_prev", "fallback_to_mappings" },
			["<C-n>"] = { "select_next", "fallback_to_mappings" },
			["<C-y>"] = { "select_and_accept", "fallback" },
			["<CR>"] = { "accept", "fallback" },
			["<C-Space>"] = { "show", "show_documentation", "hide_documentation" },
			["<C-e>"] = { "cancel", "fallback" },
			["<C-b>"] = { "scroll_documentation_up", "fallback" },
			["<C-f>"] = { "scroll_documentation_down", "fallback" },
		},

		completion = {
			list = { selection = { preselect = false, auto_insert = false } },
			documentation = { auto_show = true, auto_show_delay_ms = 200 },
			accept = { auto_brackets = { enabled = true } },
		},

		sources = {
			default = { "lazydev", "lsp", "snippets", "buffer", "path" },
			providers = {
				lazydev = {
					name = "LazyDev",
					module = "lazydev.integrations.blink",
					score_offset = 100,
				},
			},
		},
	},
}
