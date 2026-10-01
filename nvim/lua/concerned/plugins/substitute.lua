return {
	"gbprod/substitute.nvim",
	event = { "BufReadPre", "BufNewFile" },
	config = function()
		local substitute = require("substitute")

		substitute.setup()

		local exchange = require("substitute.exchange")
		vim.keymap.set("n", "gs", exchange.operator, { desc = "Exchange operator" })
		vim.keymap.set("n", "gss", exchange.line, { desc = "Exchange line" })
		vim.keymap.set("n", "gsc", exchange.cancel, { desc = "Cancel exchange" })
		vim.keymap.set("x", "X", exchange.visual, { desc = "Exchange selection" })
	end,
}
