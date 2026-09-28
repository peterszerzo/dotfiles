-- The language servers this config uses, in lspconfig's naming. One list, read
-- by both lsp/mason.lua (to install them) and lsp/lspconfig.lua (to enable
-- them), so the two cannot drift apart.
--
-- Deliberately not derived from whatever Mason happens to have installed: a
-- server left behind by an old experiment would otherwise keep attaching to
-- buffers.
--
-- Lives outside lua/concerned/plugins/ because lazy.nvim imports every module
-- in there as a plugin spec.
return {
	"cssls",
	"elmls",
	"html",
	"lua_ls",
	"svelte",
	"tailwindcss",
	"ts_ls",
}
