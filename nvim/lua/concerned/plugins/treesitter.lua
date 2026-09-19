-- Parsers to keep installed. Installing is a no-op when they are already present.
local parsers = {
	"css",
	"elm",
	"fish",
	"html",
	"javascript",
	"json",
	"lua",
	"markdown",
	"markdown_inline",
	"tsx",
	"typescript",
	"vim",
	"vimdoc",
	"yaml",
}

-- Wrap a `vim.treesitter._select` function so it falls back to the LSP
-- equivalent in buffers without a parser.
local function select(name, lsp_count)
	return function()
		if vim.treesitter.get_parser(nil, nil, { error = false }) then
			require("vim.treesitter._select")[name](vim.v.count1)
		elseif lsp_count then
			vim.lsp.buf.selection_range(lsp_count * vim.v.count1)
		end
	end
end

-- A snapshot of the visual selection, used to tell whether a selection command
-- had any effect (the treesitter ones leave the selection untouched instead of
-- reporting failure).
local function selection()
	return { vim.fn.mode(), vim.fn.getpos("v"), vim.fn.getpos(".") }
end

-- Like `select`, but wrapping around: `select_next` on the last sibling walks
-- back to the first one, and vice versa.
local function select_sibling(name, opposite)
	return function()
		if not vim.treesitter.get_parser(nil, nil, { error = false }) then
			return
		end

		local ts_select = require("vim.treesitter._select")

		for _ = 1, vim.v.count1 do
			local before = selection()
			ts_select[name](1)

			if vim.deep_equal(selection(), before) then
				-- Already at the edge; run the opposite command until it, too,
				-- stops moving, which lands on the sibling at the other end.
				repeat
					before = selection()
					ts_select[opposite](1)
				until vim.deep_equal(selection(), before)
			end
		end
	end
end

return {
	"nvim-treesitter/nvim-treesitter",
	-- The `main` branch is the rewrite that targets Neovim 0.12+. It does not
	-- support lazy-loading.
	lazy = false,
	branch = "main",
	build = ":TSUpdate",
	config = function()
		require("nvim-treesitter").install(parsers)

		vim.api.nvim_create_autocmd("FileType", {
			group = vim.api.nvim_create_augroup("concerned_treesitter", {}),
			callback = function()
				-- Highlighting, injections and folds all come from Neovim itself;
				-- nvim-treesitter only supplies the parsers and queries.
				if not pcall(vim.treesitter.start) then
					return
				end

				vim.wo[0][0].foldmethod = "expr"
				vim.wo[0][0].foldexpr = "v:lua.vim.treesitter.foldexpr()"

				if vim.bo.filetype == "elm" then
					-- The Elm indent queries are worse than plain smartindent.
					vim.bo.indentexpr = ""
					vim.bo.smartindent = true
				else
					vim.bo.indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
				end
			end,
		})

		-- Incremental selection. Neovim 0.12 already binds `an`/`in`/`]n`/`[n` in
		-- visual mode (see `:h treesitter-incremental-selection`); these are the
		-- one-keystroke equivalents, and <CR> doubles as the entry point from
		-- normal mode so growing a selection is just <CR><CR><CR>.
		local select_parent = select("select_parent", 1)

		vim.keymap.set("n", "<CR>", function()
			-- <CR> has built-in meaning in special buffers (jumping to the entry
			-- under the cursor in the quickfix list, for instance), so only take it
			-- over in ordinary file buffers.
			if vim.bo.buftype ~= "" then
				vim.api.nvim_feedkeys(vim.keycode("<CR>"), "n", false)
				return
			end
			select_parent()
		end, { desc = "Select node under cursor" })

		vim.keymap.set("x", "<CR>", select_parent, { desc = "Select parent node" })
		vim.keymap.set("x", "<BS>", select("select_child", -1), { desc = "Select child node" })
		vim.keymap.set("x", "<C-n>", select_sibling("select_next", "select_prev"), { desc = "Select next sibling" })
		vim.keymap.set("x", "<C-p>", select_sibling("select_prev", "select_next"), { desc = "Select previous sibling" })
	end,
}
