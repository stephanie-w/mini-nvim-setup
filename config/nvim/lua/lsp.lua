-- ========================================================================== --
--                     NATIVE LSP & DIAGNOSTICS MODULE                        --
-- ========================================================================== --

-- 1. ENABLE NATIVE LSP SERVERS (Ruff & ty)
vim.lsp.enable("ruff")
vim.lsp.enable("ty")

-- 2. DIAGNOSTICS DISPLAY CONFIGURATION
vim.diagnostic.config({
  virtual_text = {
    source = "always", -- Show "ruff" / "ty" source labels on messages
  },
  signs = true,
  underline = true,
  update_in_insert = true, -- Update diagnostic messages live while typing
  severity_sort = true,
})

-- 3. FORMAT ON SAVE (Python / Ruff)
vim.api.nvim_create_autocmd("BufWritePre", {
  pattern = "*.py",
  callback = function()
    vim.lsp.buf.format({ async = false })
  end,
})

-- 4. LSP NAVIGATION & CODE ACTIONS
vim.keymap.set("n", "gd", vim.lsp.buf.definition, { desc = "Go to Definition" })
vim.keymap.set("n", "K", vim.lsp.buf.hover, { desc = "Show Code Documentation" })
vim.keymap.set({ "i", "n" }, "<C-k>", vim.lsp.buf.signature_help, { desc = "Show Signature / Function Arguments" })
vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename, { desc = "Smart Rename" })
vim.keymap.set("n", "<leader>ca", vim.lsp.buf.code_action, { desc = "LSP Code Actions" })

-- Diagnostic Navigation Keymaps
vim.keymap.set("n", "]d", function()
  vim.diagnostic.jump({ count = 1, float = true })
end, { desc = "Next Diagnostic" })

vim.keymap.set("n", "[d", function()
  vim.diagnostic.jump({ count = -1, float = true })
end, { desc = "Previous Diagnostic" })

vim.keymap.set("n", "<leader>d", vim.diagnostic.open_float, { desc = "Show Line Diagnostic Details" })

-- 5. OPTIONAL TREESITTER SYNTAX HIGHLIGHTING
vim.api.nvim_create_autocmd("FileType", {
  pattern = "python",
  callback = function()
    pcall(vim.treesitter.start)
  end,
})
