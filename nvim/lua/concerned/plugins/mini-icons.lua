-- Icon provider, replacing nvim-web-devicons. Plugins like lualine and octo
-- still `require("nvim-web-devicons")` by name, so preload a stub that hands
-- them mini.icons' compatibility shim instead.
return {
	"nvim-mini/mini.icons",
	lazy = true,
	opts = {},
	init = function()
		package.preload["nvim-web-devicons"] = function()
			require("mini.icons").mock_nvim_web_devicons()
			return package.loaded["nvim-web-devicons"]
		end
	end,
}
