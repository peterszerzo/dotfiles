-- Telescope picker over the CRUX code reviews (code.amazon.com) that are open
-- on the Brazil package in the current git repository.
--
-- There are two things to do with the review under the cursor: <CR> checks it
-- out with `cr-pull`, and <C-o> hands it to `cruxi`. Both are read-only on the
-- review itself — nothing here writes to CRUX.

local M = {}

local TOOLBOX = vim.fn.expand("~/.toolbox")
local COOKIE = vim.fn.expand("~/.midway/cookie")
local DASHBOARD_API = "https://prod.api.dashboard.crux.builder-tools.aws.dev/api/v1"
local REVIEW_URL = "https://code.amazon.com/reviews/"

-- CR id -> decoded review page JSON. Previews are re-rendered every time the
-- cursor moves, so without this every pass down the list refetches.
local payload_cache = {}

local function notify(msg, level)
	vim.notify(msg, level or vim.log.levels.INFO, { title = "CRUX" })
end

local function unmet_requirement()
	if not vim.uv.fs_stat(TOOLBOX) then
		return "Builder Toolbox is not installed — this only works on an Amazon machine"
	end
	if not vim.uv.fs_stat(COOKIE) then
		return "No Midway cookie at " .. COOKIE .. " — run `mwinit`"
	end
	return nil
end

-- Fetch JSON with the Midway cookie
local function fetch_json(url, on_done)
	local cmd = {
		"curl",
		"-sS",
		"-L",
		"--location-trusted",
		"-u",
		":",
		"-b",
		COOKIE,
		"-H",
		"Accept: application/json",
		url,
	}

	vim.system(cmd, { text = true }, function(res)
		if res.code ~= 0 then
			return on_done(nil, vim.trim(res.stderr or "") ~= "" and vim.trim(res.stderr) or "curl failed")
		end

		local ok, decoded = pcall(vim.json.decode, res.stdout)
		if not ok or type(decoded) ~= "table" then
			return on_done(nil, "response was not JSON")
		end

		-- Midway hands back a JSON error body rather than a redirect when the
		-- cookie has expired, which is the failure worth naming explicitly.
		if decoded.message == "Unauthenticated" then
			return on_done(nil, "Midway session expired — run `mwinit`")
		end

		on_done(decoded, nil)
	end)
end

--- Name of the Brazil package for the git repository containing `path`.
--- GitFarm remotes look like ssh://git.amazon.com:2222/pkg/PackageName, and for
--- a Brazil workspace the directory name matches the package, so fall back to
--- that when there is no usable remote.
local function package_name(path)
	local root = vim.system({ "git", "-C", path, "rev-parse", "--show-toplevel" }, { text = true }):wait()
	if root.code ~= 0 then
		return nil, nil
	end
	root = vim.trim(root.stdout)

	local remote = vim.system({ "git", "-C", root, "remote", "get-url", "origin" }, { text = true }):wait()
	if remote.code == 0 then
		local name = vim.trim(remote.stdout):gsub("%.git$", ""):match("/pkg/([^/]+)$")
		if name then
			return name, root
		end
	end

	return vim.fs.basename(root), root
end

--- The review checked out in the repository at `root`, if there is one.
--- `cr-pull` names its branches CRUX/CR-1234/r2/<their-branch>, and `cr` leaves
--- a `cr: <url>` trailer on the commits it reviews, which covers the reviews you
--- wrote yourself.
local function checked_out_cr(root)
	local branch = vim.system({ "git", "-C", root, "rev-parse", "--abbrev-ref", "HEAD" }, { text = true }):wait()
	if branch.code == 0 then
		local cr = vim.trim(branch.stdout):match("^CRUX/(CR%-%d+)/")
		if cr then
			return cr
		end
	end

	local log = vim.system({ "git", "-C", root, "log", "-n", "10", "--format=%B" }, { text = true }):wait()
	if log.code == 0 then
		return (log.stdout:match("code%.amazon%.com/reviews/(CR%-%d+)"))
	end
	return nil
end

local function relative_time(epoch)
	local seconds = math.max(os.time() - epoch, 0)
	local scale = {
		{ 60, "second" },
		{ 60, "minute" },
		{ 24, "hour" },
		{ 7, "day" },
		{ 4, "week" },
		{ 12, "month" },
		{ math.huge, "year" },
	}

	local value = seconds
	for _, step in ipairs(scale) do
		if value < step[1] then
			return ("%d %s%s ago"):format(value, step[2], value == 1 and "" or "s")
		end
		value = math.floor(value / step[1])
	end
end

local function absolute_time(epoch)
	return os.date("%Y-%m-%d %H:%M", epoch)
end

-- CRUX timestamps come back as "2026-08-25T13:46:19.000Z"
local function parse_timestamp(iso)
	if type(iso) ~= "string" then
		return nil
	end
	local y, mo, d, h, mi, s = iso:match("^(%d+)%-(%d+)%-(%d+)T(%d+):(%d+):(%d+)")
	if not y then
		return nil
	end
	local utc = os.time({ year = y, month = mo, day = d, hour = h, min = mi, sec = s, isdst = false })
	-- os.time interprets the table as local time, so correct for the offset
	return utc + os.difftime(os.time(), os.time(os.date("!*t")))
end

--- Squash an analyzer message down to something that fits on one preview line.
--- They arrive as markdown, often several paragraphs of links and emoji.
local function oneline(message)
	if type(message) ~= "string" then
		return ""
	end
	message = message:gsub("%[([^%]]*)%]%([^%)]*%)", "%1"):gsub("%s+", " ")
	message = vim.trim(message)
	if #message > 90 then
		message = message:sub(1, 89) .. "…"
	end
	return message
end

-- Every icon here is two terminal cells wide, so the byte-counted padding in
-- the preview's format strings still lines up underneath them.
local ANALYZER_ICONS = {
	pass = "✅",
	passed = "✅",
	fail = "❌",
	failed = "❌",
	error = "❌",
	blocked = "⛔",
	pending = "⏳",
	running = "⏳",
	["in progress"] = "⏳",
	warning = "🟡",
	skipped = "➖",
	["n/a"] = "➖",
}

local REVIEW_ICONS = {
	OPEN = "🟢",
	PENDING = "📝",
	MERGED = "🎉",
	CLOSED = "🚫",
	CANCELED = "🚫",
	CANCELLED = "🚫",
}

local function analyzer_icon(status)
	return ANALYZER_ICONS[tostring(status):lower()] or "❔"
end

--- Human label for an approval_map key such as "USER:jhampl" or "TEAM:amzn1...".
local function entity_label(key)
	local kind, id = key:match("^(%u+):(.*)$")
	if not kind then
		return key
	elseif kind == "USER" then
		return id
	elseif kind == "TEAM" then
		return "team " .. (id:match("([^.]+)$") or id)
	elseif kind == "SNS" then
		return "sns " .. (id:match("([^:]+)$") or id)
	end
	return kind:lower() .. " " .. id
end

--- Whether one approval_map entry is satisfied. `requirements_met` accounts for
--- things the raw counts do not, such as a protected reviewer, so trust it when
--- the service sends it.
local function requirement_met(entry)
	if type(entry.requirements_met) == "boolean" then
		return entry.requirements_met
	end
	return (entry.granted or 0) >= (entry.required or 0)
end

--- Whether every approval requirement on the revision has been met, alongside a
--- one-line explanation. Requirements live in approval_map keyed by reviewer,
--- with `required` approvals needed and `granted` collected so far.
local function approval_summary(approval_map)
	local required_total, granted_total, outstanding = 0, 0, {}

	for key, entry in pairs(approval_map or {}) do
		local required = entry.required or 0
		if required > 0 then
			required_total = required_total + required
			granted_total = granted_total + math.min(entry.granted or 0, required)
			if not requirement_met(entry) then
				table.insert(outstanding, entity_label(key))
			end
		end
	end

	if required_total == 0 then
		return "➖ n/a — no required approvers"
	end

	table.sort(outstanding)
	if #outstanding == 0 then
		return ("✅ approved — %d of %d"):format(granted_total, required_total)
	end
	return ("⏳ not yet — %d of %d, waiting on %s"):format(
		granted_total,
		required_total,
		table.concat(outstanding, ", ")
	)
end

local function render_detail(payload)
	local revision = (payload.revision or {}).cr_revision or {}
	local id = (revision.id or {}).review_revision_id or {}
	local lines = {}

	local function add(line)
		table.insert(lines, line or "")
	end

	local function fact(label, value)
		add(("%-13s%s"):format(label, value))
	end

	add("# " .. (revision.summary or "(no title)"))
	add()
	add(("%s · revision %s"):format(id.cr or "?", id.revision or "?"))
	add(REVIEW_URL .. (id.cr or ""))
	add()

	local status = revision.status or "?"
	fact(
		"Status",
		("%s %s · %s"):format(
			REVIEW_ICONS[status] or "❔",
			status,
			status == "PENDING" and "unpublished draft" or "published"
		)
	)
	fact("Approved", approval_summary(payload.approval_map))
	fact("Author", ((revision.author or {}).entity_id or {}).id or "?")

	-- The dry run build is the analyzer worth pulling up out of the list
	for _, analyzer in ipairs(payload.analyzers or {}) do
		if analyzer.partner_id == "Dry Run Build" then
			fact(
				"Dry run",
				("%s %s — %s"):format(
					analyzer_icon(analyzer.status),
					analyzer.status or "?",
					oneline(analyzer.status_message)
				)
			)
		end
	end

	fact("Category", revision.category or "—")

	local packages = {}
	for _, entry in ipairs(revision.packages or {}) do
		table.insert(packages, (entry.package or {}).name)
	end
	fact("Packages", #packages > 0 and table.concat(packages, ", ") or "—")

	if #(revision.tags or {}) > 0 then
		fact("Tags", table.concat(revision.tags, ", "))
	end

	for _, stamp in ipairs({ { "Created", "created_at" }, { "Updated", "last_updated_at" } }) do
		local epoch = parse_timestamp(revision[stamp[2]])
		if epoch then
			fact(stamp[1], ("%s (%s)"):format(absolute_time(epoch), relative_time(epoch)))
		end
	end

	fact("Auto-publish", revision.auto_publish and "on" or "off")
	fact("Merging", revision.pull_requests_allowed and "allowed" or "blocked")

	add()
	add("## Analyzers")
	add()
	if #(payload.analyzers or {}) == 0 then
		add("_None have reported._")
	end
	for _, analyzer in ipairs(payload.analyzers or {}) do
		add(
			("  %s %-9s%-26s%s"):format(
				analyzer_icon(analyzer.status),
				analyzer.status or "?",
				analyzer.partner_id or "?",
				oneline(analyzer.status_message)
			)
		)
	end

	add()
	add("## Reviewers")
	add()
	local reviewers = {}
	for key, entry in pairs(payload.approval_map or {}) do
		local approvers = {}
		for _, approver in ipairs(entry.approvers or {}) do
			table.insert(approvers, approver.id)
		end

		local icon, note
		if (entry.required or 0) > 0 then
			icon = requirement_met(entry) and "✅" or "⏳"
			note = ("%d of %d approved"):format(math.min(entry.granted or 0, entry.required), entry.required)
		elseif #approvers > 0 then
			icon, note = "✅", "approved"
		else
			icon, note = "➖", "optional"
		end
		if #approvers > 0 then
			note = note .. " — " .. table.concat(approvers, ", ")
		end

		local label = entity_label(key)
		if #label > 32 then
			label = label:sub(1, 31) .. "…"
		end
		-- Sorted on the icon first, so whoever is still being waited on groups together
		table.insert(reviewers, ("  %s %-32s  %s"):format(icon, label, note))
	end
	table.sort(reviewers)
	if #reviewers == 0 then
		add("_None._")
	end
	vim.list_extend(lines, reviewers)

	add()
	add("## Description")
	add()
	local description = revision.description
	if type(description) == "string" and vim.trim(description) ~= "" then
		vim.list_extend(lines, vim.split(description, "\n", { plain = true }))
	else
		add("_No description._")
	end

	-- Analyzers post as AAA (service) principals, so separate them out from the
	-- comments an actual reviewer left. `importance == 1` is CRUX's blocking
	-- comment, and an unresolved one of those holds up the merge.
	local from_people, from_analyzers, unresolved, blocking, drafts = 0, 0, 0, 0, 0
	for _, entry in ipairs(revision.comments or {}) do
		local comment = entry.cr_comment or {}
		if comment.published == false then
			drafts = drafts + 1
		end
		if ((comment.author or {}).entity_id or {}).type == "USER" then
			from_people = from_people + 1
			if not comment.fixed then
				unresolved = unresolved + 1
				if comment.importance == 1 then
					blocking = blocking + 1
				end
			end
		else
			from_analyzers = from_analyzers + 1
		end
	end
	add()
	add("## Comments")
	add()
	if from_people == 0 then
		add("  ➖ none from reviewers")
	elseif unresolved == 0 then
		add(("  ✅ %d from reviewers, all resolved"):format(from_people))
	else
		add(("  💬 %d from reviewers · %d unresolved"):format(from_people, unresolved))
	end
	if blocking > 0 then
		add(("  🚨 %d blocking and unresolved — merge is held up"):format(blocking))
	end
	if from_analyzers > 0 then
		add(("  🤖 %d from analyzers"):format(from_analyzers))
	end
	if drafts > 0 then
		add(("  📝 %d unpublished draft%s of your own"):format(drafts, drafts == 1 and "" or "s"))
	end

	return lines
end

-- cruxi asks the terminal what it can do before it draws anything, and waits for
-- the answers: the background colour (OSC 11), the cell size in pixels (CSI 16t),
-- synchronized output and the two keyboard protocols. Nvim's built-in terminal
-- answers none of those, so cruxi sits on a blank screen until a keypress shakes
-- it loose. Answering on its behalf is what gets the first frame drawn — the
-- values are a plausible modern terminal rather than this one, which only the
-- pixel-exact features nothing here uses would notice.
local CAPABILITY_REPLIES = table.concat({
	"\27]11;rgb:1e1e/1e1e/1e1e\27\\", -- OSC 11: background colour
	"\27[6;20;10t", -- CSI 16t: cell size, 10x20 pixels
	"\27[?2026;2$y", -- DECRPM: synchronized output understood, currently off
	"\27[?2027;0$y", -- DECRPM: grapheme clustering not recognised
	"\27[>4;1m", -- modifyOtherKeys level 1
	"\27[?0u", -- Kitty keyboard protocol, no flags set
})

--- Hand the review over to `cruxi`, the CRUX terminal UI, in a floating terminal:
--- everything the preview only summarises is there, and can be acted on. The
--- float goes over whatever was on screen rather than taking a window away from
--- it, and closes again once cruxi exits.
local function open_review_terminal(cr, cwd)
	local width = math.min(vim.o.columns - 4, 160)
	local height = math.max(vim.o.lines - 6, 10)
	local bufnr = vim.api.nvim_create_buf(false, true)

	local win = vim.api.nvim_open_win(bufnr, true, {
		relative = "editor",
		width = width,
		height = height,
		row = math.floor((vim.o.lines - height) / 2) - 1,
		col = math.floor((vim.o.columns - width) / 2),
		style = "minimal",
		border = "rounded",
		title = " " .. cr .. " ",
		title_pos = "center",
	})

	local chan = vim.fn.jobstart({ "cruxi", cr }, {
		term = true,
		cwd = cwd,
		on_exit = function()
			-- The window may already be gone, closed out from under the job
			if vim.api.nvim_win_is_valid(win) then
				vim.api.nvim_win_close(win, true)
			end
		end,
	})

	-- Which query cruxi is waiting on, and whether it is reading yet, is not
	-- something we can see from here, so answer a few times over the first second
	-- and a half. A repeat that arrives after the frame is up is a response to a
	-- question nobody asked, which cruxi discards.
	for _, delay in ipairs({ 150, 600, 1500 }) do
		vim.defer_fn(function()
			pcall(vim.fn.chansend, chan, CAPABILITY_REPLIES)
		end, delay)
	end
	-- Closing the float should end the session rather than leave it hidden
	vim.bo[bufnr].bufhidden = "wipe"
	vim.cmd.startinsert()
end

--- The review page payload, from the cache when it is there and over the
--- network otherwise. `on_wait` runs only in the latter case, to say so.
local function with_payload(cr, on_payload, on_wait)
	if payload_cache[cr] then
		return on_payload(payload_cache[cr])
	end

	if on_wait then
		on_wait()
	end
	fetch_json(REVIEW_URL .. cr .. "?diffConfig=none", function(payload, err)
		vim.schedule(function()
			if err then
				return on_payload(nil, "Could not load " .. cr .. ": " .. err)
			end
			payload_cache[cr] = payload
			on_payload(payload)
		end)
	end)
end

local function attach_actions(prompt_bufnr, map, cwd)
	local actions = require("telescope.actions")
	local action_state = require("telescope.actions.state")

	local function instead_of_picker(fn)
		return function()
			local entry = action_state.get_selected_entry()
			if not entry then
				return
			end
			actions.close(prompt_bufnr)
			vim.schedule(function()
				fn(entry.cr)
			end)
		end
	end

	-- Checking out is the one worth reaching for without looking
	actions.select_default:replace(instead_of_picker(function(cr)
		-- `enew` keeps the terminal in the window the picker was called from; the
		-- buffer that was there is still in the list, so `:b#` brings it back
		vim.cmd.enew()
		vim.fn.jobstart({ "cr-pull", cr }, { term = true, cwd = cwd })
		vim.cmd.startinsert()
	end))

	-- <C-o> for "open", and one of the few keys telescope has not already taken for
	-- movement, preview scrolling, splits and the quickfix list
	map(
		{ "i", "n" },
		"<C-o>",
		instead_of_picker(function(cr)
			open_review_terminal(cr, cwd)
		end),
		{ desc = "Open in cruxi" }
	)
end

local function open_picker(package, cwd, reviews, current)
	local pickers = require("telescope.pickers")
	local finders = require("telescope.finders")
	local conf = require("telescope.config").values
	local previewers = require("telescope.previewers")
	local preview_utils = require("telescope.previewers.utils")
	local action_state = require("telescope.actions.state")
	local entry_display = require("telescope.pickers.entry_display")

	local displayer = entry_display.create({
		separator = "  ",
		items = { { width = 14 }, { width = 10 }, { width = 14 }, { remaining = true } },
	})

	local function make_entry(review)
		local updated = math.floor(review.updatedAt or 0)
		return {
			value = review,
			cr = review.crId,
			ordinal = table.concat({ review.title or "", review.author or "", review.crId or "" }, " "),
			display = function()
				return displayer({
					{ review.crId, "TelescopeResultsIdentifier" },
					{ review.author or "?", "TelescopeResultsComment" },
					{ updated > 0 and relative_time(updated) or "", "TelescopeResultsComment" },
					-- The one you have checked out is worth pointing at
					(review.crId == current and "▸ " or "") .. (review.title or ""),
				})
			end,
		}
	end

	local selected_index
	for index, review in ipairs(reviews) do
		if review.crId == current then
			selected_index = index
			break
		end
	end

	local previewer = previewers.new_buffer_previewer({
		title = "Code Review",
		get_buffer_by_name = function(_, entry)
			return entry.cr
		end,
		define_preview = function(self, entry)
			local bufnr = self.state.bufnr

			local function show(lines)
				if not vim.api.nvim_buf_is_valid(bufnr) then
					return
				end
				vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, lines)
				preview_utils.highlighter(bufnr, "markdown")
			end

			with_payload(entry.cr, function(payload, err)
				-- The preview may have moved on to another review while we waited
				local selected = action_state.get_selected_entry()
				if payload and selected and selected.cr ~= entry.cr then
					return
				end
				show(err and { err } or render_detail(payload))
			end, function()
				show({ "Loading " .. entry.cr .. "..." })
			end)
		end,
	})

	pickers
		.new({}, {
			prompt_title = "Open Code Reviews · " .. package,
			finder = finders.new_table({ results = reviews, entry_maker = make_entry }),
			sorter = conf.generic_sorter({}),
			previewer = previewer,
			default_selection_index = selected_index,
			attach_mappings = function(prompt_bufnr, map)
				attach_actions(prompt_bufnr, map, cwd)
				return true
			end,
		})
		:find()
end

--- Pick among the code reviews open on a Brazil package. Defaults to the package
--- owning the repository of the working directory. Safe to pass straight to
--- `vim.keymap.set`, which calls it without arguments.
function M.reviews(package)
	local missing = unmet_requirement()
	if missing then
		return notify(missing, vim.log.levels.ERROR)
	end

	if type(package) ~= "string" or package == "" then
		package = nil
	end

	local cwd = vim.fn.getcwd()

	local root = cwd
	if not package then
		package, root = package_name(cwd)
		if not package then
			return notify("Not in a git repository", vim.log.levels.WARN)
		end
	end

	notify("Fetching open reviews for " .. package .. "...")
	fetch_json(DASHBOARD_API .. "/packages/" .. package .. "/reviews", function(payload, err)
		vim.schedule(function()
			if err then
				return notify("Could not fetch reviews for " .. package .. ": " .. err, vim.log.levels.ERROR)
			end

			local reviews = payload.reviews or {}
			if #reviews == 0 then
				return notify("No open code reviews on " .. package)
			end

			open_picker(package, root, reviews, checked_out_cr(root))
		end)
	end)
end

vim.api.nvim_create_user_command("CodeReviews", function(opts)
	M.reviews(opts.args)
end, { nargs = "?", desc = "Search open code reviews for a Brazil package" })

return M
