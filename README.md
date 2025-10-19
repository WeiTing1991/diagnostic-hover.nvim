# Diagnostic Hover

A powerful Neovim diagnostic plugin that shows diagnostic messages on the current line with smart virtual text and hover floats.

## Features

- 🎯 Show diagnostic virtual text only on the current line
- 🎈 Smart diagnostic float on keybind with auto-hide
- 🎨 Customizable icons and colors
- ⚡ Automatic sorting of diagnostics by severity
- 🔧 Highly configurable

## Installation

### lazy.nvim
```lua
{
	'WeiTing1991/diagnostic-hover.nvim',
	opts = {}
}
-- or 
{
	'WeiTing1991/diagnostic-hover.nvim',
	opts = {}
  config = function()
    require('diagnostic-hover').setup()
  end
}
```

### packer.nvim
```lua
use {
  'WeiTing1991/diagnostic-hover.nvim',
  config = function()
    require('diagnostic-hover').setup()
  end
}
```

## Configuration

Default configuration:
```lua
require('diagnostic-hover').setup({
  use_icons = true,
  diagnostic_icons = {
		Error = " ",
		Warn = " ",
		Info = " ",
		Hint = "󰠠 ",
	},
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
})
```

## Usage

- Move your cursor to any line with diagnostics to see virtual text
- Press `<A-k>` to show a detailed diagnostic float (auto-hides after 1.5s)
- Press `<Esc>` to manually hide the float

