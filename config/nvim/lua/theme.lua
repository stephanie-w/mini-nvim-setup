-- ========================================================================== --
--                     THEME & UI HIGHLIGHTS MODULE                           --
-- ========================================================================== --

local M = {}

-- 1. APPLY CUSTOM UI HIGHLIGHT OVERRIDES
M.apply_highlights = function()
  -- Subtle full-line diff backgrounds
  vim.api.nvim_set_hl(0, "DiffAdd", { bg = "#1e3a2b" })
  vim.api.nvim_set_hl(0, "DiffDelete", { bg = "#3a1e26" })
  vim.api.nvim_set_hl(0, "DiffChange", { bg = "#1e2e3a" })
  vim.api.nvim_set_hl(0, "DiffText", { bg = "#3a321e" })

  vim.api.nvim_set_hl(0, "diffAdded", { bg = "#1e3a2b" })
  vim.api.nvim_set_hl(0, "diffRemoved", { bg = "#3a1e26" })
  vim.api.nvim_set_hl(0, "diffChanged", { bg = "#1e2e3a" })

  -- mini.diff inline overlays
  vim.api.nvim_set_hl(0, "MiniDiffOverAdd", { bg = "#1e3a2b" })
  vim.api.nvim_set_hl(0, "MiniDiffOverDelete", { bg = "#3a1e26" })
  vim.api.nvim_set_hl(0, "MiniDiffOverChange", { bg = "#1e2e3a" })

  -- Git Status Buffer Colors
  vim.api.nvim_set_hl(0, "GitStatusBranch", { fg = "#61afef", bold = true })
  vim.api.nvim_set_hl(0, "GitStatusHeaderStaged", { fg = "#98c379", bold = true })
  vim.api.nvim_set_hl(0, "GitStatusHeaderUnstaged", { fg = "#e5c07b", bold = true })
  vim.api.nvim_set_hl(0, "GitStatusHeaderUntracked", { fg = "#e06c75", bold = true })
  vim.api.nvim_set_hl(0, "GitStatusHeaderConflicted", { fg = "#fb4934", bold = true })
  vim.api.nvim_set_hl(0, "GitStatusStagedType", { fg = "#98c379", bold = true })
  vim.api.nvim_set_hl(0, "GitStatusStagedFile", { fg = "#73daca" })
  vim.api.nvim_set_hl(0, "GitStatusUnstagedType", { fg = "#e5c07b", bold = true })
  vim.api.nvim_set_hl(0, "GitStatusUnstagedFile", { fg = "#e5c07b" })
  vim.api.nvim_set_hl(0, "GitStatusUntrackedFile", { fg = "#e06c75" })
  vim.api.nvim_set_hl(0, "GitStatusConflictedFile", { fg = "#fb4934", bold = true })
end

-- 2. SETUP FUNCTION
---@param theme_name? string Optional theme name ('deep-teal', 'deepwater', 'nord', 'solarized-dark')
M.setup = function(theme_name)
  theme_name = theme_name or "deep-teal"

  -- Auto-reapply custom highlights whenever colorscheme changes
  vim.api.nvim_create_autocmd("ColorScheme", {
    group = vim.api.nvim_create_augroup("CustomThemeHighlights", { clear = true }),
    callback = function()
      M.apply_highlights()
    end,
  })

  -- Load the requested theme
  local ok, err = pcall(vim.cmd, "colorscheme " .. theme_name)
  if not ok then
    vim.notify("Could not load colorscheme " .. theme_name .. ": " .. tostring(err), vim.log.levels.WARN)
  end

  M.apply_highlights()
end

return M
