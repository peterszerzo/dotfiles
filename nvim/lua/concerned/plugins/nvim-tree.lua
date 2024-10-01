return {
	"nvim-tree/nvim-tree.lua",
	dependencies = {
		"nvim-tree/nvim-web-devicons",
	},
	event = "VeryLazy",
	config = function()
		local nvim_tree = require("nvim-tree")

		local HEIGHT_RATIO = 0.85
		local WIDTH_RATIO = 0.4

		nvim_tree.setup({
			view = {
				float = {
					enable = true,
					open_win_config = function()
						local screen_w = vim.opt.columns:get()
						local screen_h = vim.opt.lines:get() - vim.opt.cmdheight:get()
						local window_w = screen_w * WIDTH_RATIO
						local window_h = screen_h * HEIGHT_RATIO
						local window_w_int = math.floor(window_w)
						local window_h_int = math.floor(window_h)
						local center_x = (screen_w - window_w) / 2
						local center_y = ((vim.opt.lines:get() - window_h) / 2) - vim.opt.cmdheight:get()
						return {
							border = "rounded",
							relative = "editor",
							row = center_y,
							col = center_x,
							width = window_w_int,
							height = window_h_int,
						}
					end,
				},
				width = function()
					return math.floor(vim.opt.columns:get() * WIDTH_RATIO)
				end,
			},
		})

		local tree_api = require("nvim-tree.api")
		local tree_view = require("nvim-tree.view")

		vim.keymap.set({ "n" }, "<Leader>t", function()
			if tree_view.is_visible() then
				tree_view.close()
			else
				tree_api.tree.find_file({ open = true, focus = true })
			end
		end, { desc = "Toggle tree" })
	end,
}
