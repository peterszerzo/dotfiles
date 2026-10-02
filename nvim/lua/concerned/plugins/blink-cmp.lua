-- The tailwind language server decides for itself how much of the word under
-- the cursor a class completion replaces, and it only excludes the variant
-- prefix for variants it recognises. Hit one it doesn't -- `enabled:` on a
-- project pinned below Tailwind 3.1, a variant from a plugin it failed to load
-- -- and the range it sends back covers the whole token, so accepting
-- `text-primary-90` over `enabled:hover:tepri90` throws the variants away.
--
-- Pull the start of the range past the last `:` before the cursor. Items whose
-- own text contains a separator are left alone: those are the variant
-- suggestions (`hover:`), which legitimately replace the variants typed so far.
local function tailwind_keep_variants(ctx, items)
	local after_colon = ctx.line:sub(1, ctx.cursor[2]):match(".*():")
	if not after_colon then
		return items
	end

	local line = ctx.cursor[1] - 1
	for _, item in ipairs(items) do
		local edit = item.textEdit
		if
			item.client_name == "tailwindcss"
			and edit
			and edit.range
			and edit.range.start.line == line
			and edit.range["end"].line == line
			and edit.range.start.character < after_colon
			and not edit.newText:find(":", 1, true)
		then
			-- A fresh table, not an in-place edit: blink points every item at the
			-- one range object the server sent in `itemDefaults.editRange`, so
			-- mutating it would move the range for the variant items too.
			item.textEdit = {
				newText = edit.newText,
				range = {
					start = { line = line, character = after_colon },
					["end"] = { line = line, character = edit.range["end"].character },
				},
			}
		end
	end

	return items
end

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
				lsp = { transform_items = tailwind_keep_variants },
			},
		},
	},
}
