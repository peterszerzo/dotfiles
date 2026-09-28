-- Session restore for the `<Leader>t` restart mapping in `concerned.core.keymaps`.
local M = {}

-- Detect the filetype of every restored file buffer that came back without one.
local function detect_missing_filetypes()
	for _, buf in ipairs(vim.api.nvim_list_bufs()) do
		local missing = vim.bo[buf].filetype == "" and vim.bo[buf].buftype == ""
		if missing and vim.api.nvim_buf_is_loaded(buf) and vim.api.nvim_buf_get_name(buf) ~= "" then
			vim.api.nvim_buf_call(buf, function()
				vim.cmd("filetype detect")
			end)
		end
	end
end

local function source(session)
	vim.cmd.source(session)
	vim.fn.delete(session)
	vim.schedule(detect_missing_filetypes)
end

function M.restore(session)
	if vim.v.vim_did_enter == 1 then
		source(session)
	else
		vim.api.nvim_create_autocmd("VimEnter", {
			once = true,
			callback = function()
				vim.schedule(function()
					source(session)
				end)
			end,
		})
	end
end

return M
