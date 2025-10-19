-- lua/diagnostic-hover/config.lua

local M = {}

local diagnostic_icons = {
  Error = " ",
  Warn = " ",
  Info = " ",
  Hint = "󰠠 ",
}

-- Default configuration
M.defaults = {
  use_icons = true,
  diagnostic_icons = diagnostic_icons,
  float_opts = {
    focus = false,
    scope = "line",
    border = "single",
    style = "minimal",
    header = "",
    prefix = "󱓻 ",
    source = "if_many",
    wrap = true,
    max_width = 50,
  },
  auto_hide_delay = 1500, -- milliseconds
  show_virtual_text_on_current_line = true,
  hide_virtual_text_in_insert = true,
  update_in_insert = true,
  underline = true,
  keymap = {
    show_float = "<A-k>"
    hide_float = "<Esc>",
  },
  skip_filetypes = { "oil" },
}

-- Current configuration (will be merged with user config)
M.options = {}

return M
