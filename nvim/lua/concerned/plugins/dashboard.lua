return {
	"goolord/alpha-nvim",
	event = "VimEnter",
	config = function()
		local alpha = require("alpha")
		local dashboard = require("alpha.themes.dashboard")

		-- Set header: a membership badge. Every line is exactly 39 display cells
		-- wide so the borders line up; keep it that way when editing. The lines use
		-- [[long strings]] so the backslashes in the portrait need no escaping.
		dashboard.section.header.val = {
			"",
			"",
			[[╔═════════════════════════════════════╗]],
			[[║                                     ║]],
			[[║    BUSINESS PROGRAMMERS' SOCIETY    ║]],
			[[║                                     ║]],
			[[║ ┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈ ║]],
			[[║                                     ║]],
			[[║   ┌─────────────┐                   ║]],
			[[║   │   _______   │                   ║]],
			[[║   │  /   o   \  │                   ║]],
			[[║   │ /_________\ │                   ║]],
			[[║   │/___________\│   MEMBER   p0     ║]],
			[[║   │ |  =   =  | │   NO.      2242   ║]],
			[[║   │ |  o   o  | │   SINCE    2017   ║]],
			[[║   │ |    |    | │                   ║]],
			[[║   │ | :\___/: | │                   ║]],
			[[║   │  \:::::::/  │                   ║]],
			[[║   └─────────────┘                   ║]],
			[[║                                     ║]],
			[[╚═════════════════════════════════════╝]],
			"",
			"",
		}

		dashboard.section.buttons.val = {}

		-- Set footer
		local function footer()
			return ""
		end

		dashboard.section.footer.val = footer()

		-- Send config to alpha
		alpha.setup(dashboard.opts)

		-- Disable folding on alpha buffer
		vim.cmd([[autocmd FileType alpha setlocal nofoldenable]])
	end,
}
