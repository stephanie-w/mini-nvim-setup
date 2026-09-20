-- ========================================================================== --
--                     GIT WORKFLOW & HISTORY PANEL MODULE                    --
-- ========================================================================== --

-- 1. MINI.DIFF & MINI.GIT SETUP
require("mini.diff").setup({
  view = {
    style = "sign",
    signs = { add = "┃", change = "┃", delete = "━" },
  },
  options = {
    wrap_goto = true, -- Cycle between first and last hunks with notification
  },
})
require("mini.git").setup()

-- 3. GIT NAVIGATION & DIFF KEYMAPS
vim.keymap.set("n", "]h", function()
  require("mini.diff").goto_hunk("next")
end, { desc = "Next Git hunk (cycles)" })

vim.keymap.set("n", "[h", function()
  require("mini.diff").goto_hunk("prev")
end, { desc = "Previous Git hunk (cycles)" })

vim.keymap.set("n", "<leader>td", function()
  require("mini.diff").toggle_overlay()
end, { desc = "Toggle MiniDiff Overlay" })

-- Stage Hunk or Visual Selection (<leader>ga)
vim.keymap.set("n", "<leader>ga", function()
  local line = vim.fn.line(".")
  require("mini.diff").do_hunks(0, "apply", { line_start = line, line_end = line })
end, { desc = "Stage hunk at cursor (Git Add)" })

vim.keymap.set("x", "<leader>ga", function()
  local line_start = vim.fn.line("v")
  local line_end = vim.fn.line(".")
  if line_start > line_end then
    line_start, line_end = line_end, line_start
  end
  require("mini.diff").do_hunks(0, "apply", { line_start = line_start, line_end = line_end })
  vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<Esc>", true, false, true), "n", false)
end, { desc = "Stage selected lines (Git Add)" })

-- Discard Hunk or Visual Selection (<leader>gX)
vim.keymap.set("n", "<leader>gX", function()
  local line = vim.fn.line(".")
  require("mini.diff").do_hunks(0, "reset", { line_start = line, line_end = line })
end, { desc = "Discard hunk at cursor" })

vim.keymap.set("x", "<leader>gX", function()
  local line_start = vim.fn.line("v")
  local line_end = vim.fn.line(".")
  if line_start > line_end then
    line_start, line_end = line_end, line_start
  end
  require("mini.diff").do_hunks(0, "reset", { line_start = line_start, line_end = line_end })
  vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<Esc>", true, false, true), "n", false)
end, { desc = "Discard selected lines" })

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

-- Open Commit, Stash, or Working Tree Diff with Delta in Terminal Tab
vim.keymap.set("n", "<leader>gd", function()
  local line = vim.api.nvim_get_current_line()
  local stash = line:match("(stash@{%d+})")
  if stash then
    vim.cmd("tabnew | terminal git stash show -p " .. vim.fn.fnameescape(stash) .. " | delta --paging=always")
    vim.cmd("startinsert")
    return
  end
  local commit = line:match("^[*|%s\\/]*([%a%d]+)")
  if (vim.bo.filetype == "git" or vim.bo.filetype == "diff") and commit and #commit >= 7 then
    vim.cmd("tabnew | terminal git show " .. vim.fn.fnameescape(commit) .. " | delta --paging=always")
  elseif commit and #commit >= 7 and line:match("^[*|%s\\/]*%x%x%x%x%x%x%x") then
    vim.cmd("tabnew | terminal git show " .. vim.fn.fnameescape(commit) .. " | delta --paging=always")
  else
    vim.cmd("tabnew | terminal git diff HEAD | delta --paging=always")
  end
  vim.cmd("startinsert")
end, { desc = "Show Commit, Stash, or Working Tree with Delta in Terminal Tab" })

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
    local lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)

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

    -- In Git status buffers: apply rich color highlights and interactive keymaps
    if subcommand == "status" then
      vim.bo[bufnr].filetype = "git"
      local ns = vim.api.nvim_create_namespace("git_status_colors")
      vim.api.nvim_buf_clear_namespace(bufnr, ns, 0, -1)
      local current_section = nil

      for lnum, line in ipairs(lines) do
        local idx = lnum - 1
        if line:match("^On branch ") then
          local _, b_end = line:find("^On branch ")
          vim.api.nvim_buf_set_extmark(bufnr, ns, idx, 0, { end_col = b_end, hl_group = "Comment" })
          vim.api.nvim_buf_set_extmark(bufnr, ns, idx, b_end, { end_col = #line, hl_group = "GitStatusBranch" })
        elseif line:match("^Your branch") then
          vim.api.nvim_buf_set_extmark(bufnr, ns, idx, 0, { end_col = #line, hl_group = "Comment" })
        elseif line:match("^Changes to be committed:") then
          current_section = "staged"
          vim.api.nvim_buf_set_extmark(bufnr, ns, idx, 0, { end_col = #line, hl_group = "GitStatusHeaderStaged" })
        elseif line:match("^Changes not staged for commit:") then
          current_section = "unstaged"
          vim.api.nvim_buf_set_extmark(bufnr, ns, idx, 0, { end_col = #line, hl_group = "GitStatusHeaderUnstaged" })
        elseif line:match("^Untracked files:") then
          current_section = "untracked"
          vim.api.nvim_buf_set_extmark(bufnr, ns, idx, 0, { end_col = #line, hl_group = "GitStatusHeaderUntracked" })
        elseif line:match("^Unmerged paths:") then
          current_section = "conflicted"
          vim.api.nvim_buf_set_extmark(bufnr, ns, idx, 0, { end_col = #line, hl_group = "GitStatusHeaderConflicted" })
        elseif line:match("^%s*%(") then
          vim.api.nvim_buf_set_extmark(bufnr, ns, idx, 0, { end_col = #line, hl_group = "Comment" })
        elseif line:match("^\t") and current_section then
          if current_section == "staged" then
            local colon = line:find(":")
            if colon then
              vim.api.nvim_buf_set_extmark(bufnr, ns, idx, 1, { end_col = colon, hl_group = "GitStatusStagedType" })
              vim.api.nvim_buf_set_extmark(bufnr, ns, idx, colon, { end_col = #line, hl_group = "GitStatusStagedFile" })
            else
              vim.api.nvim_buf_set_extmark(bufnr, ns, idx, 1, { end_col = #line, hl_group = "GitStatusStagedFile" })
            end
          elseif current_section == "unstaged" then
            local colon = line:find(":")
            if colon then
              vim.api.nvim_buf_set_extmark(bufnr, ns, idx, 1, { end_col = colon, hl_group = "GitStatusUnstagedType" })
              vim.api.nvim_buf_set_extmark(bufnr, ns, idx, colon, { end_col = #line, hl_group = "GitStatusUnstagedFile" })
            else
              vim.api.nvim_buf_set_extmark(bufnr, ns, idx, 1, { end_col = #line, hl_group = "GitStatusUnstagedFile" })
            end
          elseif current_section == "untracked" then
            vim.api.nvim_buf_set_extmark(bufnr, ns, idx, 1, { end_col = #line, hl_group = "GitStatusUntrackedFile" })
          elseif current_section == "conflicted" then
            vim.api.nvim_buf_set_extmark(bufnr, ns, idx, 1, { end_col = #line, hl_group = "GitStatusConflictedFile" })
          end
        end
      end

      -- Interactive file opening on <CR>
      vim.keymap.set("n", "<CR>", function()
        local line = vim.api.nvim_get_current_line()
        local file = line:match("^\t[%a%s]+:%s+(.-)$") or line:match("^\t(.-)$")
        if file and #file > 0 then
          file = file:gsub("%s+$", "")
          vim.cmd("edit " .. vim.fn.fnameescape(file))
        end
      end, { buffer = bufnr, desc = "Open file from Git status" })

      -- Close with 'q' or <BS>
      vim.keymap.set("n", "q", "<cmd>bdelete!<cr>", { buffer = bufnr, desc = "Close Git Status" })
      vim.keymap.set("n", "<BS>", "<cmd>bdelete!<cr>", { buffer = bufnr, desc = "Close Git Status" })
    end
  end,
})
