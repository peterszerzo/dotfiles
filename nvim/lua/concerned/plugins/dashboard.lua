return {
	"goolord/alpha-nvim",
	event = "VimEnter",
	config = function()
		local alpha = require("alpha")
		local dashboard = require("alpha.themes.dashboard")

		-- Set header
		dashboard.section.header.val = {
			"",
			"",
			"   ╔═══════════════════════════════════════╗",
			"   ║╔═════════════════════════════════════╗║",
			"   ║║                                     ║║",
			"   ║║      Business Programmers'          ║║",
			"   ║║            Community                ║║",
			"   ║║                                     ║║",
			"   ║╚═════════════════════════════════════╝║",
			"   ╚═══════════════════════════════════════╝",
			"",
			"",
		}

		-- Set menu
		dashboard.section.buttons.val = {
			dashboard.button("f", "  Find File", ":Telescope find_files<CR>"),
			dashboard.button("r", "  Recent Files", ":Telescope oldfiles<CR>"),
			dashboard.button("g", "  Find Word", ":Telescope live_grep<CR>"),
			dashboard.button("z", "  LazyGit", ":LazyGit<CR>"),
			dashboard.button("q", "  Quit", ":qa<CR>"),
		}

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
	dependencies = { "nvim-tree/nvim-web-devicons" },
}
