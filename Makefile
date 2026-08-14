.PHONY: test lint

test:
	nvim --headless --noplugin -u NONE -l tests/test_config.lua
	nvim --headless --noplugin -u NONE -l tests/test_float.lua

lint:
	stylua --check lua
