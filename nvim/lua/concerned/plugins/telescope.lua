return {
	"nvim-telescope/telescope.nvim",
	dependencies = { "nvim-lua/plenary.nvim", { "nvim-telescope/telescope-fzf-native.nvim", build = "make" } },
	config = function()
		local builtin = require("telescope.builtin")
		vim.keymap.set("n", "<Leader>f", builtin.find_files, { desc = "Search files" })
		vim.keymap.set("n", "<Leader>/", builtin.live_grep, { desc = "Live grep" })
		vim.keymap.set("n", "<Leader>b", builtin.buffers, { desc = "Search buffers" })
		vim.keymap.set("n", "<Leader>m", builtin.lsp_document_symbols, { desc = "Search symbols" })
	end,
}
