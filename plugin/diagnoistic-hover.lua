-- plugin/diagnostic-hover.lua

-- Only load once
if vim.g.loaded_diagnostic_hover then
  return
end
vim.g.loaded_diagnostic_hover = 1

vim.api.nvim_create_autocmd("LspAttach", {
  group = vim.api.nvim_create_augroup("diagnostic-hover/auto-setup", { clear = true }),
  once = true,  -- Only run once
  callback = function()
    -- Check if setup was already called
    if not vim.g.diagnostic_hover_setup_called then
      require('diagnostic-hover').setup()
    end
  end,
})
