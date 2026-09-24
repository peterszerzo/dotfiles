local nvim_set_keymap = vim.api.nvim_set_keymap

vim.g.mapleader = " "

nvim_set_keymap("i", "jk", "<Esc>", { desc = "Escape" })
-- Remap the uppercase version as well, in case caps lock or caps word is on
nvim_set_keymap("i", "JK", "<Esc>", { desc = "Escape" })
nvim_set_keymap("n", "<Leader>q", "<Cmd>q!<CR>", { desc = "Exit without saving" })
-- <Cmd> runs the command without entering command-line mode, so nothing flashes
-- in the cmdline on the way through
nvim_set_keymap("n", "<Leader>s", "<Cmd>w<CR>", { desc = "Save" })
-- Restart, keeping the current buffers/windows/tabs. `:restart` accepts a
-- command to run on the new server (`:h :restart`), so we write a session file
-- first, then source and delete it once the new server is up.
local restart_session = vim.fs.joinpath(vim.fn.stdpath("state"), "restart-session.vim")

vim.keymap.set("n", "<Leader>t", function()
	vim.cmd("mksession! " .. vim.fn.fnameescape(restart_session))
	vim.cmd(("restart lua vim.cmd.source(%q) vim.fn.delete(%q)"):format(restart_session, restart_session))
end, { desc = "Restart Neovim while preserving buffers" })

nvim_set_keymap("n", "<Leader><Leader>", "<Cmd>nohl<CR>", { desc = "Clear highlights" })
nvim_set_keymap("n", "<Leader>+", "<C-a>", { desc = "Increment number" }) -- increment
nvim_set_keymap("n", "<Leader>-", "<C-x>", { desc = "Decrement number" }) -- decrement

vim.keymap.set({ "n" }, "<BS>", "<C-^>", { desc = "Previous file" })

vim.keymap.set({ "n", "v", "l" }, "<Leader>gb", ":GBrowse!<CR>")
vim.keymap.set({ "n", "v", "l" }, "<Leader>gd", "<Cmd>Gdiff<CR>")

vim.keymap.set("n", "<Leader>ea", "<Cmd>e ~/Documents/AGENDA.md<CR>", { desc = "Open agenda" })
vim.keymap.set("n", "<Leader>en", "<Cmd>e ~/Documents/NOTES.md<CR>", { desc = "Open notes" })

-- Wrap inner word or visual selection in a markdown link tag
vim.api.nvim_create_autocmd("FileType", {
	pattern = "markdown",
	group = vim.api.nvim_create_augroup("concerned_markdown_keymaps", {}),
	callback = function(args)
		vim.keymap.set("x", "<Leader>ll", 'c[<C-r>"]()<Left>', {
			buffer = args.buf,
			desc = "Link from selection",
		})
		vim.keymap.set("n", "<Leader>ll", 'ciw[<C-r>"]()<Left>', {
			buffer = args.buf,
			desc = "Link from word",
		})
	end,
})

vim.api.nvim_create_user_command("Format", function()
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
end, {})

-- Get the current file path relative to the working directory
-- Falls back to the absolute path when the file lives outside of cwd
local function relative_file_path()
	return vim.fn.fnamemodify(vim.fn.expand("%:p"), ":.")
end

-- Get the current file path as an absolute path on this machine
local function absolute_file_path()
	return vim.fn.expand("%:p")
end

-- Function to copy the file path, example @src/index.js
local function copy_file_reference(file_path, prefix)
	local reference = prefix .. file_path

	-- Copy to system clipboard (+ register)
	vim.fn.setreg("+", reference)

	-- Notify the user
	print("Copied: " .. reference)
end

-- Function to copy file path and visual selection range, example src/index.js:5-10
local function copy_visual_selection_reference(file_path)
	-- Get visual selection marks
	-- '< and '> represent the start and end of the last visual selection
	local start_line = vim.fn.getpos("'<")[2]
	local end_line = vim.fn.getpos("'>")[2]

	-- Format the string
	local reference = string.format("%s:%d-%d", file_path, start_line, end_line)

	-- Copy to system clipboard (+ register)
	vim.fn.setreg("+", reference)

	-- Notify the user
	print("Copied: " .. reference)
end

-- Leave visual mode so the '< and '> marks reflect the selection we just made
local function exit_visual_mode()
	vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<Esc>", true, false, true), "x", true)
end

vim.keymap.set("v", "<Leader>c", function()
	exit_visual_mode()
	copy_visual_selection_reference(relative_file_path())
end, { desc = "Copy coding agent reference (visual selection)" })

vim.keymap.set("n", "<Leader>c", function()
	copy_file_reference(relative_file_path(), "@")
end, { desc = "Copy coding agent reference (file)" })

vim.keymap.set("v", "<Leader>C", function()
	exit_visual_mode()
	copy_visual_selection_reference(absolute_file_path())
end, { desc = "Copy absolute reference (visual selection)" })

vim.keymap.set("n", "<Leader>C", function()
	copy_file_reference(absolute_file_path(), "")
end, { desc = "Copy absolute reference (file)" })

local function open_reference(input)
	-- Pattern matches path/to/file.ext:start-end, where both the leading @ and
	-- the :start-end line range are optional
	local reference = input:gsub("^@", "")
	local path, start_line, end_line = reference:match("^([^:]+):(%d+)%-(%d+)$")
	path = path or reference:match("^([^:]+)$")

	if not path then
		print("Invalid reference format. Use: path/to/file or path/to/file:start-end")
		return
	end

	-- Open the file
	vim.cmd("edit " .. path)

	-- Without a line range, stay in normal mode on the freshly opened file
	if start_line then
		-- Set cursor to the start line (1st column)
		vim.api.nvim_win_set_cursor(0, { tonumber(start_line), 0 })

		-- Enter Visual Line mode (V)
		vim.cmd("normal! V")

		-- Move cursor to the end line to complete the selection
		vim.api.nvim_win_set_cursor(0, { tonumber(end_line), 0 })
	end
end

vim.api.nvim_create_user_command("Reselect", function(opts)
	open_reference(opts.args)
end, {
	nargs = 1,
	desc = "Take a file name + line number reference as defined with <Leader>c, and reselect it in the codebase",
})
