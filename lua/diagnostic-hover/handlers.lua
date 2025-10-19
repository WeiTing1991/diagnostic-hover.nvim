-- lua/diagnostic-hover/handlers.lua

local M = {}

-- Setup diagnostic handlers to sort by severity
M.setup_sorting = function()
  local show_handler = vim.diagnostic.handlers.virtual_text.show

  vim.diagnostic.handlers.virtual_text = {
    show = function(ns, bufnr, diagnostics, handler_opts)
      table.sort(diagnostics, function(diag1, diag2)
        return diag1.severity < diag2.severity
      end)
      return show_handler(ns, bufnr, diagnostics, handler_opts)
    end,
  }
end

-- Configure global diagnostic settings
M.configure_diagnostics = function(config)
  vim.diagnostic.config({
    signs = {
      text = {
        [vim.diagnostic.severity.ERROR] = config.diagnostic_icons.Error,
        [vim.diagnostic.severity.WARN] = config.diagnostic_icons.Warn,
        [vim.diagnostic.severity.INFO] = config.diagnostic_icons.Info,
        [vim.diagnostic.severity.HINT] = config.diagnostic_icons.Hint,
      },
      texthl = {
        [vim.diagnostic.severity.ERROR] = "DiagnosticSignError",
        [vim.diagnostic.severity.WARN] = "DiagnosticSignWarn",
        [vim.diagnostic.severity.INFO] = "DiagnosticSignInfo",
        [vim.diagnostic.severity.HINT] = "DiagnosticSignHint",
      },
      numhl = {
        [vim.diagnostic.severity.ERROR] = "DiagnosticSignError",
        [vim.diagnostic.severity.WARN] = "DiagnosticSignWarn",
        [vim.diagnostic.severity.INFO] = "DiagnosticSignInfo",
        [vim.diagnostic.severity.HINT] = "DiagnosticSignHint",
      },
    },
    virtual_text = false,
    underline = config.underline,
    update_in_insert = config.update_in_insert,
    float = false,
  })
end

-- Setup custom highlight
M.setup_highlights = function()
  vim.api.nvim_set_hl(0, "DiagnosticUnderlineHint", {
    underline = false,
    underdotted = true,
    sp = "#61AFEF",
  })
end

return M
