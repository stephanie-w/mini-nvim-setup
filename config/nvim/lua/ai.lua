-- ========================================================================== --
--                     PI AGENT CODING ASSISTANT MODULE                       --
-- ========================================================================== --

local M = {}

local active_job_id = nil
local chat_win = nil
local chat_buf = nil

-- Return full environment with restored host XDG & Pi configuration paths
local function get_pi_env()
  local env = vim.fn.environ()
  local home = os.getenv("HOME") or vim.fn.expand("~")
  env["PI_CODING_AGENT_DIR"] = home .. "/.pi/agent"
  env["XDG_CONFIG_HOME"] = os.getenv("ORIG_XDG_CONFIG_HOME") or (home .. "/.config")
  env["XDG_DATA_HOME"] = os.getenv("ORIG_XDG_DATA_HOME") or (home .. "/.local/share")
  env["XDG_STATE_HOME"] = os.getenv("ORIG_XDG_STATE_HOME") or (home .. "/.local/state")
  env["XDG_CACHE_HOME"] = os.getenv("ORIG_XDG_CACHE_HOME") or (home .. "/.cache")
  env["NVIM"] = vim.v.servername
  return env
end

-- Global RPC helpers called by Pi extension (via v:lua.PiGetContext())
_G.PiGetContext = function()
  local target_win = vim.api.nvim_get_current_win()
  local target_buf = vim.api.nvim_get_current_buf()

  -- If focused on terminal/pichat, find the other non-terminal code window in the active tabpage
  if vim.bo[target_buf].buftype == "terminal" or vim.bo[target_buf].filetype == "pichat" then
    for _, win in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
      local b = vim.api.nvim_win_get_buf(win)
      if vim.bo[b].buftype ~= "terminal" and vim.bo[b].filetype ~= "pichat" and vim.api.nvim_buf_get_name(b) ~= "" then
        target_win = win
        target_buf = b
        break
      end
    end
  end

  local file_path = vim.api.nvim_buf_get_name(target_buf)
  local file_type = vim.bo[target_buf].filetype
  local is_modified = vim.bo[target_buf].modified
  local total_lines = (target_buf and vim.api.nvim_buf_is_valid(target_buf)) and vim.api.nvim_buf_line_count(target_buf) or 0
  local cursor = (target_win and vim.api.nvim_win_is_valid(target_win)) and vim.api.nvim_win_get_cursor(target_win) or { 1, 0 }

  -- Filter out terminal buffers from the open buffer list
  local bufs = {}
  for _, b in ipairs(vim.fn.getbufinfo({ buflisted = 1 })) do
    local bname = b.name or ""
    local btype = vim.bo[b.bufnr].buftype
    local bft = vim.bo[b.bufnr].filetype
    if bname ~= "" and not bname:match("^term://") and btype ~= "terminal" and bft ~= "pichat" then
      table.insert(bufs, {
        bufnr = b.bufnr,
        name = bname,
        modified = (b.modified == 1),
      })
    end
  end

  return vim.json.encode({
    active_file = file_path,
    relative_file = (file_path ~= "") and vim.fn.fnamemodify(file_path, ":~:.") or "",
    file_name = (file_path ~= "") and vim.fn.fnamemodify(file_path, ":t") or "",
    filetype = file_type,
    cursor_line = cursor[1],
    cursor_col = cursor[2] + 1,
    total_lines = total_lines,
    modified = is_modified,
    open_buffers = bufs,
  })
end

_G.PiGetBufferContent = function(target)
  local bufnr = nil
  if not target or target == "" or target == "%" then
    local cur_buf = vim.api.nvim_get_current_buf()
    if vim.bo[cur_buf].buftype == "terminal" or vim.bo[cur_buf].filetype == "pichat" then
      for _, win in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
        local b = vim.api.nvim_win_get_buf(win)
        if vim.bo[b].buftype ~= "terminal" and vim.bo[b].filetype ~= "pichat" and vim.api.nvim_buf_get_name(b) ~= "" then
          bufnr = b
          break
        end
      end
    end
    bufnr = bufnr or cur_buf
  else
    bufnr = target
  end

  local lines = vim.fn.getbufline(bufnr, 1, "$")
  return table.concat(lines, "\n")
end

-- Helper to display markdown output in a centered floating window
function M.show_floating_markdown(lines, title)
  local buf = vim.api.nvim_create_buf(false, true)
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
  vim.bo[buf].filetype = "markdown"
  vim.bo[buf].bufhidden = "wipe"

  local width = math.min(math.floor(vim.o.columns * 0.8), 100)
  local height = math.min(math.floor(vim.o.lines * 0.75), math.max(#lines + 2, 10))
  local row = math.floor((vim.o.lines - height) / 2)
  local col = math.floor((vim.o.columns - width) / 2)

  local win = vim.api.nvim_open_win(buf, true, {
    relative = "editor",
    width = width,
    height = height,
    row = row,
    col = col,
    style = "minimal",
    border = "rounded",
    title = title or " 💬 Pi Response ",
    title_pos = "center",
  })

  vim.keymap.set("n", "q", "<cmd>close<cr>", { buffer = buf, nowait = true, desc = "Close window" })
  vim.keymap.set("n", "<Esc>", "<cmd>close<cr>", { buffer = buf, nowait = true, desc = "Close window" })
end

-- Determine if a prompt is an informational question or an edit command
local function is_read_only_question(prompt)
  local lower = vim.trim(prompt:lower())
  if lower:match("^what") or lower:match("^why") or lower:match("^how")
      or lower:match("^explain") or lower:match("^review") or lower:match("^is there")
      or lower:match("%?$") then
    return true
  end
  return false
end

local nvim_system_prompt = "You are running as an interactive coding assistant alongside Neovim. Use the nvim_get_context and nvim_read_buffer tools whenever the user refers to 'this file', 'current file', or active editor context. Follow project conventions in AGENTS.md."

-- 1. PROMPT PI (Background Edit or Question, with Context)
function M.prompt_pi(is_visual)
  local file = vim.fn.expand("%:p")
  local start_line, end_line = nil, nil
  local selection_text = nil

  if is_visual then
    -- Exit visual mode to save '< and '> marks
    vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<ESC>", true, false, true), "x", true)
    local start_pos = vim.fn.getpos("'<")
    local end_pos = vim.fn.getpos("'>")
    start_line, end_line = start_pos[2], end_pos[2]
    local lines = vim.api.nvim_buf_get_lines(0, start_line - 1, end_line, false)
    selection_text = table.concat(lines, "\n")
  end

  vim.schedule(function()
    local prompt_title = is_visual
        and string.format("🤖 Pi (Lines %d-%d): ", start_line, end_line)
        or (file ~= "" and string.format("🤖 Pi (%s): ", vim.fn.expand("%:t")) or "🤖 Pi Prompt: ")

    vim.ui.input({ prompt = prompt_title }, function(input)
      if not input or vim.trim(input) == "" then
        return
      end

      local question = is_read_only_question(input)
      local filename = file ~= "" and vim.fn.expand("%:t") or "workspace"
      local stderr_lines = {}
      local stdout_lines = {}

      if question then
        -- READ-ONLY QUESTION: Output to floating markdown window
        local cmd = { "pi", "--bash-guard-auto-allow", "--append-system-prompt", nvim_system_prompt, "--tools", "read,grep,find,ls", "-p" }
        if file ~= "" then
          table.insert(cmd, "@" .. file)
        end
        if selection_text then
          table.insert(cmd, string.format("Regarding lines %d-%d:\n```\n%s\n```\n%s", start_line, end_line, selection_text, input))
        else
          table.insert(cmd, input)
        end

        vim.notify("Pi is thinking...", vim.log.levels.INFO, { title = "Pi Assistant", timeout = 2500 })

        active_job_id = vim.fn.jobstart(cmd, {
          stdout_buffered = true,
          stderr_buffered = true,
          env = get_pi_env(),
          on_stdout = function(_, data)
            if data then
              for _, line in ipairs(data) do
                table.insert(stdout_lines, line)
              end
            end
          end,
          on_stderr = function(_, data)
            if data then
              for _, line in ipairs(data) do
                if vim.trim(line) ~= "" then
                  table.insert(stderr_lines, line)
                end
              end
            end
          end,
          on_exit = function(_, code)
            active_job_id = nil
            while #stdout_lines > 0 and stdout_lines[#stdout_lines] == "" do
              table.remove(stdout_lines)
            end

            if code == 0 and #stdout_lines > 0 then
              vim.schedule(function()
                vim.cmd("echo ''")
                M.show_floating_markdown(stdout_lines, " 💬 " .. input .. " ")
              end)
            else
              local err_msg = #stderr_lines > 0 and table.concat(stderr_lines, "\n") or "Pi query returned no output"
              vim.notify("Pi query failed:\n" .. err_msg, vim.log.levels.ERROR, { title = "Pi Assistant" })
            end
          end,
        })

        if active_job_id > 0 then
          vim.fn.jobclose(active_job_id, "stdin")
        else
          vim.notify("Failed to spawn Pi process", vim.log.levels.ERROR, { title = "Pi Assistant" })
        end
      else
        -- EDIT COMMAND: Modify file on disk and auto-reload buffer
        local cmd = { "pi", "--bash-guard-auto-allow", "--append-system-prompt", nvim_system_prompt, "-p" }
        if file ~= "" then
          table.insert(cmd, "@" .. file)
        end
        if selection_text then
          table.insert(cmd, string.format("In %s, specifically modify lines %d-%d to: %s", file, start_line, end_line, input))
        else
          table.insert(cmd, input)
        end

        vim.notify(string.format("Pi is modifying %s...", filename), vim.log.levels.INFO, { title = "Pi Assistant", timeout = 3000 })

        active_job_id = vim.fn.jobstart(cmd, {
          stderr_buffered = true,
          env = get_pi_env(),
          on_stderr = function(_, data)
            if data then
              for _, line in ipairs(data) do
                if vim.trim(line) ~= "" then
                  table.insert(stderr_lines, line)
                end
              end
            end
          end,
          on_exit = function(_, code)
            active_job_id = nil
            if code == 0 then
              vim.schedule(function()
                vim.cmd("echo ''")
                vim.cmd("checktime") -- Reload buffer from disk to trigger mini.diff
                vim.notify(string.format("✨ Pi finished edits on %s", filename), vim.log.levels.INFO, { title = "Pi Assistant", timeout = 3000 })
              end)
            else
              local err_msg = #stderr_lines > 0 and table.concat(stderr_lines, "\n") or "Pi edit command failed"
              vim.notify("Pi edit failed:\n" .. err_msg, vim.log.levels.ERROR, { title = "Pi Assistant" })
            end
          end,
        })

        if active_job_id > 0 then
          vim.fn.jobclose(active_job_id, "stdin")
        else
          vim.notify("Failed to spawn Pi process", vim.log.levels.ERROR, { title = "Pi Assistant" })
        end
      end
    end)
  end)
end

-- 2. TOGGLEABLE PI CHAT PANEL (Persistent sidebar split)
function M.toggle_chat()
  -- If the chat window is currently visible, close/hide it
  if chat_win and vim.api.nvim_win_is_valid(chat_win) then
    vim.api.nvim_win_hide(chat_win)
    chat_win = nil
    return
  end

  -- If the chat buffer already exists and is alive, re-open it instantly (retains history)
  if chat_buf and vim.api.nvim_buf_is_valid(chat_buf) then
    vim.cmd("vsplit")
    chat_win = vim.api.nvim_get_current_win()
    vim.api.nvim_win_set_buf(chat_win, chat_buf)
    vim.api.nvim_win_set_width(chat_win, math.floor(vim.o.columns * 0.4))
    vim.cmd("startinsert")
    return
  end

  -- Otherwise, launch a fresh interactive Pi terminal session in project root
  local home = os.getenv("HOME") or vim.fn.expand("~")
  local orig_config = os.getenv("ORIG_XDG_CONFIG_HOME") or (home .. "/.config")
  local orig_data = os.getenv("ORIG_XDG_DATA_HOME") or (home .. "/.local/share")
  local orig_state = os.getenv("ORIG_XDG_STATE_HOME") or (home .. "/.local/state")
  local orig_cache = os.getenv("ORIG_XDG_CACHE_HOME") or (home .. "/.cache")

  local env_prefix = string.format(
    "env XDG_CONFIG_HOME=%s XDG_DATA_HOME=%s XDG_STATE_HOME=%s XDG_CACHE_HOME=%s PI_CODING_AGENT_DIR=%s/.pi/agent NVIM=%s ",
    vim.fn.shellescape(orig_config),
    vim.fn.shellescape(orig_data),
    vim.fn.shellescape(orig_state),
    vim.fn.shellescape(orig_cache),
    vim.fn.shellescape(home),
    vim.fn.shellescape(vim.v.servername)
  )

  -- Open clean 40% width vertical panel on right with appended Neovim system prompt
  local chat_cmd = env_prefix .. "pi --append-system-prompt " .. vim.fn.shellescape(nvim_system_prompt)
  vim.cmd("vsplit | terminal " .. chat_cmd)
  chat_win = vim.api.nvim_get_current_win()
  chat_buf = vim.api.nvim_get_current_buf()
  vim.api.nvim_win_set_width(chat_win, math.floor(vim.o.columns * 0.4))

  -- Set buffer properties
  vim.bo[chat_buf].filetype = "pichat"

  -- In Normal mode inside the Pi panel, pressing 'q' hides the panel
  vim.keymap.set("n", "q", function()
    M.toggle_chat()
  end, { buffer = chat_buf, nowait = true, desc = "Hide Pi Panel" })

  vim.cmd("startinsert")
end

-- 3. CANCEL / STOP RUNNING PI TASK
function M.stop_generation()
  if active_job_id then
    vim.fn.jobstop(active_job_id)
    active_job_id = nil
    vim.notify("Pi background task cancelled", vim.log.levels.WARN, { title = "Pi Assistant" })
  else
    vim.notify("No active Pi background task", vim.log.levels.INFO, { title = "Pi Assistant" })
  end
end

-- Keymaps (Reusing existing <leader>a namespace)
vim.keymap.set("n", "<leader>ap", function()
  M.prompt_pi(false)
end, { desc = "Prompt Pi (Edit or Ask on Active File)" })

vim.keymap.set("x", "<leader>ap", function()
  M.prompt_pi(true)
end, { desc = "Prompt Pi (Edit or Ask on Selection)" })

vim.keymap.set({ "n", "x" }, "<leader>at", function()
  M.toggle_chat()
end, { desc = "Toggle Interactive Pi Panel (Open / Hide)" })

vim.keymap.set("n", "<leader>as", function()
  M.stop_generation()
end, { desc = "Stop Active Pi Task" })

-- ========================================================================== --
-- 4. AGENTIC.NVIM FALLBACK INTEGRATION (:Agentic / <leader>aa)
-- ========================================================================== --

local has_profile, local_profile = pcall(require, "local_profile")
local active_profile = has_profile and local_profile or {}

local default_provider = "opencode"
if active_profile.profile == "work" then
  default_provider = active_profile.default_work_provider or "kiro"
elseif active_profile.profile == "home" then
  default_provider = active_profile.default_home_provider or "opencode"
end

local has_agentic, agentic = pcall(require, "agentic")
if has_agentic then
  local original_env = {
    XDG_CONFIG_HOME = os.getenv("ORIG_XDG_CONFIG_HOME") or (os.getenv("HOME") .. "/.config"),
    XDG_DATA_HOME = os.getenv("ORIG_XDG_DATA_HOME") or (os.getenv("HOME") .. "/.local/share"),
    XDG_STATE_HOME = os.getenv("ORIG_XDG_STATE_HOME") or (os.getenv("HOME") .. "/.local/state"),
    XDG_CACHE_HOME = os.getenv("ORIG_XDG_CACHE_HOME") or (os.getenv("HOME") .. "/.cache"),
  }

  agentic.setup({
    provider = default_provider,
    acp_providers = {
      ["opencode"] = {
        name = "DeepSeek (OpenCode)",
        command = "opencode",
        args = { "acp" },
        env = original_env,
        initial_model = "deepseek/deepseek-v4-pro",
        default_mode = "plan",
      },
      ["kiro"] = {
        name = "Kiro Agent",
        command = "kiro-cli",
        args = { "acp" },
        env = original_env,
        initial_model = "claude-sonnet-4.5",
        default_mode = "plan",
      },
      ["gemini"] = {
        name = "Gemini Agent",
        command = "gemini",
        args = { "--acp" },
        env = original_env,
        initial_model = "gemini-2.5-pro",
        default_mode = "plan",
      },
    },
  })

  -- User commands to open agentic.nvim anytime
  vim.api.nvim_create_user_command("Agentic", function()
    agentic.toggle()
  end, { desc = "Toggle agentic.nvim sidebar" })

  vim.api.nvim_create_user_command("AgenticToggle", function()
    agentic.toggle()
  end, { desc = "Toggle agentic.nvim sidebar" })

  -- Fallback shortcut: <leader>aa ("Assistant Agentic")
  vim.keymap.set({ "n", "v", "x" }, "<leader>aa", function()
    agentic.toggle()
  end, { desc = "Toggle agentic.nvim Sidebar (Fallback)" })

  -- Protect Agentic buffers from mini.completion conflicts
  vim.api.nvim_create_autocmd({ "FileType", "BufWinEnter", "BufEnter" }, {
    pattern = "Agentic*",
    callback = function(args)
      local bufnr = args.buf
      if vim.api.nvim_buf_is_valid(bufnr) then
        vim.b[bufnr].minicompletion_disable = true
        vim.keymap.set("n", "<C-c>", function()
          agentic.stop_generation()
        end, { buffer = bufnr, desc = "Stop Agent Generation" })
        local ft = vim.bo[bufnr].filetype
        local bufname = vim.api.nvim_buf_get_name(bufnr)
        if ft == "AgenticInput" or bufname:match("Input") then
          pcall(function()
            vim.bo[bufnr].completefunc = "v:lua.require'agentic.acp.slash_commands'.complete_func"
            vim.bo[bufnr].omnifunc = "v:lua.require'agentic.ui.file_picker'.complete_func"
          end)
        end
        vim.schedule(function()
          if vim.api.nvim_buf_is_valid(bufnr) then
            vim.bo[bufnr].syntax = "markdown"
          end
        end)
      end
    end,
  })
end

return M
