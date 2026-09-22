return {
	"nvim-lualine/lualine.nvim",
	dependencies = { "nvim-mini/mini.icons" },
	config = function()
		require("lualine").setup({
			options = {
				section_separators = { left = "", right = "" },
				component_separators = { left = "|", right = "|" },
				theme = "rose-pine",
			},
			sections = {
				lualine_c = { "filename" },
			},
		})
	end,
}
