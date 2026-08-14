.PHONY: test lint

test:
	nvim --headless --noplugin -u NONE -l tests/test_config.lua

lint:
	stylua --check lua
