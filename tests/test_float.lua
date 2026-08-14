local project_root = vim.fn.fnamemodify(debug.getinfo(1, "S").source:sub(2), ":h:h")
package.path = project_root .. "/lua/?.lua;" .. project_root .. "/lua/?/init.lua;" .. package.path

local h = dofile(project_root .. "/tests/helpers.lua")
local float = require("diagnostic-hover.float")
local config = require("diagnostic-hover.config")

-- Mock diagnostic severity constants
vim.diagnostic = vim.diagnostic or {}
vim.diagnostic.severity = vim.diagnostic.severity or {
	ERROR = 1,
	WARN = 2,
	INFO = 3,
	HINT = 4,
}

h.describe("float.format_diagnostics", function()
	h.it("formats a single diagnostic", function()
		local diagnostics = {
			{ severity = 1, message = "undefined variable", source = "pyright" },
		}
		local result = float.format_diagnostics(diagnostics, config.defaults)

		h.assert_true(#result.lines >= 1)
		h.assert_true(string.find(result.lines[1], "undefined variable") ~= nil)
		h.assert_true(#result.highlights > 0)
	end)

	h.it("formats multiple diagnostics with divider", function()
		local diagnostics = {
			{ severity = 1, message = "error msg", source = "pyright" },
			{ severity = 2, message = "warn msg", source = "eslint" },
		}
		local result = float.format_diagnostics(diagnostics, config.defaults)

		local has_divider = false
		for _, line in ipairs(result.lines) do
			if string.find(line, "─") then
				has_divider = true
			end
		end
		h.assert_true(has_divider)
	end)

	h.it("no divider for single diagnostic", function()
		local diagnostics = {
			{ severity = 1, message = "error msg", source = "pyright" },
		}
		local result = float.format_diagnostics(diagnostics, config.defaults)

		local has_divider = false
		for _, line in ipairs(result.lines) do
			if string.find(line, "─") then
				has_divider = true
			end
		end
		h.assert_true(not has_divider)
	end)

	h.it("shows source when config source is always", function()
		local cfg = vim.tbl_deep_extend("force", config.defaults, {
			float_opts = { source = "always" },
		})
		local diagnostics = {
			{ severity = 1, message = "error msg", source = "pyright" },
		}
		local result = float.format_diagnostics(diagnostics, cfg)

		local has_source = false
		for _, line in ipairs(result.lines) do
			if string.find(line, "pyright") then
				has_source = true
			end
		end
		h.assert_true(has_source)
	end)

	h.it("hides source when config source is if_many and only one source", function()
		local cfg = vim.tbl_deep_extend("force", config.defaults, {
			float_opts = { source = "if_many" },
		})
		local diagnostics = {
			{ severity = 1, message = "error msg", source = "pyright" },
			{ severity = 2, message = "warn msg", source = "pyright" },
		}
		local result = float.format_diagnostics(diagnostics, cfg)

		local has_source = false
		for _, line in ipairs(result.lines) do
			if string.find(line, "source:") then
				has_source = true
			end
		end
		h.assert_true(not has_source)
	end)

	h.it("shows source when config source is if_many and multiple sources", function()
		local cfg = vim.tbl_deep_extend("force", config.defaults, {
			float_opts = { source = "if_many" },
		})
		local diagnostics = {
			{ severity = 1, message = "error msg", source = "pyright" },
			{ severity = 2, message = "warn msg", source = "eslint" },
		}
		local result = float.format_diagnostics(diagnostics, cfg)

		local has_source = false
		for _, line in ipairs(result.lines) do
			if string.find(line, "source:") then
				has_source = true
			end
		end
		h.assert_true(has_source)
	end)

	h.it("respects use_icons = false", function()
		local cfg = vim.tbl_deep_extend("force", config.defaults, {
			use_icons = false,
		})
		local diagnostics = {
			{ severity = 1, message = "error msg", source = "pyright" },
		}
		local result = float.format_diagnostics(diagnostics, cfg)

		local first_line = result.lines[1]
		h.assert_true(string.find(first_line, "error msg") ~= nil)
		h.assert_true(string.find(first_line, config.defaults.diagnostic_icons.Error) == nil)
	end)

	h.it("highlights use correct severity groups", function()
		local diagnostics = {
			{ severity = 2, message = "warn msg", source = "eslint" },
		}
		local result = float.format_diagnostics(diagnostics, config.defaults)

		h.assert_eq(result.highlights[1].hl_group, "DiagnosticWarn")
	end)
end)

h.report()
