return {
	"nvim-telescope/telescope.nvim",
	dependencies = { "nvim-lua/plenary.nvim", { "nvim-telescope/telescope-fzf-native.nvim", build = "make" } },
	config = function()
		local builtin = require("telescope.builtin")
		vim.keymap.set("n", "<Leader>ff", builtin.find_files, { desc = "Search files" })
		vim.keymap.set("n", "<C-p>", builtin.git_files, {})
		vim.keymap.set("n", "<Leader>fg", builtin.live_grep, { desc = "Live grep" })
		vim.keymap.set("n", "<Leader>fs", builtin.grep_string, { desc = "Search under cursor" })
		vim.keymap.set("n", "<Leader>fc", builtin.git_commits, { desc = "Search commits" })
		vim.keymap.set("n", "<Leader>fh", builtin.help_tags, { desc = "Search help tags" })
		vim.keymap.set("n", "<Leader>fr", builtin.registers, { desc = "Search registers" })
		vim.keymap.set("n", "<Leader>fm", builtin.marks, { desc = "Search marks" })
		vim.keymap.set("n", "<Leader>fd", builtin.commands, { desc = "Search commands" })
		vim.keymap.set("n", "<Leader>ft", builtin.treesitter, { desc = "Search treesitter" })
		vim.keymap.set("n", "<Leader>fn", builtin.man_pages, { desc = "Search man pages" })
	end,
}
