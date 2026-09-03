# Changelog

## [Unreleased]

## [0.2.0]

### Added

- Three display modes: `float` (default), `virt_lines`, `inline`
- `auto_show_float` config option (default off)
- Custom pretty float module with multi-diagnostic support

### Fixed

- Float mode no longer shows inline virtual text at EOL
- Float only shows on keybind, no auto-show
- Handle newlines in diagnostic messages for float
- Enable word wrap for long messages in float window
- Default `show_virtual_text_on_current_line` to `false`

## [0.1.0]

### Added

- Initial release
- Show diagnostic virtual text only on the current line
- Smart diagnostic float on keybind with auto-hide
- Configurable diagnostic icons
- Skip filetypes support
- Hide virtual text in insert mode
