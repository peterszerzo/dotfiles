return {
	"folke/noice.nvim",
	event = "VeryLazy",
	dependencies = {
		"MunifTanjim/nui.nvim",
		-- Backend for the notification view that noice routes messages to. The
		-- animation and timeout of those notifications are its settings, not noice's.
		{
			"rcarriga/nvim-notify",
			opts = {
				-- No fade/slide animation, the notification just appears and vanishes
				stages = "static",
				timeout = 2000,
			},
		},
	},
	opts = {
		routes = {
			-- Neovim 0.11+ reports `:!cmd` output under the shell_* message kinds,
			-- which noice does not know about yet. Without this route they match
			-- no view at all and the output is dropped silently.
			{
				view = "split",
				filter = { event = "msg_show", kind = { "shell_out", "shell_err", "shell_ret" } },
				opts = { enter = false },
			},
		},
	},
}
