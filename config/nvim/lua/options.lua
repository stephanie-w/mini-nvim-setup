-- ========================================================================== --
--                     GLOBAL OPTIONS & ENVIRONMENT                           --
-- ========================================================================== --

local M = {}

vim.g.mapleader = " " -- Use Spacebar as global Leader key
vim.g.maplocalleader = "\\" -- Use Backslash (\) as LocalLeader key
vim.opt.number = true -- Show line numbers
vim.opt.relativenumber = true -- Relative line numbers for easy jumping
vim.opt.shiftwidth = 4 -- Default indent width (Python standard)
vim.opt.tabstop = 4 -- Number of spaces tabs count for
vim.opt.expandtab = true -- Turn tabs into spaces
vim.opt.splitright = true -- Force vertical splits to open on the right
vim.opt.termguicolors = true -- Enable 24-bit True Color support
vim.opt.swapfile = false

-- Filetype indentation overrides (Lua standard: 2 spaces)
vim.api.nvim_create_autocmd("FileType", {
  pattern = "lua",
  callback = function()
    vim.bo.shiftwidth = 2
    vim.bo.tabstop = 2
    vim.bo.softtabstop = 2
    vim.bo.expandtab = true
  end,
})

-- Automatically point Python LSP to local .venv if it exists (uv project aware)
if vim.fn.isdirectory(".venv") == 1 then
  vim.env.VIRTUAL_ENV = vim.fn.getcwd() .. "/.venv"
  vim.env.PATH = vim.env.VIRTUAL_ENV .. "/bin:" .. vim.env.PATH
end

return M
