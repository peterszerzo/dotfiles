return {
	"MeanderingProgrammer/render-markdown.nvim",
	ft = { "markdown" },
	dependencies = { "nvim-mini/mini.icons" },
	opts = {
		checkbox = {
			custom = {
				-- `- [-]` for "in progress", alongside the built-in `[ ]`/`[x]`.
				todo = { raw = "[-]", rendered = "󰥔 ", highlight = "RenderMarkdownTodo" },
			},
		},
	},
}
