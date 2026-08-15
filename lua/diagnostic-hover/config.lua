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
  virtual_text_mode = "float", -- "float", "virt_lines", or "inline"
  inline_separator = " | ",
  auto_show_float = false, -- auto-show float on cursor move
  keymap = {
    show_float = vim.fn.has("mac") == 1 and "<M-k>" or "<A-K>",
    hide_float = "<Esc>",
  },
  skip_filetypes = { "oil" },
}

M.options = {}

return M
