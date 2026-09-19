return {
	"m4xshen/hardtime.nvim",
	dependencies = { "MunifTanjim/nui.nvim", "nvim-lua/plenary.nvim" },
	opts = {},
	config = function()
		require("hardtime").setup({
			max_count = 1,
			restricted_keys = {
				["w"] = { "n", "x" },
				["W"] = { "n", "x" },
				["b"] = { "n", "x" },
				["B"] = { "n", "x" },
				["h"] = { "n", "x" },
				["j"] = { "n", "x" },
				["k"] = { "n", "x" },
				["l"] = { "n", "x" },
				["-"] = { "n", "x" },
				["+"] = { "n", "x" },
				["gj"] = { "n", "x" },
				["gk"] = { "n", "x" },
				-- <CR> is treesitter incremental selection, which is meant to be
				-- pressed repeatedly, so it must not be rate limited. `false` is
				-- needed rather than omitting the key, to also unset hardtime's own
				-- default for <C-M> -- the same keycode as <CR>.
				["<CR>"] = false,
				["<C-M>"] = false,
				-- Likewise <C-N>/<C-P>, which select treesitter siblings in visual
				-- mode. hardtime's mappings are `noremap` and are set after ours, so
				-- its defaults for these two would shadow them entirely. Narrowing the
				-- mode list to just { "n" } does not work: hardtime merges config with
				-- `tbl_deep_extend`, which keeps the "x" from its own default list.
				["<C-N>"] = false,
				["<C-P>"] = false,
			},
		})
	end,
}
