-- lua/diagnostic-hover/float.lua

local M = {}

-- Map severity to highlight group
local severity_hl = {
	[1] = "DiagnosticError",
	[2] = "DiagnosticWarn",
	[3] = "DiagnosticInfo",
	[4] = "DiagnosticHint",
}

-- Map severity to icon key
local severity_icon_key = {
	[1] = "Error",
	[2] = "Warn",
	[3] = "Info",
	[4] = "Hint",
}

-- Check if source labels should be shown
local function should_show_source(diagnostics, source_config)
	if source_config == "always" then
		return true
	end
	if source_config == "if_many" then
		local sources = {}
		for _, diag in ipairs(diagnostics) do
			if diag.source then
				sources[diag.source] = true
			end
		end
		local count = 0
		for _ in pairs(sources) do
			count = count + 1
		end
		return count > 1
	end
	return false
end

-- Format diagnostics into lines and highlights for the float buffer
-- Returns { lines = string[], highlights = { line, col_start, col_end, hl_group }[] }
M.format_diagnostics = function(diagnostics, config)
	local lines = {}
	local highlights = {}
	local show_source = should_show_source(diagnostics, config.float_opts.source)

	for i, diag in ipairs(diagnostics) do
		local icon_key = severity_icon_key[diag.severity] or "Error"
		local hl_group = severity_hl[diag.severity] or "DiagnosticError"

		-- Message line: <icon> <message> or just <message>
		local msg_line
		if config.use_icons then
			local icon = config.diagnostic_icons[icon_key]
			msg_line = icon .. " " .. diag.message
		else
			msg_line = diag.message
		end
		table.insert(lines, msg_line)
		table.insert(highlights, {
			line = #lines - 1,
			col_start = 0,
			col_end = #msg_line,
			hl_group = hl_group,
		})

		-- Source line
		if show_source and diag.source then
			local source_line = "  source: " .. diag.source
			table.insert(lines, source_line)
			table.insert(highlights, {
				line = #lines - 1,
				col_start = 0,
				col_end = #source_line,
				hl_group = "Comment",
			})
		end

		-- Divider between diagnostics (not after the last one)
		if i < #diagnostics then
			local max_width = config.float_opts.max_width or 50
			local divider = string.rep("─", max_width - 2)
			table.insert(lines, divider)
			table.insert(highlights, {
				line = #lines - 1,
				col_start = 0,
				col_end = #divider,
				hl_group = "FloatBorder",
			})
		end
	end

	return { lines = lines, highlights = highlights }
end

-- Open a custom float window showing diagnostics for the current line
-- Returns winid or nil
M.open = function(bufnr, config)
	local curline = vim.api.nvim_win_get_cursor(0)[1]
	local diagnostics = vim.diagnostic.get(bufnr, { lnum = curline - 1 })

	if #diagnostics == 0 then
		return nil
	end

	-- Sort by severity
	table.sort(diagnostics, function(a, b)
		return a.severity < b.severity
	end)

	local formatted = M.format_diagnostics(diagnostics, config)

	-- Create scratch buffer
	local float_buf = vim.api.nvim_create_buf(false, true)
	vim.api.nvim_buf_set_lines(float_buf, 0, -1, false, formatted.lines)
	vim.bo[float_buf].modifiable = false

	-- Apply highlights
	local ns = vim.api.nvim_create_namespace("diagnostic_hover_float")
	for _, hl in ipairs(formatted.highlights) do
		vim.api.nvim_buf_add_highlight(float_buf, ns, hl.hl_group, hl.line, hl.col_start, hl.col_end)
	end

	-- Calculate window dimensions
	local max_width = config.float_opts.max_width or 50
	local width = 0
	for _, line in ipairs(formatted.lines) do
		width = math.max(width, vim.fn.strdisplaywidth(line))
	end
	width = math.min(width + 2, max_width)
	local height = #formatted.lines

	-- Open float window
	local winid = vim.api.nvim_open_win(float_buf, false, {
		relative = "cursor",
		row = 1,
		col = 0,
		width = width,
		height = height,
		style = config.float_opts.style or "minimal",
		border = config.float_opts.border or "single",
		focusable = config.float_opts.focus or false,
	})

	return winid
end

-- Close a float window if it is valid
M.close = function(winid)
	if winid and vim.api.nvim_win_is_valid(winid) then
		vim.api.nvim_win_close(winid, false)
	end
end

return M
