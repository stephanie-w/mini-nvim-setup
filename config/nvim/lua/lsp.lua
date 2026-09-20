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

-- 4. LSP FLOATING PREVIEWS (Hover & Signature Help with easy dismissal)
local make_dismissable_handler = function(orig_handler, desc_label)
  return function(err, result, ctx, config)
    config = vim.tbl_extend("force", { border = "single" }, config or {})
    local fbuf, fwin = orig_handler(err, result, ctx, config)
    if fbuf and fwin and vim.api.nvim_win_is_valid(fwin) then
      vim.b[fbuf].is_lsp_preview = true
      vim.keymap.set("n", "q", function()
        if vim.api.nvim_win_is_valid(fwin) then
          vim.api.nvim_win_close(fwin, true)
        end
      end, { buffer = fbuf, desc = "Close " .. desc_label })

      vim.keymap.set("n", "<Esc>", function()
        if vim.api.nvim_win_is_valid(fwin) then
          vim.api.nvim_win_close(fwin, true)
        end
      end, { buffer = fbuf, desc = "Close " .. desc_label })
    end
    return fbuf, fwin
  end
end

vim.lsp.handlers["textDocument/hover"] = make_dismissable_handler(vim.lsp.handlers.hover, "Hover Popup")
vim.lsp.handlers["textDocument/signatureHelp"] = make_dismissable_handler(vim.lsp.handlers.signature_help, "Signature Popup")

-- Helper to close all floating preview windows in current tab
local close_floating_previews = function()
  local closed = false
  for _, win in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
    local cfg = vim.api.nvim_win_get_config(win)
    if cfg.relative and cfg.relative ~= "" then
      local buf = vim.api.nvim_win_get_buf(win)
      if vim.b[buf].is_lsp_preview or vim.bo[buf].buftype == "nofile" or vim.bo[buf].filetype == "markdown" then
        pcall(vim.api.nvim_win_close, win, true)
        closed = true
      end
    end
  end
  return closed
end

-- 5. LSP NAVIGATION & CODE ACTIONS
vim.keymap.set("n", "gd", vim.lsp.buf.definition, { desc = "Go to Definition" })

-- Toggle Hover: press K to open, press K again (or <Esc>) to dismiss
vim.keymap.set("n", "K", function()
  local current_win = vim.api.nvim_get_current_win()
  local current_cfg = vim.api.nvim_win_get_config(current_win)
  if current_cfg.relative and current_cfg.relative ~= "" then
    vim.api.nvim_win_close(current_win, true)
    return
  end

  if close_floating_previews() then
    return
  end

  vim.lsp.buf.hover()
end, { desc = "Toggle Code Documentation Hover" })

-- Esc in Normal mode closes any open floating popups and clears search highlight
vim.keymap.set("n", "<Esc>", function()
  close_floating_previews()
  vim.cmd("nohlsearch")
end, { desc = "Dismiss popups & clear highlights" })

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

-- 6. OPTIONAL TREESITTER SYNTAX HIGHLIGHTING
vim.api.nvim_create_autocmd("FileType", {
  pattern = "python",
  callback = function()
    pcall(vim.treesitter.start)
  end,
})
