-- ========================================================================== --
--                     INTERACTIVE PYTHON REPL MODULE                         --
-- ========================================================================== --

local function send_text_to_repl(text)
  -- Look for an existing terminal channel
  local term_chan = nil
  for _, chan in ipairs(vim.api.nvim_list_chans()) do
    if chan.mode == "terminal" and chan.pty then
      term_chan = chan.id
      break
    end
  end

  -- If no terminal is open, split and start ipython via uvx
  if not term_chan then
    vim.cmd("vsplit | terminal uvx ipython")
    vim.cmd("sleep 100m") -- Give PTY a split-second to start
    for _, chan in ipairs(vim.api.nvim_list_chans()) do
      if chan.mode == "terminal" and chan.pty then
        term_chan = chan.id
        break
      end
    end
  end

  -- Send the text to the terminal input channel
  if term_chan then
    vim.api.nvim_chan_send(term_chan, text)
  end
end

local function send_code_to_repl(is_visual)
  if is_visual then
    -- Exit visual mode to update visual selection marks ('< and '>)
    vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<ESC>", true, false, true), "x", true)
    vim.schedule(function()
      local start_pos = vim.fn.getpos("'<")
      local end_pos = vim.fn.getpos("'>")
      local lines = vim.api.nvim_buf_get_lines(0, start_pos[2] - 1, end_pos[2], false)
      local text = table.concat(lines, "\n") .. "\n"
      send_text_to_repl(text)
    end)
  else
    local text = vim.api.nvim_get_current_line() .. "\n"
    send_text_to_repl(text)
  end
end

-- Keymaps to send current line (Normal) or selection (Visual) to REPL
vim.keymap.set("n", "<leader>rr", function()
  send_code_to_repl(false)
end, { desc = "Send line to REPL" })

vim.keymap.set("x", "<leader>rr", function()
  send_code_to_repl(true)
end, { desc = "Send selection to REPL" })
