return {
	"nvim-telescope/telescope.nvim",
	dependencies = { "nvim-lua/plenary.nvim", { "nvim-telescope/telescope-fzf-native.nvim", build = "make" } },
	config = function()
		local builtin = require("telescope.builtin")
		vim.keymap.set("n", "<Leader>f", function()
			builtin.find_files({ hidden = true, file_ignore_patterns = { "^%.git/" } })
		end, { desc = "Search files" })
		vim.keymap.set("n", "<Leader>/", builtin.live_grep, { desc = "Live grep" })
		vim.keymap.set("n", "<Leader>b", builtin.git_branches, { desc = "Search branches" })
		vim.keymap.set("n", "<Leader>;", function()
			builtin.command_history({
				-- "> " would be parsed as part of the command on the selected line
				selection_caret = "  ",
				attach_mappings = function(prompt_bufnr)
					local picker = require("telescope.actions.state").get_current_picker(prompt_bufnr)
					vim.schedule(function()
						vim.treesitter.start(picker.results_bufnr, "vim")
					end)
					return true
				end,
			})
		end, { desc = "Search command history" })
		vim.keymap.set("n", "<Leader>'", builtin.commands, { desc = "Search commands" })
		vim.keymap.set("n", "<Leader>m", builtin.lsp_document_symbols, { desc = "Search symbols" })
	end,
}
