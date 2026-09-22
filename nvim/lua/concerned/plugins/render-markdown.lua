-- In-buffer markdown rendering: styled headings, bullet and checkbox icons,
-- code block backgrounds, tables and callouts. The line under the cursor is
-- left as raw text, so editing still happens on the real characters.
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
