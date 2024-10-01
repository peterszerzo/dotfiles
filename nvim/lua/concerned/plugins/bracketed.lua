return {
	"echasnovski/mini.bracketed",
	config = function()
		require("mini.bracketed").setup({
			buffer = { suffix = "", options = {} },
			comment = { suffix = "", options = {} },
			conflict = { suffix = "x", options = {} },
			diagnostic = { suffix = "d", options = {} },
			file = { suffix = "", options = {} },
			indent = { suffix = "", options = {} },
			jump = { suffix = "", options = {} },
			location = { suffix = "", options = {} },
			oldfile = { suffix = "", options = {} },
			quickfix = { suffix = "q", options = {} },
			treesitter = { suffix = "", options = {} },
			undo = { suffix = "", options = {} },
			window = { suffix = "", options = {} },
			yank = { suffix = "", options = {} },
		})
	end,
}
