-- Telescope picker over the CRUX code reviews (code.amazon.com) that are open
-- on the Brazil package in the current git repository.
--
-- Two internal endpoints back this, both authenticated with the Midway cookie
-- jar that `mwinit` writes:
--   * the CRUX dashboard API, for the list of open reviews on a package
--   * the Code Browser review page in its JSON form, for the detail in the
--     preview (title, description, approvals, analyzers, ...)
--
-- Requires the Builder Toolbox and a current Midway session; both are reported
-- as errors when the picker is opened rather than gated out of existence.
--
--   require("concerned.crux").reviews()   -- also :CodeReviews [Package]
--
-- Everything the user is asked is a telescope picker, so <Esc> and <C-c> close
-- it and choose nothing throughout, and nothing is opened until after the
-- picker it was chosen from has finished closing. A detail fetch still in flight
-- when a picker goes away simply writes nowhere: the preview checks its buffer
-- is still valid, and `payload_cache` keeps the answer for next time. Declining
-- the approval confirmation leaves the review untouched — nothing is sent until
-- the "Yes" line is chosen.
--
-- What there is to do with a review is the picker's own mappings rather than a
-- menu of its own, so the preview stays up while you act and the list survives
-- the ones that only copy or open something. <C-/> lists them.

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

--- Pick one of `labels`, as a telescope picker in the middle of the screen
--- rather than the `vim.ui.select` default: the lines are moved between with
--- <C-n>/<C-p> and narrowed by typing, instead of being read off by number.
--- <Esc> and <C-c> are telescope's own close mappings and choose nothing.
local function select_one(labels, opts, on_choice)
	local pickers = require("telescope.pickers")
	local finders = require("telescope.finders")
	local conf = require("telescope.config").values
	local actions = require("telescope.actions")
	local action_state = require("telescope.actions.state")
	local themes = require("telescope.themes")

	-- Wide enough for the longest line and tall enough for all of them: menus
	-- this short should never need scrolling. The center layout counts the prompt
	-- and the three border rows in its height, and the caret in its width.
	local width = #(opts.prompt or "")
	for _, label in ipairs(labels) do
		width = math.max(width, #label)
	end

	pickers
		.new(
			themes.get_dropdown({
				layout_config = { width = width + 6, height = #labels + 4 },
			}),
			{
				-- The prompts here read as a question or a label, which the border
				-- title already punctuates
				prompt_title = (opts.prompt or "Select one"):gsub("[:%s]+$", ""),
				finder = finders.new_table({ results = labels }),
				sorter = conf.generic_sorter({}),
				attach_mappings = function(prompt_bufnr)
					actions.select_default:replace(function()
						-- Nothing is selected when the prompt matches no line
						local entry = action_state.get_selected_entry()
						actions.close(prompt_bufnr)
						if entry then
							-- Let the close finish first: some of these open a
							-- window, or another menu, of their own
							vim.schedule(function()
								on_choice(entry[1])
							end)
						end
					end)
					return true
				end,
			}
		)
		:find()
end

--- What is missing before any of this can work, as a message to show the user.
--- Both of these are otherwise only discoverable as a failing curl or a command
--- that is not there.
local function unmet_requirement()
	if not vim.uv.fs_stat(TOOLBOX) then
		return "Builder Toolbox is not installed — this only works on an Amazon machine"
	end
	if not vim.uv.fs_stat(COOKIE) then
		return "No Midway cookie at " .. COOKIE .. " — run `mwinit`"
	end
	return nil
end

-- Fetch JSON with the Midway cookie. `-u:` gets curl to send credentials on the
-- redirect through midway-auth; we deliberately leave out `-c` because several
-- of these can be in flight at once and we'd rather not have them race to
-- rewrite the user's cookie jar.
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

--- Put the same lines the preview shows into a throwaway buffer, where they can
--- be read at full width, searched and yanked from. It takes over the window the
--- menu was called from, so `q` puts the previous buffer back rather than
--- closing a window the user did not ask for.
local function open_detail_buffer(cr, lines)
	local bufnr = vim.api.nvim_create_buf(false, true)
	vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, lines)
	-- A name makes the buffer findable, but a stale wiped one may still hold it
	pcall(vim.api.nvim_buf_set_name, bufnr, "crux://" .. cr)
	vim.bo[bufnr].filetype = "markdown"
	vim.bo[bufnr].modifiable = false
	vim.bo[bufnr].bufhidden = "wipe"
	vim.keymap.set("n", "q", "<Cmd>bdelete<CR>", { buffer = bufnr, desc = "Close review details" })

	vim.api.nvim_win_set_buf(0, bufnr)
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

--- Approve the latest revision of a review. CRUX only takes this over its web
--- routes, which want the CSRF token from the review page and the session
--- cookie that token was issued against — hence the throwaway jar, which keeps
--- these writes away from the Midway jar the read paths share.
local function approve(cr, revision)
	local jar = vim.fn.tempname()
	local page = REVIEW_URL .. cr .. "/revisions/" .. revision

	local function done(msg, level)
		os.remove(jar)
		notify(msg, level)
	end

	notify("Approving " .. cr .. " revision " .. revision .. "...")
	vim.system({
		"curl",
		"-sS",
		"-L",
		"--location-trusted",
		"-u",
		":",
		"-b",
		COOKIE,
		"-c",
		jar,
		page,
	}, { text = true }, function(res)
		local html = res.stdout or ""
		local token = html:match('name="csrf%-token"[^>]-content="([^"]+)"')
			or html:match('content="([^"]+)"[^>]-name="csrf%-token"')
		if not token then
			return vim.schedule(function()
				done("Could not read a CSRF token from " .. page, vim.log.levels.ERROR)
			end)
		end

		vim.system({
			"curl",
			"-sS",
			"-L",
			"--location-trusted",
			"-u",
			":",
			"-b",
			jar,
			"-X",
			"POST",
			"-H",
			"X-CSRF-Token: " .. token,
			"-H",
			"Accept: application/json",
			"-o",
			"/dev/null",
			"-w",
			"%{http_code}",
			page .. "/approve",
		}, { text = true }, function(post)
			vim.schedule(function()
				local code = vim.trim(post.stdout or "")
				if code ~= "200" then
					return done(("Could not approve %s (HTTP %s)"):format(cr, code), vim.log.levels.ERROR)
				end
				-- The cached payload now has a stale approval map
				payload_cache[cr] = nil
				done("✅ Approved " .. cr .. " revision " .. revision)
			end)
		end)
	end)
end

--- Ask before approving, since it is the one action here that other people see.
local function confirm_approval(cr)
	with_payload(cr, function(payload, err)
		if err then
			return notify(err, vim.log.levels.ERROR)
		end

		local revision = (((payload.revision or {}).cr_revision or {}).id or {}).review_revision_id or {}
		revision = revision.revision
		if not revision then
			return notify("Could not tell which revision of " .. cr .. " to approve", vim.log.levels.ERROR)
		end

		local yes = ("Yes, approve revision %s"):format(revision)
		select_one({ "Cancel", yes }, {
			prompt = ("Approve %s?"):format(cr),
		}, function(choice)
			if choice == yes then
				approve(cr, revision)
			else
				notify(cr .. " not approved")
			end
		end)
	end, function()
		notify("Loading " .. cr .. "...")
	end)
end

--- Bind the things worth doing with a review to the reviews picker itself. Every
--- mapping carries a `desc`, which is what <C-/> reads its list out of, so these
--- are as nameable as the menu they replaced.
local function attach_actions(prompt_bufnr, map, cwd)
	local actions = require("telescope.actions")
	local action_state = require("telescope.actions.state")

	--- Act on the review under the cursor, leaving the picker up. Nothing is
	--- selected when the prompt matches no review.
	local function on_review(fn)
		return function()
			local entry = action_state.get_selected_entry()
			if entry then
				fn(entry.cr)
			end
		end
	end

	--- The same, for the ones that want a window or a prompt of their own: the
	--- picker is closed first and they run once it has finished going away.
	local function instead_of_picker(fn)
		return on_review(function(cr)
			actions.close(prompt_bufnr)
			vim.schedule(function()
				fn(cr)
			end)
		end)
	end

	--- Report something that happened without the picker going anywhere. A plain
	--- `vim.notify` lands on the cmdline, which is a line you are not looking at
	--- while the picker has your attention and which telescope redraws over on the
	--- next keystroke, so put it in the prompt's own title for a moment too. Still
	--- notified as well, to leave the text in `:messages`.
	local flashes = 0
	local function say(message)
		notify(message)

		local picker = action_state.get_current_picker(prompt_bufnr)
		local border = picker and picker.layout.prompt and picker.layout.prompt.border
		if not border then
			return
		end

		flashes = flashes + 1
		local flash = flashes
		border:change_title(message)
		vim.defer_fn(function()
			-- The picker may be gone, or a later message may have taken the title
			-- over, in which case that one owns putting it back
			if flash == flashes and vim.api.nvim_buf_is_valid(prompt_bufnr) then
				border:change_title(picker.prompt_title)
			end
		end, 1000)
	end

	local function view_details(cr)
		with_payload(cr, function(payload, err)
			if err then
				return notify(err, vim.log.levels.ERROR)
			end
			open_detail_buffer(cr, render_detail(payload))
		end, function()
			notify("Loading " .. cr .. "...")
		end)
	end

	-- Checking out is the one worth reaching for without looking
	actions.select_default:replace(instead_of_picker(function(cr)
		-- `enew` keeps the terminal in the window the picker was called from; the
		-- buffer that was there is still in the list, so `:b#` brings it back
		vim.cmd.enew()
		vim.fn.jobstart({ "cr-pull", cr }, { term = true, cwd = cwd })
		vim.cmd.startinsert()
	end))

	map({ "i", "n" }, "<C-o>", instead_of_picker(view_details), { desc = "View details in a buffer" })

	-- These three leave the list and the prompt alone, which is most of the reason
	-- to bind them: you can copy or open three reviews in a row
	map({ "i", "n" }, "<C-b>", on_review(function(cr)
		vim.ui.open(REVIEW_URL .. cr)
		say("Opened " .. cr .. " in the browser")
	end), { desc = "Open in browser" })

	map({ "i", "n" }, "<C-y>", on_review(function(cr)
		vim.fn.setreg("+", REVIEW_URL .. cr)
		say("Copied " .. REVIEW_URL .. cr)
	end), { desc = "Copy CR URL" })

	map({ "i", "n" }, "<C-e>", on_review(function(cr)
		vim.fn.setreg("+", cr)
		say("Copied " .. cr)
	end), { desc = "Copy CR ID" })

	-- Approve is the only one of these other people see, so it wants a key that is
	-- nowhere near <CR> — the confirmation is what actually guards it.
	--
	-- <C-g> rather than the <C-a> this asks for because tmux holds that as its
	-- prefix, and no <M-…> because kitty leaves macos_option_as_alt off, so Option
	-- composes a character instead of sending a modifier. That leaves the keys
	-- telescope has not already taken for movement, preview scrolling, splits and
	-- the quickfix list: <C-b>, <C-e>, <C-g>, <C-o> and <C-y>.
	map({ "i", "n" }, "<C-g>", instead_of_picker(confirm_approval), { desc = "Approve" })
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

	-- The working directory, not the open file: with a file from elsewhere on
	-- screen the package you are working in is still the one you want.
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
