-- nvim-ts-context-commentstring picks the commentstring for the language under
-- the cursor rather than the one for the file, so a comment in JSX markup is
-- {/* */} while the surrounding TypeScript gets //, and the same for svelte and
-- html.
--
-- gc reads 'commentstring' at the moment the operator runs, so the value has to
-- be computed then rather than set once per buffer. Hooking
-- vim.filetype.get_option is how the plugin documents doing that;
-- enable_autocmd = false turns off its own buffer-local mechanism, which would
-- otherwise fight with this one.
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
