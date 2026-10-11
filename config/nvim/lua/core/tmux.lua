-- Working alongside Claude Code in the tmux window next door

local CLAUDE_WINDOW = ":=claude"
local RELOAD_INTERVAL_MS = 1000

-- Pick up files Claude edits on disk (needs `focus-events on` in tmux)
vim.o.autoread = true
vim.api.nvim_create_autocmd({ "FocusGained", "BufEnter", "CursorHold", "TermLeave" }, {
	group = vim.api.nvim_create_augroup("claude_autoread", { clear = true }),
	callback = function()
		if vim.fn.mode() ~= "c" and vim.fn.getcmdwintype() == "" then
			vim.cmd("checktime")
		end
	end,
})

-- Claude can be docked beside the editor, where nvim never regains focus: poll so its edits show as they land
local reload_timer = vim.uv.new_timer()
reload_timer:start(RELOAD_INTERVAL_MS, RELOAD_INTERVAL_MS, vim.schedule_wrap(function()
	if vim.fn.mode() ~= "c" and vim.fn.getcmdwintype() == "" then
		vim.cmd("silent! checktime")
	end
end))

-- tms tags Claude's pane, so it is found in its own window or docked in this one
local function claude_pane()
	local listed = vim.system({ "tmux", "list-panes", "-s", "-F", "#{pane_id} #{@tms_role}" }):wait()
	for pane, role in (listed.stdout or ""):gmatch("(%%%d+) (%S+)") do
		if role == "claude" then
			return pane
		end
	end
	return CLAUDE_WINDOW
end

local function send_to_claude(text)
	if not vim.env.TMUX then
		vim.notify("Not inside tmux", vim.log.levels.WARN)
		return
	end
	local target = claude_pane()
	local sent = vim.system({ "tmux", "send-keys", "-t", target, "-l", text }):wait()
	if sent.code ~= 0 then
		vim.notify("No claude window in this session (prefix + a opens one)", vim.log.levels.WARN)
		return
	end
	vim.system({ "tmux", "select-window", "-t", target }):wait()
	vim.system({ "tmux", "select-pane", "-t", target }):wait()
end

local function current_file()
	local name = vim.api.nvim_buf_get_name(0)
	if name == "" then
		return nil
	end
	return vim.fn.fnamemodify(name, ":.")
end

vim.keymap.set("n", "<leader>af", function()
	local file = current_file()
	if file then
		send_to_claude("@" .. file .. " ")
	end
end, { desc = "Claude: reference this file" })

vim.keymap.set("v", "<leader>as", function()
	local file = current_file()
	if not file then
		return
	end
	local first, last = vim.fn.line("v"), vim.fn.line(".")
	if first > last then
		first, last = last, first
	end
	send_to_claude(("@%s lines %d-%d "):format(file, first, last))
end, { desc = "Claude: reference selected lines" })
