local nvim_set_keymap = vim.api.nvim_set_keymap

nvim_set_keymap("i", "jk", "<Esc>", {})
nvim_set_keymap("n", "<Leader>q", ":q!<CR>", {})
nvim_set_keymap("n", "<Leader>s", ":w<CR>", {})
nvim_set_keymap("n", "<Leader>h", ":noh<CR>", {})
nvim_set_keymap("n", "<Leader>r", ":LspRestart<CR>", {})
nvim_set_keymap("n", "+", "<C-a>", {})
nvim_set_keymap("n", "-", "<C-x>", {})
