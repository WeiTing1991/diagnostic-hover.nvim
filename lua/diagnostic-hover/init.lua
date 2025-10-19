-- lua/diagnostic-hover/init.lua

local M = {}

-- Import modules
local config_module = require("diagnostic-hover.config")
local handlers = require("diagnostic-hover.handlers")
local buffer = require("diagnostic-hover.buffer")

-- Setup function
M.setup = function(opts)
  -- Mark that setup was called
  vim.g.diagnostic_hover_setup_called = true

  -- Merge user config with defaults
  config_module.options = vim.tbl_deep_extend("force", config_module.defaults, opts or {})

  -- Setup diagnostic handlers
  handlers.setup_sorting()
  handlers.configure_diagnostics(config_module.options)
  handlers.setup_highlights()

  -- Setup autocmd for LSP attach
  vim.api.nvim_create_autocmd("LspAttach", {
    group = vim.api.nvim_create_augroup("diagnostic-hover/lsp-attach", { clear = true }),
    callback = function(args)
      buffer.setup(args.buf, config_module.options)
    end,
  })
end

return M
