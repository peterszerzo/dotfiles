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
			"<leader>xx",
			"<cmd>Trouble diagnostics toggle filter.buf=0<cr>",
			desc = "Buffer Diagnostics (Trouble)",
		},
		{
			"<leader>xX",
			"<cmd>Trouble diagnostics toggle<cr>",
			desc = "Diagnostics (Trouble)",
		},
		{
			"<leader>xs",
			"<cmd>Trouble symbols toggle focus=false<cr>",
			desc = "Symbols (Trouble)",
		},
		{
			"<leader>xd",
			"<cmd>Trouble lsp toggle focus=false win.position=right<cr>",
			desc = "LSP Definitions / references / ... (Trouble)",
		},
		{
			"<leader>xq",
			"<cmd>Trouble qflist toggle<cr>",
			desc = "Quickfix List (Trouble)",
		},
	},
}
