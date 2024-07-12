return {
	"gbprod/substitute.nvim",
	event = { "BufReadPre", "BufNewFile" },
	config = function()
		local substitute = require("substitute")

		substitute.setup()

		-- set keymaps
		local keymap = vim.keymap -- for conciseness

		vim.keymap.set("n", "sx", require("substitute.exchange").operator, { noremap = true })
		vim.keymap.set("n", "sxx", require("substitute.exchange").line, { noremap = true })
		vim.keymap.set("x", "X", require("substitute.exchange").visual, { noremap = true })
		vim.keymap.set("n", "sxc", require("substitute.exchange").cancel, { noremap = true })
	end,
}
