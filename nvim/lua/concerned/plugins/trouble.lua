return {
	"folke/trouble.nvim",
	opts = {
		focus = true,
		modes = {
			symbols = { focus = true, win = { type = "split", position = "right", size = 0.33 } },
			diagnostics = { focus = true, win = { type = "split", position = "right", size = 0.5 } },
			loclist = { focus = true, win = { type = "split", position = "right", size = 0.5 } },
			quickfix = { focus = true, win = { type = "split", position = "right", size = 0.5 } },
			todo = { focus = true, win = { type = "split", position = "right", size = 0.5 } },
		},
	},
	cmd = "Trouble",
	keys = {
		{
			"<leader>xw",
			"<cmd>Trouble diagnostics toggle<CR>",
			desc = "Open trouble workspace diagnostics",
		},
		{
			"<leader>xd",
			"<cmd>Trouble diagnostics toggle filter.buf=0<CR>",
			desc = "Open trouble document diagnostics",
		},
		{ "<leader>xq", "<cmd>Trouble quickfix toggle<CR>", desc = "Open trouble quickfix list" },
		{ "<leader>xl", "<cmd>Trouble loclist toggle<CR>", desc = "Open trouble location list" },
		{ "<leader>xt", "<cmd>Trouble todo toggle<CR>", desc = "Open todos in trouble" },
		{
			"<leader>xs",
			"<cmd>Trouble symbols toggle<CR>",
			desc = "Open symbols in trouble",
		},
	},
}
