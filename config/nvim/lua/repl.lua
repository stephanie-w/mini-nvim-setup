-- ========================================================================== --
--                     INTERACTIVE PYTHON REPL MODULE                         --
-- ========================================================================== --
--
-- Sends the current line (normal mode) or the visual selection to an
-- ipython REPL running in a terminal buffer.
--
-- Known limitation: a visual selection must be valid Python on its own.
-- Selecting the body of a function without its `def` line will fail with
-- "SyntaxError: 'return' outside function". Select the whole `def`, or a
-- single line. This is a property of Python, not of this module.

local M = {}

-- Private defaults. Reachable only from inside this file, overridable via setup().
-- --no-autoindent is required: with autoindent on (the default), ipython
-- reprocesses multi-line input meant for a human typing and silently drops
-- blocks sent as a single write, producing an empty cell and NameError.
local config = {
  command = "uvx ipython --no-autoindent",
  keymap = "<leader>rr",
}

-- Return the channel id of a live REPL terminal, or nil if none is open.
-- Uses vim.b instead of nvim_buf_get_var because the latter throws
-- "Key not found" on buffers that are not terminals, which would abort
-- send_text before it could open a new terminal.
-- Stale buffers are prevented by the TermClose handler in setup().
local function find_channel()
  for _, buf in ipairs(vim.api.nvim_list_bufs()) do
    local chan = vim.b[buf].terminal_job_id
    if chan then
      return chan
    end
  end
  return nil
end

-- Send text to the REPL, opening one first if needed.
local function send_text(text)
  local chan = find_channel()
  if not chan then
    vim.cmd("vsplit | terminal " .. config.command)
    chan = find_channel()
  end

  if chan then
    vim.api.nvim_chan_send(chan, text)
  end
end

-- Gather the text to send: current line in normal mode, visual selection in visual mode.
local function send_code(is_visual)
  if not is_visual then
    send_text(vim.api.nvim_get_current_line() .. "\n")
    return
  end

  -- Exit visual mode so Neovim updates the '< and '> marks, then read them.
  vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<ESC>", true, false, true), "x", true)
  vim.schedule(function()
    local start_pos = vim.fn.getpos("'<")
    local end_pos = vim.fn.getpos("'>")
    local lines = vim.api.nvim_buf_get_lines(0, start_pos[2] - 1, end_pos[2], false)
    send_text(table.concat(lines, "\n") .. "\n")
  end)
end

-- Configure and register the keymaps. Safe to call with no arguments.
M.setup = function(opts)
  opts = opts or {}
  config.command = opts.command or config.command
  config.keymap = opts.keymap or config.keymap

  -- Tag every terminal buffer as "repl" and wipe it when its process exits,
  -- so a closed terminal does not leave a stale buffer behind.
  vim.api.nvim_create_autocmd("TermOpen", {
    callback = function(args)
      vim.bo[args.buf].filetype = "repl"
    end,
  })

  vim.api.nvim_create_autocmd("TermClose", {
    callback = function(args)
      vim.schedule(function()
        if vim.api.nvim_buf_is_valid(args.buf) then
          vim.api.nvim_buf_delete(args.buf, { force = true })
        end
      end)
    end,
  })

  vim.keymap.set("n", config.keymap, function()
    send_code(false)
  end, { desc = "Send line to REPL" })

  vim.keymap.set("x", config.keymap, function()
    send_code(true)
  end, { desc = "Send selection to REPL" })
end

return M
