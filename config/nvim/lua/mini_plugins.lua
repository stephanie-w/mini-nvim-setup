-- ========================================================================== --
--                     MINI.NVIM PLUGINS & WORKFLOW MODULE                    --
-- ========================================================================== --

-- 1. THEME & VISUALS
vim.cmd("colorscheme deep-teal") -- Options: 'nord', 'solarized-dark', 'deep-teal', 'deepwater'
require("mini.statusline").setup()

-- 2. COMPLETION & EDITING AIDS
require("mini.completion").setup({
  lsp_completion = {
    source_func = "completefunc",
    auto_setup = false, -- Handled explicitly on LspAttach
  },
  delay = { completion = 100, info = 100 },
  window = {
    info = { height = 25, width = 80, border = "single" },
    signature = { height = 25, width = 80, border = "single" },
  },
})

-- Attach MiniCompletion LSP completion only when an LSP client connects
vim.api.nvim_create_autocmd("LspAttach", {
  callback = function(args)
    vim.bo[args.buf].completefunc = "v:lua.MiniCompletion.completefunc_lsp"
  end,
})

require("mini.ai").setup() -- Text objects (e.g., 'vif' to select Python function)
require("mini.comment").setup() -- Comment out blocks instantly with 'gc'
require("mini.pairs").setup() -- Automatically close brackets/quotes
require("mini.trailspace").setup() -- Highlight and trim trailing whitespace
require("mini.pick").setup() -- Lightweight fuzzy picker
require("mini.extra").setup() -- Extra pickers (diagnostics, keymaps, git, symbols)

-- Autocomplete Navigation Keymaps (mini.completion & mini.pairs)
vim.keymap.set("i", "<Tab>", function()
  return vim.fn.pumvisible() == 1 and "<C-n>" or "<Tab>"
end, { expr = true, replace_keycodes = true })

vim.keymap.set("i", "<S-Tab>", function()
  return vim.fn.pumvisible() == 1 and "<C-p>" or "<S-Tab>"
end, { expr = true, replace_keycodes = true })

vim.keymap.set("i", "<CR>", function()
  if vim.fn.pumvisible() == 1 and vim.fn.complete_info()["selected"] ~= -1 then
    return "<C-y>"
  end
  return require("mini.pairs").cr()
end, { expr = true, replace_keycodes = true })

-- 3. CLUES (Keymap Guide)
local miniclue = require("mini.clue")
miniclue.setup({
  triggers = {
    -- Leader triggers
    { mode = "n", keys = "<Leader>" },
    { mode = "x", keys = "<Leader>" },
    { mode = "v", keys = "<Leader>" },

    -- Square bracket navigation ([d, ]d, [h, ]h, etc.)
    { mode = "n", keys = "[" },
    { mode = "n", keys = "]" },

    -- Built-in completion
    { mode = "i", keys = "<C-x>" },

    -- `g` key
    { mode = "n", keys = "g" },
    { mode = "x", keys = "g" },
    { mode = "v", keys = "g" },

    -- Marks
    { mode = "n", keys = "'" },
    { mode = "n", keys = "`" },
    { mode = "x", keys = "'" },
    { mode = "x", keys = "`" },

    -- Registers
    { mode = "n", keys = '"' },
    { mode = "x", keys = '"' },
    { mode = "i", keys = "<C-r>" },
    { mode = "c", keys = "<C-r>" },

    -- Window commands
    { mode = "n", keys = "<C-w>" },

    -- `z` key
    { mode = "n", keys = "z" },
    { mode = "x", keys = "z" },
  },

  clues = {
    miniclue.gen_clues.builtin_completion(),
    miniclue.gen_clues.g(),
    miniclue.gen_clues.marks(),
    miniclue.gen_clues.registers(),
    miniclue.gen_clues.windows(),
    miniclue.gen_clues.z(),
    miniclue.gen_clues.square_brackets(),

    -- Leader group descriptions
    { mode = "n", keys = "<Leader>a", desc = "+Assistant (Pi)" },
    { mode = "x", keys = "<Leader>a", desc = "+Assistant (Pi)" },
    { mode = "v", keys = "<Leader>a", desc = "+Assistant (Pi)" },
    { mode = "n", keys = "<Leader>p", desc = "+Pickers" },
    { mode = "n", keys = "<Leader>pk", desc = "+Keymap Pickers" },
    { mode = "n", keys = "<Leader>g", desc = "+Git" },
    { mode = "x", keys = "<Leader>g", desc = "+Git" },
    { mode = "v", keys = "<Leader>g", desc = "+Git" },
    { mode = "n", keys = "<Leader>gp", desc = "+GitHub PRs" },
    { mode = "n", keys = "<Leader>r", desc = "+Refactor & REPL" },
    { mode = "x", keys = "<Leader>r", desc = "+REPL (Selection)" },
    { mode = "v", keys = "<Leader>r", desc = "+REPL (Selection)" },
    { mode = "n", keys = "<Leader>t", desc = "+Toggle & Trim" },
    { mode = "n", keys = "<Leader>c", desc = "+Code Actions" },
  },

  window = {
    delay = 300,
    config = { width = "auto" },
  },
})

-- 4. PICKER KEYMAPS
vim.keymap.set("n", "<leader>tw", "<cmd>lua MiniTrailspace.trim()<cr>", { desc = "Trim trailing whitespace" })
vim.keymap.set("n", "<leader>pf", "<cmd>Pick files<cr>", { desc = "Pick Files" })
vim.keymap.set("n", "<leader>pg", "<cmd>Pick grep_live<cr>", { desc = "Pick Grep (Live)" })
vim.keymap.set("n", "<leader>pb", "<cmd>Pick buffers<cr>", { desc = "Pick Buffers" })
vim.keymap.set("n", "<leader>ph", "<cmd>Pick help<cr>", { desc = "Pick Help" })
vim.keymap.set("n", "<leader>pd", function()
  MiniExtra.pickers.diagnostic()
end, { desc = "Pick Diagnostics" })
vim.keymap.set("n", "<leader>pka", function()
  MiniExtra.pickers.keymaps({ mode = "n", scope = "global" })
end, { desc = "Pick Keymaps (Normal Mode)" })

vim.keymap.set("n", "<leader>pc", function()
  MiniExtra.pickers.git_commits()
end, { desc = "Pick Git Commits" })

vim.keymap.set("n", "<leader>pS", function()
  local MiniPick = require("mini.pick")
  local stashes = vim.fn.systemlist({ "git", "stash", "list" })
  if vim.v.shell_error ~= 0 or #stashes == 0 then
    vim.notify("No git stashes found.", vim.log.levels.INFO)
    return
  end
  local preview = function(buf_id, item)
    if type(item) ~= "string" then
      return
    end
    local stash_ref = item:match("^(stash@{%d+})")
    if not stash_ref then
      return
    end
    vim.bo[buf_id].filetype = "diff"
    local out = vim.fn.systemlist({ "git", "stash", "show", "-p", stash_ref })
    vim.api.nvim_buf_set_lines(buf_id, 0, -1, false, out)
  end
  local choose = function(item)
    local stash_ref = item:match("^(stash@{%d+})")
    if stash_ref then
      vim.schedule(function()
        vim.cmd("tabnew | terminal git stash show -p " .. vim.fn.fnameescape(stash_ref) .. " | delta --paging=always")
        vim.cmd("startinsert")
      end)
    end
  end
  MiniPick.start({
    source = {
      items = stashes,
      name = "Git Stashes",
      preview = preview,
      choose = choose,
    },
  })
end, { desc = "Pick Git Stashes (with live diff preview)" })

vim.keymap.set("n", "<leader>ps", function()
  MiniExtra.pickers.lsp({ scope = "document_symbol" })
end, { desc = "Pick Document Symbols" })

vim.keymap.set("n", "<leader>pr", function()
  MiniExtra.pickers.lsp({ scope = "references" })
end, { desc = "Pick References" })

-- 5. FILE EXPLORER (mini.files) + TAB HOOKS
require("mini.files").setup()

vim.keymap.set("n", "<leader>e", function()
  require("mini.files").open()
end, { desc = "Open File Explorer" })

local map_tabedit = function(buf_id, lhs)
  local MiniFiles = require("mini.files")
  vim.keymap.set("n", lhs, function()
    local fs_entry = MiniFiles.get_fs_entry()
    if fs_entry ~= nil and fs_entry.fs_type == "file" then
      MiniFiles.close()
      vim.cmd("tabedit " .. vim.fn.fnameescape(fs_entry.path))
    else
      MiniFiles.go_in()
    end
  end, { buffer = buf_id, desc = "Open file in new tab" })
end

vim.api.nvim_create_autocmd("User", {
  pattern = "MiniFilesBufferCreate",
  callback = function(args)
    map_tabedit(args.data.buf_id, "gt") -- 'gt' inside mini.files opens in a new tab
  end,
})

-- Global Tab Navigation
vim.keymap.set("n", "H", "<cmd>tabprevious<cr>", { desc = "Go to previous tab" })
vim.keymap.set("n", "L", "<cmd>tabnext<cr>", { desc = "Go to next tab" })
