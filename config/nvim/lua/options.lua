-- ~/.config/nvim/lua/options.lua

local M = {}

vim.g.mapleader = " " -- Use the Spacebar as your Leader key
vim.opt.number = true -- Show line numbers
vim.opt.relativenumber = true -- Relative line numbers for easy jumping
vim.opt.shiftwidth = 4 -- Size of an indent (Python standard)
vim.opt.tabstop = 4 -- Number of spaces tabs count for
vim.opt.expandtab = true -- Turn tabs into spaces
vim.opt.splitright = true -- Force vertical splits to open on the right
vim.opt.termguicolors = true -- Enable 24-bit True Color support

-- Automatically point Python LSP to local .venv if it exists (uv project aware)
if vim.fn.isdirectory(".venv") == 1 then
	vim.env.VIRTUAL_ENV = vim.fn.getcwd() .. "/.venv"
	vim.env.PATH = vim.env.VIRTUAL_ENV .. "/bin:" .. vim.env.PATH
end

return M
