vim.g.mapleader = " "

-- vim.keymap.set throughout rather than vim.api.nvim_set_keymap: the low-level
-- API leaves mappings remappable by default, so a plugin that later maps <C-a>
-- would change what <Leader>+ does.
vim.keymap.set("i", "jk", "<Esc>", { desc = "Escape" })
-- Remap the uppercase version as well, in case caps lock or caps word is on
vim.keymap.set("i", "JK", "<Esc>", { desc = "Escape" })
vim.keymap.set("n", "<Leader>q", "<Cmd>q!<CR>", { desc = "Exit without saving" })
-- <Cmd> runs the command without entering command-line mode, so nothing flashes
-- in the cmdline on the way through
vim.keymap.set("n", "<Leader>s", "<Cmd>w<CR>", { desc = "Save" })
-- Restart, keeping the current buffers/windows/tabs. `:restart` accepts a
-- command to run on the new server (`:h :restart`), so we write a session file
-- first, then source and delete it once the new server is up.
local restart_session = vim.fs.joinpath(vim.fn.stdpath("state"), "restart-session.vim")

vim.keymap.set("n", "<Leader>t", function()
	vim.cmd("mksession! " .. vim.fn.fnameescape(restart_session))
	-- `concerned.restart` is required by path rather than here, because the new
	-- server can run this command before it has sourced init.lua. The config
	-- directory is on the runtimepath from the very start, so the require works
	-- either way.
	vim.cmd(('restart lua require("concerned.restart").restore(%q)'):format(restart_session))
end, { desc = "Restart Neovim while preserving buffers" })

vim.keymap.set("n", "<Leader><Leader>", "<Cmd>nohl<CR>", { desc = "Clear highlights" })
vim.keymap.set("n", "<Leader>+", "<C-a>", { desc = "Increment number" }) -- increment
vim.keymap.set("n", "<Leader>-", "<C-x>", { desc = "Decrement number" }) -- decrement

vim.keymap.set({ "n" }, "<BS>", "<C-^>", { desc = "Previous file" })

vim.keymap.set({ "n", "x" }, "<Leader>gb", ":GBrowse!<CR>", { desc = "Git browse" })
vim.keymap.set({ "n", "x" }, "<Leader>gd", "<Cmd>Gdiff<CR>", { desc = "Git diff" })

vim.keymap.set("n", "<Leader>ea", "<Cmd>e ~/Documents/AGENDA.md<CR>", { desc = "Open agenda" })
vim.keymap.set("n", "<Leader>en", "<Cmd>e ~/Documents/NOTES.md<CR>", { desc = "Open notes" })

-- Keep the selection after indenting, so a block can be nudged over repeatedly
-- without reselecting it each time
vim.keymap.set("x", ">", ">gv", { desc = "Indent and keep selection" })
vim.keymap.set("x", "<", "<gv", { desc = "Dedent and keep selection" })

-- Centre the match and open just enough folds to see it
vim.keymap.set("n", "n", "nzzzv", { desc = "Next search match" })
vim.keymap.set("n", "N", "Nzzzv", { desc = "Previous search match" })

-- Single <Esc> belongs to whatever is running in the terminal (lazygit and yazi
-- both use it), so it takes two to get back to normal mode.
vim.keymap.set("t", "<Esc><Esc>", "<C-\\><C-n>", { desc = "Exit terminal mode" })

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
