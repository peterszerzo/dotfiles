return {
	"nvim-lualine/lualine.nvim",
	dependencies = { "nvim-mini/mini.icons" },
	event = "VeryLazy",
	config = function()
		require("lualine").setup({
			options = {
				section_separators = { left = "", right = "" },
				component_separators = { left = "|", right = "|" },
			},
			sections = {
				lualine_c = { "filename" },
			},
		})
	end,
}
