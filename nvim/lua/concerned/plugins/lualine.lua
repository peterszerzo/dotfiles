return {
	"nvim-lualine/lualine.nvim",
	dependencies = { "nvim-mini/mini.icons" },
	event = "VeryLazy",
	config = function()
		require("lualine").setup({
			options = {
				theme = "auto",
			},
			sections = {
				lualine_a = { "mode" },
				lualine_b = { "branch", "fugitive" },
				lualine_c = {
					"filename",
					function()
						return vim.ui.progress_status()
					end,
				},
				lualine_x = { "diagnostics", "trouble" },
				lualine_y = { "diff" },
				lualine_z = { "location" },
			},
		})
	end,
}
