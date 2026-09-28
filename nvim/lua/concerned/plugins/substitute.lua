return {
	"gbprod/substitute.nvim",
	event = { "BufReadPre", "BufNewFile" },
	config = function()
		local substitute = require("substitute")

		substitute.setup()

		-- Exchange lives under `g` rather than the `s` prefix these mappings used to
		-- use. Any mapping starting with `s` makes bare `s` a partial match, so it
		-- stops doing anything visible until the next keystroke resolves the
		-- ambiguity -- and stalls for 'timeoutlen' if you pause. `g` is already a
		-- prefix key (gc, gd, gr, gt and friends), so hanging one more off it costs
		-- nothing. `gs` on its own was :sleep, which nobody reaches for.
		local exchange = require("substitute.exchange")
		vim.keymap.set("n", "gs", exchange.operator, { desc = "Exchange operator" })
		vim.keymap.set("n", "gss", exchange.line, { desc = "Exchange line" })
		vim.keymap.set("n", "gsc", exchange.cancel, { desc = "Cancel exchange" })
		vim.keymap.set("x", "X", exchange.visual, { desc = "Exchange selection" })
	end,
}
