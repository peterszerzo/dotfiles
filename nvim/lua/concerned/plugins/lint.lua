return {
	"mfussenegger/nvim-lint",
	event = { "BufReadPre", "BufNewFile" },
	config = function()
		local lint = require("lint")

		-- `eslint_d` rather than `eslint`: it keeps a server warm between runs, and
		-- it is what mason-tool-installer installs (see lsp/mason.lua).
		lint.linters_by_ft = {
			javascript = { "eslint_d" },
			javascriptreact = { "eslint_d" },
			typescript = { "eslint_d" },
			typescriptreact = { "eslint_d" },
		}

		-- nvim-lint only ever lints when asked to, so drive it off the events where
		-- the buffer has just settled.
		vim.api.nvim_create_autocmd({ "BufReadPost", "BufWritePost", "InsertLeave" }, {
			group = vim.api.nvim_create_augroup("concerned_lint", {}),
			desc = "Run the linters for this filetype",
			callback = function()
				lint.try_lint()
			end,
		})
	end,
}
