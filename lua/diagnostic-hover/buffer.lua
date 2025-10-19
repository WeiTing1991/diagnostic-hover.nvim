-- lua/diagnostic-hover/buffer.lua

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

    -- Show virtual text only for current line if it has diagnostics
    if #diagnostics > 0 then
      local diag = diagnostics[1]
      local hl_group, icon = get_diagnostic_info(diag.severity, config.diagnostic_icons)

      -- Build virtual text based on use_icons setting
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
    end
  end

  -- Hide virtual text
  local function hide_virtual_text()
    vim.api.nvim_buf_clear_namespace(bufnr, ns_id, 0, -1)
    last_line = nil
  end

  -- Show diagnostic float
  local function show_diagnostic_float()
    local curline = vim.api.nvim_win_get_cursor(0)[1]
    local diagnostics = vim.diagnostic.get(bufnr, { lnum = curline - 1 })

    if #diagnostics == 0 then
      return
    end

    hide_virtual_text()

    if diagnostic_float.winid and vim.api.nvim_win_is_valid(diagnostic_float.winid) then
      vim.api.nvim_win_close(diagnostic_float.winid, false)
    end

    diagnostic_float.winid = vim.diagnostic.open_float(bufnr, config.float_opts)
    diagnostic_float.line = curline
  end

  -- Hide diagnostic float and return to normal
  local function hide_diagnostic_float()
    if diagnostic_float.winid and vim.api.nvim_win_is_valid(diagnostic_float.winid) then
      vim.api.nvim_win_close(diagnostic_float.winid, false)
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
