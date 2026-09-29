return {
	"saghen/blink.cmp",
	version = "1.*",
	event = "InsertEnter",
	dependencies = { "L3MON4D3/LuaSnip" },
	opts = {
		snippets = { preset = "luasnip" },

		keymap = {
			preset = "none",
			["<C-p>"] = { "select_prev", "fallback" },
			["<C-n>"] = { "select_next", "fallback" },
			["<C-y>"] = { "select_and_accept", "fallback" },
			["<C-Space>"] = { "show", "show_documentation", "hide_documentation" },
			["<C-e>"] = { "hide", "fallback" },
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
