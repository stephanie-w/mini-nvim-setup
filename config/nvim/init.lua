-- ========================================================================== --
--                     NEOVIM 0.12 CUSTOM ISOLATED CONFIG                     --
-- ========================================================================== --

-- 1. GLOBAL OPTIONS --
require("options")

-- ========================================================================== --
-- 2. THEME & VISUALS (Built-in mini.nvim)
-- ========================================================================== --
vim.cmd("colorscheme deepwater") -- Options: 'nord', 'solarized-dark', 'deep-teal', 'deepwater'
require("mini.statusline").setup() -- Polished, integrated statusline

-- ========================================================================== --
-- 3. DEVELOPMENT LIFE QUALITY MODULES
-- ========================================================================== --
require("mini.completion").setup({ -- Native, lightweight auto-completion popups
	delay = { completion = 100, info = 100 },
	window = {
		info = { height = 25, width = 80, border = "single" },
		signature = { height = 25, width = 80, border = "single" },
	},
})
require("mini.ai").setup() -- Text objects (e.g., 'vif' to select in Python function)
require("mini.comment").setup() -- Comment out blocks instantly with 'gc'
require("mini.pairs").setup() -- Automatically close brackets/quotes
require("mini.trailspace").setup() -- Highlight and trim messy trailing whitespace
require("mini.pick").setup() -- Lightweight fuzzy picker
require("mini.extra").setup() -- Extra pickers (diagnostics, keymaps, etc.)

vim.keymap.set("n", "<leader>tw", "<cmd>Lua MiniTrailspace.trim()<cr>", { desc = "Trim trailing whitespace" })

-- Picker Keymaps
vim.keymap.set("n", "<leader>pf", "<cmd>Pick files<cr>", { desc = "Pick Files" })
vim.keymap.set("n", "<leader>pg", "<cmd>Pick grep_live<cr>", { desc = "Pick Grep (Live)" })
vim.keymap.set("n", "<leader>pb", "<cmd>Pick buffers<cr>", { desc = "Pick Buffers" })
vim.keymap.set("n", "<leader>ph", "<cmd>Pick help<cr>", { desc = "Pick Help" })
vim.keymap.set("n", "<leader>pd", function()
	MiniExtra.pickers.diagnostic()
end, { desc = "Pick Diagnostics" })
vim.keymap.set("n", "<leader>pka", function()
	MiniExtra.pickers.keymaps()
end, { desc = "Pick All Keymaps" })
vim.keymap.set("n", "<leader>pkl", function()
	MiniExtra.pickers.keymaps({}, { query = { "l", "s", "p" } })
end, { desc = "Pick LSP Keymaps" })
vim.keymap.set("n", "<leader>pkg", function()
	MiniExtra.pickers.keymaps({}, { query = { "g", "i", "t" } })
end, { desc = "Pick Git Keymaps" })
vim.keymap.set("n", "<leader>pkp", function()
	MiniExtra.pickers.keymaps({}, { query = { "p", "i", "c", "k" } })
end, { desc = "Pick Picker Keymaps" })
vim.keymap.set("n", "<leader>pc", function()
	MiniExtra.pickers.git_commits()
end, { desc = "Pick Git Commits" })
vim.keymap.set("n", "<leader>ps", function()
	MiniExtra.pickers.lsp({ scope = "document_symbol" })
end, { desc = "Pick Document Symbols" })
vim.keymap.set("n", "<leader>pr", function()
	MiniExtra.pickers.lsp({ scope = "references" })
end, { desc = "Pick References" })

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

-- ========================================================================== --
-- 4. FILE EXPLORER (mini.files) + NAVIGATION
-- ========================================================================== --
require("mini.files").setup()

-- Open file explorer UI
vim.keymap.set("n", "<leader>e", function()
	require("mini.files").open()
end, { desc = "Open File Explorer" })

-- Hook to intercept file open requests and push them smoothly into new tabs
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

-- Global Tab Navigation Shortcuts
vim.keymap.set("n", "H", "<cmd>tabprevious<cr>", { desc = "Go to previous tab" })
vim.keymap.set("n", "L", "<cmd>tabnext<cr>", { desc = "Go to next tab" })

-- ========================================================================== --
-- 5. MANUAL LSP CONFIGURATION (Python / uv)
-- ========================================================================== --

-- Enable Ruff and ty natively (no nvim-lspconfig needed)
vim.lsp.enable("ruff")
vim.lsp.enable("ty")

-- Configure Neovim diagnostics display (e.g., live Ruff updates)
vim.diagnostic.config({
	virtual_text = {
		source = "always", -- Show "ruff" source label on messages
	},
	signs = true,
	underline = true,
	update_in_insert = true, -- Update diagnostic messages live while typing/editing
	severity_sort = true,
})

-- Format Python files instantly on save using Ruff
vim.api.nvim_create_autocmd("BufWritePre", {
	pattern = "*.py",
	callback = function()
		vim.lsp.buf.format({ async = false })
	end,
})

-- Core Code Navigation Keymaps
vim.keymap.set("n", "gd", vim.lsp.buf.definition, { desc = "Go to Definition" })
vim.keymap.set("n", "K", vim.lsp.buf.hover, { desc = "Show Code Documentation" })
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

-- ========================================================================== --
-- 6. TREESITTER HIGH-PERFORMANCE NATIVE SYNTAX (Optional)
-- ========================================================================== --
-- To enable native Treesitter syntax highlighting, uncomment the block below.
-- NOTE: This requires having the compiled 'python.so' parser installed in your
-- Neovim runtimepath (e.g. inside `data/nvim/parser/python.so`).
--
-- vim.api.nvim_create_autocmd("FileType", {
-- 	pattern = "python",
-- 	callback = function()
-- 		vim.treesitter.start()
-- 	end,
-- })

-- ========================================================================== --
-- 7. GIT WORKFLOW & HISTORY PANEL
-- ========================================================================== --
require("mini.diff").setup({
	view = {
		style = "sign",
		signs = { add = "┃", change = "┃", delete = "━" },
	},
})
require("mini.git").setup()

-- Git Navigation Maps
vim.keymap.set("n", "]h", function()
	require("mini.diff").goto_hunk("next")
end, { desc = "Next Git hunk" })
vim.keymap.set("n", "[h", function()
	require("mini.diff").goto_hunk("prev")
end, { desc = "Previous Git hunk" })

-- Git Tab Layouts
vim.keymap.set("n", "<leader>gl", "<cmd>tab Git log --oneline<cr>", { desc = "Git Log (Dedicated Tab)" })
vim.keymap.set("n", "<leader>gs", "<cmd>tab Git status<cr>", { desc = "Git Status (Dedicated Tab)" })

-- Open Commit Diff on the Right Panel
vim.keymap.set("n", "<leader>gc", function()
	vim.cmd("vertical lua require('mini.git').show_at_cursor()")
end, { desc = "Inspect commit in right panel" })

-- Git Line History (Normal and Visual modes)
vim.keymap.set({ "n", "x" }, "<leader>gh", "<cmd>lua MiniGit.show_range_history()<cr>", { desc = "Git Range History" })

-- Force Filetypes for syntax colors on raw git log stream
vim.api.nvim_create_autocmd("User", {
	pattern = "MiniGitCommandSplit",
	callback = function(args)
		local win_id = args.data.win_stdout
		local bufnr = vim.api.nvim_win_get_buf(win_id)
		local lines = vim.api.nvim_buf_get_lines(bufnr, 0, 1, false)
		if #lines > 0 then
			if lines[1]:match("^commit") or lines[1]:match("^diff %-%-git") then
				vim.bo[bufnr].filetype = "diff"
			elseif lines[1]:match("^%*?%s*%x%x%x%x%x%x%x") or args.data.git_subcommand == "log" then
				vim.bo[bufnr].filetype = "git"
			end
		end
	end,
})

-- ========================================================================== --
-- 8. ACP CODING ASSISTANT (agentic.nvim)
-- ========================================================================== --

-- Safely load local profile settings
local has_profile, local_profile = pcall(require, "local_profile")
local active_profile = has_profile and local_profile or {}

-- Determine the default provider based on active environment profile
local default_provider = "agy"
if active_profile.profile == "work" then
	default_provider = active_profile.default_work_provider or "kiro"
elseif active_profile.profile == "home" then
	default_provider = active_profile.default_home_provider or "agy"
end

-- Restore host XDG env variables for spawned agent CLI processes
local original_env = {
	XDG_CONFIG_HOME = os.getenv("ORIG_XDG_CONFIG_HOME") or (os.getenv("HOME") .. "/.config"),
	XDG_DATA_HOME = os.getenv("ORIG_XDG_DATA_HOME") or (os.getenv("HOME") .. "/.local/share"),
	XDG_STATE_HOME = os.getenv("ORIG_XDG_STATE_HOME") or (os.getenv("HOME") .. "/.local/state"),
	XDG_CACHE_HOME = os.getenv("ORIG_XDG_CACHE_HOME") or (os.getenv("HOME") .. "/.cache"),
}

-- Initialize the ACP client with your available providers
require("agentic").setup({
	provider = default_provider,
	acp_providers = {
		["agy"] = {
			name = "Gemini (AGY)",
			command = "agy",
			args = { "acp" },
			env = original_env,
		},
		["opencode"] = {
			name = "DeepSeek (OpenCode)",
			command = "opencode",
			args = { "acp" },
			env = original_env,
		},
		["kiro"] = {
			name = "Kiro Agent",
			command = "kiro-cli",
			args = { "acp" },
			env = original_env,
		},
		["copilot"] = {
			name = "GitHub Copilot",
			command = "copilot-agent",
			args = { "--acp" },
			env = original_env,
		},
	},
})

-- Assistant Keymaps
vim.keymap.set({ "n", "x" }, "<leader>at", function()
	require("agentic").toggle()
end, { desc = "Toggle Assistant Chat Sidebar" })

-- Enable markdown syntax highlighting for all Agentic buffers (since Treesitter is disabled)
vim.api.nvim_create_autocmd({ "FileType", "BufWinEnter" }, {
	pattern = "Agentic*",
	callback = function()
		vim.schedule(function()
			if vim.api.nvim_buf_is_valid(0) then
				vim.bo.syntax = "markdown"
			end
		end)
	end,
})

-- Enable syntax highlighting inside code fences for common languages
vim.g.markdown_fenced_languages = { "python", "lua", "bash", "sh" }

-- ========================================================================== --
-- 9. INTERACTIVE PYTHON REPL
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

	-- If no terminal is open, split and start python3
	if not term_chan then
		vim.cmd("vsplit | terminal python3")
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
		-- Exit visual mode to force Neovim to update visual selection marks ('< and '>)
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
