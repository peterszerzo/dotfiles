local nvim_set_keymap = vim.api.nvim_set_keymap

nvim_set_keymap("i", "jk", "<Esc>", {})
-- Remap the uppercase version as well, in case caps lock or caps word is on
nvim_set_keymap("i", "JK", "<Esc>", {})
nvim_set_keymap("n", "<Leader>q", ":q!<CR>", {})
nvim_set_keymap("n", "<Leader>s", ":w<CR>", {})
nvim_set_keymap("n", "<Leader>nh", ":nohl<CR>", {})
nvim_set_keymap("n", "<Leader>+", "<C-a>", { desc = "Increment number" }) -- increment
nvim_set_keymap("n", "<Leader>-", "<C-x>", { desc = "Decrement number" }) -- decrement

-- Git shortcuts
vim.keymap.set({ "n", "v", "l" }, "<Leader>ib", ":GBrowse!<CR>")
vim.keymap.set({ "n", "v", "l" }, "<Leader>id", ":Gdiff<CR>")
vim.keymap.set({ "n" }, "<Leader>b", "<C-^>")

vim.keymap.set("n", "<Leader>c", function()
	vim.cmd("e ~/.config/nvim/init.lua")
end)

vim.keymap.set("n", "<Leader>p", function()
	local ft = vim.bo.filetype
	if ft == "elm" then
		vim.cmd("!elm-format % --yes")
	elseif
		ft == "javascript"
		or ft == "typescript"
		or ft == "typescriptreact"
		or ft == "html"
		or ft == "json"
		or ft == "markdown"
		or ft == "css"
	then
		vim.cmd("!prettier % --write")
	end
end)
