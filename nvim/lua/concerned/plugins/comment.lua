-- Commenting itself is built in since Neovim 0.10: gc as an operator, gcc for a
-- line, gb/gbc for blockwise. Comment.nvim used to provide those and was
-- shadowing the builtins; all that is still worth having is the treesitter part,
-- which picks the right commentstring inside embedded languages -- {/* */} in
-- JSX markup but // in the surrounding TypeScript, and the same for svelte and
-- html.
--
-- Built-in gc reads 'commentstring' at the moment the operator runs, so the
-- value has to be computed then rather than set once per buffer. Hooking
-- vim.filetype.get_option is how nvim-ts-context-commentstring documents doing
-- that; enable_autocmd = false turns off its own buffer-local mechanism, which
-- would otherwise fight with this one.
return {
	"JoosepAlviste/nvim-ts-context-commentstring",
	event = { "BufReadPre", "BufNewFile" },
	opts = {
		enable_autocmd = false,
	},
	config = function(_, opts)
		require("ts_context_commentstring").setup(opts)

		local get_option = vim.filetype.get_option
		vim.filetype.get_option = function(filetype, option)
			if option ~= "commentstring" then
				return get_option(filetype, option)
			end
			return require("ts_context_commentstring.internal").calculate_commentstring()
				or get_option(filetype, option)
		end
	end,
}
