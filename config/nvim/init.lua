-- ========================================================================== --
--                     NEOVIM 0.12 CUSTOM ISOLATED CONFIG                     --
-- ========================================================================== --

-- 1. Global Options & Environment Setup
require("options")

-- 2. Theme & UI Highlights (deep-teal, deepwater, nord, solarized-dark)
require("theme").setup("deep-teal")

-- 3. mini.nvim Suite & Visuals (Completion, Clues, Pickers, Files, Text Objects)
require("mini_plugins")

-- 3. Native LSP & Diagnostics (Ruff, ty, Format on Save)
require("lsp")

-- 4. Git Workflows, Diff Overlays & Delta Viewer
require("git")

-- 5. Interactive Python REPL (uv / ipython)
require("repl").setup()

-- 6. Pi AI Coding Assistant (Prompt, Edit, Ask, Chat)
require("ai")
