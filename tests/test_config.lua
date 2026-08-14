local project_root = vim.fn.fnamemodify(debug.getinfo(1, "S").source:sub(2), ":h:h")
package.path = project_root .. "/lua/?.lua;" .. project_root .. "/lua/?/init.lua;" .. package.path

local h = dofile(project_root .. "/tests/helpers.lua")
local config = require("diagnostic-hover.config")

h.describe("config defaults", function()
	h.it("has virtual_text_mode default", function()
		h.assert_eq(config.defaults.virtual_text_mode, "stacked")
	end)

	h.it("has inline_separator default", function()
		h.assert_eq(config.defaults.inline_separator, " | ")
	end)

	h.it("has use_icons default", function()
		h.assert_eq(config.defaults.use_icons, true)
	end)

	h.it("has diagnostic_icons", function()
		h.assert_true(config.defaults.diagnostic_icons.Error ~= nil)
		h.assert_true(config.defaults.diagnostic_icons.Warn ~= nil)
		h.assert_true(config.defaults.diagnostic_icons.Info ~= nil)
		h.assert_true(config.defaults.diagnostic_icons.Hint ~= nil)
	end)

	h.it("has float_opts defaults", function()
		h.assert_eq(config.defaults.float_opts.border, "single")
		h.assert_eq(config.defaults.float_opts.max_width, 50)
		h.assert_eq(config.defaults.float_opts.wrap, true)
	end)

	h.it("has auto_hide_delay default", function()
		h.assert_eq(config.defaults.auto_hide_delay, 1500)
	end)
end)

h.describe("config merge", function()
	h.it("merges user config with defaults", function()
		local merged = vim.tbl_deep_extend("force", config.defaults, {
			virtual_text_mode = "inline",
			auto_hide_delay = 3000,
		})
		h.assert_eq(merged.virtual_text_mode, "inline")
		h.assert_eq(merged.auto_hide_delay, 3000)
		h.assert_eq(merged.use_icons, true)
		h.assert_eq(merged.inline_separator, " | ")
	end)
end)

h.report()
