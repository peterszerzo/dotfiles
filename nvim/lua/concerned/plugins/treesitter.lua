return {
	"nvim-treesitter/nvim-treesitter",
	lazy = false,
	build = ":TSUpdate",
	branch = "main",
	config = function()
		vim.api.nvim_create_autocmd("FileType", {
			callback = function()
				-- Enable treesitter highlighting and disable regex syntax
				pcall(vim.treesitter.start)
				-- Enable treesitter-based indentation
				vim.bo.indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
			end,
		})
		local ensureInstalled = { "typescript", "tsx", "javascript", "elm" }
		local alreadyInstalled = require("nvim-treesitter.config").get_installed()
		local parsersToInstall = vim.iter(ensureInstalled)
			:filter(function(parser)
				return not vim.tbl_contains(alreadyInstalled, parser)
			end)
			:totable()
		require("nvim-treesitter").install(parsersToInstall)

		-- Incremental selection
		vim.keymap.set({ "x" }, "[n", function()
			require("vim.treesitter._select").select_prev(vim.v.count1)
		end, { desc = "Select previous treesitter node" })

		vim.keymap.set({ "x" }, "]n", function()
			require("vim.treesitter._select").select_next(vim.v.count1)
		end, { desc = "Select next treesitter node" })

		vim.keymap.set({ "x", "o" }, "an", function()
			if vim.treesitter.get_parser(nil, nil, { error = false }) then
				require("vim.treesitter._select").select_parent(vim.v.count1)
			else
				vim.lsp.buf.selection_range(vim.v.count1)
			end
		end, { desc = "Select parent treesitter node or outer incremental lsp selections" })

		vim.keymap.set({ "x", "o" }, "in", function()
			if vim.treesitter.get_parser(nil, nil, { error = false }) then
				require("vim.treesitter._select").select_child(vim.v.count1)
			else
				vim.lsp.buf.selection_range(-vim.v.count1)
			end
		end, { desc = "Select child treesitter node or inner incremental lsp selections" })
	end,
}
