-- lua/diagnostic-hover/buffer.lua

local float = require("diagnostic-hover.float")

local M = {}

-- Get diagnostic highlight group and icon
local function get_diagnostic_info(severity, icons)
  if severity == vim.diagnostic.severity.ERROR then
    return "DiagnosticVirtualTextError", icons.Error
  elseif severity == vim.diagnostic.severity.WARN then
    return "DiagnosticVirtualTextWarn", icons.Warn
  elseif severity == vim.diagnostic.severity.INFO then
    return "DiagnosticVirtualTextInfo", icons.Info
  elseif severity == vim.diagnostic.severity.HINT then
    return "DiagnosticVirtualTextHint", icons.Hint
  else
    return "DiagnosticVirtualTextError", icons.Error
  end
end

-- Setup buffer-specific functionality
M.setup = function(bufnr, config)
  -- Skip certain filetypes
  if vim.tbl_contains(config.skip_filetypes, vim.bo[bufnr].filetype) then
    return
  end

  -- Store float window info
  local diagnostic_float = {
    winid = nil,
    line = nil,
  }

  -- Create namespace for custom virtual text
  local ns_id = vim.api.nvim_create_namespace("diagnostic_current_line")
  local last_line = nil

  -- Show virtual text on current line only
  local function update_virtual_text()
    if not config.show_virtual_text_on_current_line then
      return
    end

    local curline = vim.api.nvim_win_get_cursor(0)[1]

    -- Always clear previous virtual text first
    vim.api.nvim_buf_clear_namespace(bufnr, ns_id, 0, -1)

    -- Only proceed if line has changed
    if last_line == curline then
      return
    end

    last_line = curline
    local diagnostics = vim.diagnostic.get(bufnr, { lnum = curline - 1 })

    if #diagnostics == 0 then
      return
    end

    -- Sort by severity (most severe first)
    table.sort(diagnostics, function(a, b)
      return a.severity < b.severity
    end)

    if config.virtual_text_mode == "virt_lines" then
      -- Virt_lines mode: each diagnostic on its own line below the code (no float)
      local virt_lines = {}
      for _, diag in ipairs(diagnostics) do
        local hl_group, icon = get_diagnostic_info(diag.severity, config.diagnostic_icons)
        local line_chunks = {}
        if config.use_icons then
          table.insert(line_chunks, { icon, hl_group })
          table.insert(line_chunks, { " " .. diag.message, hl_group })
        else
          table.insert(line_chunks, { diag.message, hl_group })
        end
        table.insert(virt_lines, line_chunks)
      end

      vim.api.nvim_buf_set_extmark(bufnr, ns_id, curline - 1, -1, {
        virt_lines = virt_lines,
      })
    elseif config.virtual_text_mode == "inline" then
      -- Inline mode: all diagnostics concatenated on one line (no float)
      local virt_text = {}
      for i, diag in ipairs(diagnostics) do
        local hl_group, icon = get_diagnostic_info(diag.severity, config.diagnostic_icons)
        if i > 1 then
          table.insert(virt_text, { config.inline_separator, "Comment" })
        end
        if config.use_icons then
          table.insert(virt_text, { icon, hl_group })
          table.insert(virt_text, { " " .. diag.message, hl_group })
        else
          table.insert(virt_text, { diag.message, hl_group })
        end
      end

      vim.api.nvim_buf_set_extmark(bufnr, ns_id, curline - 1, -1, {
        virt_text = virt_text,
        virt_text_pos = "eol",
      })
    else
      -- Float mode (default): most severe diagnostic at EOL + auto-show float
      local diag = diagnostics[1]
      local hl_group, icon = get_diagnostic_info(diag.severity, config.diagnostic_icons)
      local virt_text = {}
      if config.use_icons then
        virt_text = {
          { icon, hl_group },
          { " " .. diag.message, hl_group },
        }
      else
        virt_text = {
          { diag.message, hl_group },
        }
      end

      vim.api.nvim_buf_set_extmark(bufnr, ns_id, curline - 1, -1, {
        virt_text = virt_text,
        virt_text_pos = "eol",
      })

      -- Auto-show float if multiple diagnostics on this line
      if #diagnostics > 1 then
        if diagnostic_float.winid and vim.api.nvim_win_is_valid(diagnostic_float.winid) then
          float.close(diagnostic_float.winid)
        end
        diagnostic_float.winid = float.open(bufnr, config)
        if diagnostic_float.winid then
          diagnostic_float.line = curline
        end
      end
    end
  end

  -- Hide virtual text
  local function hide_virtual_text()
    vim.api.nvim_buf_clear_namespace(bufnr, ns_id, 0, -1)
    last_line = nil
  end

  -- Show diagnostic float
  local function show_diagnostic_float()
    hide_virtual_text()

    if diagnostic_float.winid and vim.api.nvim_win_is_valid(diagnostic_float.winid) then
      float.close(diagnostic_float.winid)
    end

    diagnostic_float.winid = float.open(bufnr, config)
    if diagnostic_float.winid then
      diagnostic_float.line = vim.api.nvim_win_get_cursor(0)[1]
    end
  end

  -- Hide diagnostic float and return to normal
  local function hide_diagnostic_float()
    if diagnostic_float.winid and vim.api.nvim_win_is_valid(diagnostic_float.winid) then
      float.close(diagnostic_float.winid)
      diagnostic_float.winid = nil
      diagnostic_float.line = nil
    end

    update_virtual_text()
  end

  -- Autocommands
  vim.api.nvim_create_autocmd({ "CursorMoved", "CursorMovedI" }, {
    buffer = bufnr,
    callback = function()
      -- Hide float if cursor moved to a different line
      if diagnostic_float.winid and vim.api.nvim_win_is_valid(diagnostic_float.winid) then
        local curline = vim.api.nvim_win_get_cursor(0)[1]
        if diagnostic_float.line and curline ~= diagnostic_float.line then
          hide_diagnostic_float()
        end
      end

      -- Only show virtual text if no float is currently shown
      if not (diagnostic_float.winid and vim.api.nvim_win_is_valid(diagnostic_float.winid)) then
        update_virtual_text()
      end
    end,
  })

  if config.hide_virtual_text_in_insert then
    vim.api.nvim_create_autocmd("InsertEnter", {
      buffer = bufnr,
      callback = function()
        hide_virtual_text()
        if diagnostic_float.winid and vim.api.nvim_win_is_valid(diagnostic_float.winid) then
          vim.api.nvim_win_close(diagnostic_float.winid, false)
          diagnostic_float.winid = nil
        end
      end,
    })
  end

  vim.api.nvim_create_autocmd("InsertLeave", {
    buffer = bufnr,
    callback = function()
      vim.defer_fn(update_virtual_text, 100)
    end,
  })

  vim.api.nvim_create_autocmd("BufLeave", {
    buffer = bufnr,
    callback = hide_virtual_text,
  })

  -- Keymaps
  if config.keymap.show_float then
    vim.keymap.set("n", config.keymap.show_float, function()
      show_diagnostic_float()
      vim.defer_fn(function()
        hide_diagnostic_float()
      end, config.auto_hide_delay)
    end, {
      buffer = bufnr,
      desc = "Show diagnostic hover",
    })
  end

  if config.keymap.hide_float then
    vim.keymap.set("n", config.keymap.hide_float, function()
      hide_diagnostic_float()
    end, {
      buffer = bufnr,
      desc = "Hide diagnostic hover",
    })
  end

  -- Initial call
  vim.defer_fn(update_virtual_text, 200)
end

return M
