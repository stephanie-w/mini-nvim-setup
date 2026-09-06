-- ========================================================================== --
--                     GIT WORKFLOW & HISTORY PANEL MODULE                    --
-- ========================================================================== --

-- 1. SUBTLE FULL-LINE DIFF BACKGROUND TINTS
local set_diff_highlights = function()
  vim.api.nvim_set_hl(0, "DiffAdd", { bg = "#1e3a2b" })
  vim.api.nvim_set_hl(0, "DiffDelete", { bg = "#3a1e26" })
  vim.api.nvim_set_hl(0, "DiffChange", { bg = "#1e2e3a" })
  vim.api.nvim_set_hl(0, "DiffText", { bg = "#3a321e" })

  vim.api.nvim_set_hl(0, "diffAdded", { bg = "#1e3a2b" })
  vim.api.nvim_set_hl(0, "diffRemoved", { bg = "#3a1e26" })
  vim.api.nvim_set_hl(0, "diffChanged", { bg = "#1e2e3a" })

  vim.api.nvim_set_hl(0, "MiniDiffOverAdd", { bg = "#1e3a2b" })
  vim.api.nvim_set_hl(0, "MiniDiffOverDelete", { bg = "#3a1e26" })
  vim.api.nvim_set_hl(0, "MiniDiffOverChange", { bg = "#1e2e3a" })
end

set_diff_highlights()

vim.api.nvim_create_autocmd("ColorScheme", {
  callback = set_diff_highlights,
})

-- 2. MINI.DIFF & MINI.GIT SETUP
require("mini.diff").setup({
  view = {
    style = "sign",
    signs = { add = "┃", change = "┃", delete = "━" },
  },
})
require("mini.git").setup()

-- 3. GIT NAVIGATION & DIFF KEYMAPS
vim.keymap.set("n", "]h", function()
  require("mini.diff").goto_hunk("next")
end, { desc = "Next Git hunk" })

vim.keymap.set("n", "[h", function()
  require("mini.diff").goto_hunk("prev")
end, { desc = "Previous Git hunk" })

vim.keymap.set("n", "<leader>td", function()
  require("mini.diff").toggle_overlay()
end, { desc = "Toggle MiniDiff Overlay" })

-- Git Tab Layouts
vim.keymap.set("n", "<leader>gl", "<cmd>tab Git log --oneline<cr>", { desc = "Git Log (Dedicated Tab)" })
vim.keymap.set("n", "<leader>gL", "<cmd>tab Git log --graph --oneline --decorate --all<cr>", { desc = "Git Log Graph (All Branches)" })
vim.keymap.set("n", "<leader>gf", "<cmd>tab Git log --oneline -- %<cr>", { desc = "Git Log for Current File" })
vim.keymap.set("n", "<leader>gs", "<cmd>tab Git status<cr>", { desc = "Git Status (Dedicated Tab)" })
vim.keymap.set("n", "<leader>gS", "<cmd>tab Git stash list<cr>", { desc = "Git Stash List (Dedicated Tab)" })
vim.keymap.set("n", "<leader>gb", function()
  MiniExtra.pickers.git_branches()
end, { desc = "Pick & Switch Git Branch" })

-- Open Commit Diff on the Right Panel
vim.keymap.set("n", "<leader>gc", function()
  vim.cmd("vertical lua require('mini.git').show_at_cursor()")
end, { desc = "Inspect commit in right panel" })

-- Open Commit Diff with Delta in Terminal Tab
vim.keymap.set("n", "<leader>gd", function()
  local line = vim.api.nvim_get_current_line()
  local stash = line:match("(stash@{%d+})")
  if stash then
    vim.cmd("tabnew | terminal git stash show -p " .. vim.fn.fnameescape(stash) .. " | delta --paging=always")
    vim.cmd("startinsert")
    return
  end
  local commit = line:match("^[*|%s\\/]*([%a%d]+)")
  if not commit or #commit < 7 then
    commit = "HEAD"
  end
  vim.cmd("tabnew | terminal git show " .. vim.fn.fnameescape(commit) .. " | delta --paging=always")
  vim.cmd("startinsert")
end, { desc = "Show Commit or Stash with Delta in Terminal Tab" })

-- GitHub CLI (gh) PR Integration
vim.keymap.set("n", "<leader>gpr", "<cmd>tabnew | terminal gh pr list<cr>i", { desc = "List GitHub PRs" })
vim.keymap.set("n", "<leader>gpc", "<cmd>tabnew | terminal gh pr checkout<cr>i", { desc = "Interactive GH PR Checkout" })
vim.keymap.set("n", "<leader>gpd", "<cmd>tabnew | terminal gh pr diff | delta --paging=always<cr>i", { desc = "Show GH PR Diff with Delta" })
vim.keymap.set("n", "<leader>gpv", "<cmd>tabnew | terminal gh pr view<cr>i", { desc = "View GH PR Overview" })

-- Auto-close terminal buffers cleanly on exit
vim.api.nvim_create_autocmd("TermClose", {
  pattern = "*",
  callback = function(args)
    if vim.v.event.status == 0 then
      vim.schedule(function()
        if vim.api.nvim_buf_is_valid(args.buf) then
          vim.api.nvim_buf_delete(args.buf, { force = true })
        end
      end)
    end
  end,
})

-- Git Line History (Normal and Visual modes)
vim.keymap.set({ "n", "x" }, "<leader>gh", "<cmd>lua MiniGit.show_range_history()<cr>", { desc = "Git Range History" })

-- 4. BUFFER HANDLING FOR RAW GIT LOG & STASH STREAMS
vim.api.nvim_create_autocmd("User", {
  pattern = "MiniGitCommandSplit",
  callback = function(args)
    local win_id = args.data.win_stdout
    local bufnr = vim.api.nvim_win_get_buf(win_id)
    local subcommand = args.data.git_subcommand
    local lines = vim.api.nvim_buf_get_lines(bufnr, 0, 1, false)

    if #lines > 0 then
      if lines[1]:match("^commit") or lines[1]:match("^diff %-%-git") then
        vim.bo[bufnr].filetype = "diff"
      elseif lines[1]:match("^%*?%s*%x%x%x%x%x%x%x") or lines[1]:match("^stash@{%d+}") or subcommand == "log" or subcommand == "stash" then
        vim.bo[bufnr].filetype = "git"
      end
    end

    -- In Git log buffers: pressing <CR> opens commit diff in current window
    if subcommand == "log" then
      vim.keymap.set("n", "<CR>", function()
        local line = vim.api.nvim_get_current_line()
        local commit = line:match("^[*|%s\\/]*([%a%d]+)")
        if commit and #commit >= 7 then
          vim.cmd("Git show " .. commit)
        end
      end, { buffer = bufnr, desc = "Show commit in current window" })
    end

    -- In Git stash list buffers: pressing <CR> opens stash diff in current window
    if subcommand == "stash" and #lines > 0 and lines[1]:match("^stash@{%d+}") then
      vim.keymap.set("n", "<CR>", function()
        local line = vim.api.nvim_get_current_line()
        local stash_ref = line:match("(stash@{%d+})")
        if stash_ref then
          vim.cmd("Git stash show -p " .. stash_ref)
        end
      end, { buffer = bufnr, desc = "Show stash diff in current window" })
    end

    -- In Git show / stash diff buffers: pressing 'q' or <BS> deletes diff buffer
    if subcommand == "show" or (subcommand == "stash" and #lines > 0 and lines[1]:match("^diff %-%-git")) or vim.bo[bufnr].filetype == "diff" then
      vim.keymap.set("n", "q", "<cmd>bdelete!<cr>", { buffer = bufnr, desc = "Close Diff" })
      vim.keymap.set("n", "<BS>", "<cmd>bdelete!<cr>", { buffer = bufnr, desc = "Close Diff" })
    end
  end,
})
