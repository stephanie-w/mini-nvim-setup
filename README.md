# Custom Isolated Neovim Configuration (Neovim 0.12)

This repository contains a highly optimized, fully sandboxed, and modular **Neovim 0.12** configuration environment. It is designed to run completely isolated from your global system configuration, targeting **Python**, **Lua**, and modern text workflows with native performance and a minimal footprint.

---

## Architecture & Isolation

All configurations, data, cache, and state files are strictly scoped to this workspace. This isolation is achieved via the custom launcher script `./nv`, which overrides standard `XDG` environment variables.

### Modular Directory Structure

*   **`./nv`**: The Python-based launcher script. Always run this instead of `nvim`.
*   **`.stylua.toml`**: Universal Lua code formatting rules (2-space indents, Unix endings) ensuring 100% sync consistency across machines.
*   **`config/nvim/`** (maps to `XDG_CONFIG_HOME`):
    *   `init.lua`: Clean high-level entrypoint requiring modular domain configs.
    *   `lua/options.lua`: Editor options, 2-space Lua & 4-space Python indentation rules, and automatic `.venv` detection.
    *   `lua/theme.lua`: Centralized theme selection (`deep-teal`, `nord`, `solarized-dark`, `deepwater`) and UI highlights.
    *   `lua/mini_plugins.lua`: Complete `mini.nvim` suite (completion, clues, fuzzy pickers, file explorer, text objects).
    *   `lua/lsp.lua`: Native Ruff & ty LSP configuration and format-on-save.
    *   `lua/git.lua`: Git workflows, `mini.diff`, `mini.git`, Delta terminal viewer, and GitHub CLI integrations.
    *   `lua/repl.lua`: Interactive Python / IPython REPL integration (`<leader>rr`).
    *   `lua/ai.lua`: Native lightweight **Pi AI agent** integration with `agentic.nvim` fallback.
    *   `lua/local_profile.lua`: Local coding assistant profile configs (git-ignored).
    *   `lsp/ruff.lua`: Native configuration for the Ruff language server.
    *   `lsp/ty.lua`: Native configuration for the ty language server/type checker.
    *   `colors/`: Directory containing custom colorschemes (`nord.lua`, `solarized-dark.lua`, `deep-teal.lua`, `deepwater.lua`).
*   **`data/`** (maps to `XDG_DATA_HOME`): Stores installed plugins (`mini.nvim`, `agentic.nvim`).
*   **`state/`** (maps to `XDG_STATE_HOME`): Stores search histories, transient states, and logs.
*   **`cache/`** (maps to `XDG_CACHE_HOME`): Editor cache files.

---

## Core Features & Integrations

1.  **Lightweight Plugin Suite (`mini.nvim`)**
    *   **Theme**: Built-in colorschemes (`deep-teal`, `nord`, `solarized-dark` using `mini.base16`). Integrated statusline.
    *   **UX Modules**: Automatic quote/bracket pairing, instant commenting (`gc`), text objects (`mini.ai`), auto-completion popups, and trailing whitespace highlighting/trimming.
    *   **File Explorer**: Integrated tree view explorer (`mini.files`) with `gt` tab-opening hooks.
2.  **Native Language Server Protocol (Ruff & ty)**
    *   Configured natively via Neovim 0.12 LSP APIs (`vim.lsp.enable`).
    *   Ruff provides instant linting, formatting on save, and quick-fixes.
    *   ty provides fast static type-checking and autocomplete.
3.  **Local Git HUD & PR Reviews**
    *   Gutter diff indicators via `mini.diff`, commit log graphs, Delta side-by-side terminal diffs, and GitHub PR reviews.
4.  **Native Pi AI Coding Assistant (`pi`)**
    *   Lightweight, sub-second AI assistance with active file/selection context.
    *   In-place autonomous file edits with automatic buffer reload and `mini.diff` highlighting.
    *   Read-only questions rendered in clean floating Markdown windows.
    *   Interactive terminal chat sidebar (`<leader>at`) connected directly to Neovim via RPC.

---

## 🤖 Pi Coding Agent Setup (Recommended)

This configuration is built to seamlessly pair with the **Pi coding agent** ([pi.dev](https://pi.dev)).

### 1. Install Pi
```bash
curl -fsSL https://pi.dev/install.sh | sh
# or via npm:
npm install -g @mariozechner/pi
```

### 2. Install the Neovim Extension for Pi (Strongly Recommended)
To allow `pi` to automatically detect Neovim, read your live in-memory buffer content, and know what file you are currently viewing, install the **`neovim.ts`** extension into your global Pi extensions directory:

```bash
mkdir -p ~/.pi/agent/extensions
# Place neovim.ts in ~/.pi/agent/extensions/neovim.ts
```

* **What it gives Pi:**
  * Auto-detects the parent Neovim editor socket (`$NVIM`).
  * Gives Pi the `nvim_get_context` tool to query your active file and cursor position.
  * Gives Pi the `nvim_read_buffer` tool to read unsaved in-memory edits directly from Neovim.
  * Gives Pi the `nvim_command` tool to send Ex commands (like `:checktime`).

---

## Installation & Prerequisites

To use this configuration environment, make sure you have:
*   **Neovim 0.12+**
*   **Python 3**
*   **Ruff** (for code formatting/diagnostics and LSP keymaps like `<leader>ca`, `<leader>rn`)
*   **ty** (Astral's type checker, e.g. `uv tool install ty` or `pip install ty`)
*   **ripgrep (rg)** (required for live grep picker `<leader>pg`)
*   **fd** (recommended for fast file finder picker `<leader>pf`)
*   **delta** (optional, for syntax-highlighted git diffs)

### Virtual Environments
This setup is aware of **`uv`** and standard `venv` workflows. It detects `.venv` at the root of the project and automatically adjusts your Python LSP path environment dynamically.

---

## Getting Started

To launch this isolated configuration:
```bash
./nv [file_paths...]
```

To edit the main configuration directly:
```bash
./nv config/nvim/init.lua
```

---

## 📚 Workflow Guides & Interactive Sandbox

Deep step-by-step guides and an interactive testing ground are provided:

*   📖 **[Daily Git Workflow & Review Guide (docs/git-workflow.md)](docs/git-workflow.md)**: Master gutter diffs, inline overlays, granular hunk staging (`ghgh`), line staging, interactive commits, branch graphs, and Delta reviews.
*   📖 **[Daily LSP & Code Intelligence Guide (docs/lsp-workflow.md)](docs/lsp-workflow.md)**: Master diagnostics navigation (`]d`/`[d`), floating inspector (`<leader>d`), code actions (`<leader>ca`), cross-file `gd`, references, smart rename (`<leader>rn`), and format-on-save.
*   🧪 **[Interactive Sandbox Practice Guide (docs/sandbox-guide.md)](docs/sandbox-guide.md)**: Hands-on testing environment to practice every keymap safely without touching production code.

### Quick Sandbox Tryout
```bash
python3 sandbox/reset_sandbox.py  # Populates live git hunks & LSP test cases
./nv sandbox/playground/service.py # Launch isolated Neovim playground
```

---

## ⌨️ Keybindings & Shortcuts

👉 **[View Full Keymaps & Shortcuts Cheatsheet (KEYMAPS.md)](KEYMAPS.md)**

### Quick Reference Highlights

| Category | Primary Keymaps | Description |
| :--- | :--- | :--- |
| **AI Coding Assistant** | `<leader>ap` (prompt/edit/ask), `<leader>at` (chat sidebar), `<leader>as` (stop) | Native Pi Coding Agent |
| **Agentic Fallback** | `<leader>aa` or `:Agentic` | ACP Agentic sidebar |
| **Navigation & Tabs** | `H` / `L`, `<leader>e`, `gt` | Tab switching & explorer |
| **LSP & Intelligence** | `K`, `<C-k>`, `gd`, `<leader>rn`, `<leader>ca`, `<leader>d`, `]d`/`[d` | Hover docs, signatures, actions, diagnostics |
| **Autocomplete** | `<Tab>`, `<S-Tab>`, `<CR>` | Popup navigation & bracket matching |
| **Fuzzy Pickers** | `<leader>pf` (files), `<leader>pg` (grep), `<leader>pb` (buffers) | Fast fuzzy search (`mini.pick`) |
| **Git Operations** | `ghgh` (stage hunk), `<leader>td` (diff overlay), `<leader>gs` | Gutter diffs & repository HUD |
| **GitHub PRs** | `<leader>gpr` (list), `<leader>gpd` (diff with `delta`) | GitHub CLI review tools |
| **Interactive REPL** | `<leader>rr` (send line / selection) | IPython terminal integration |

---

## Daily AI Assistant Workflow (`pi`)

Here is how you use the integrated AI assistant during daily development:

### 1. 💬 Ask a Read-Only Question (`<leader>ap`)
- Press **`<leader>ap`** in Normal mode (or with lines selected in Visual mode).
- Type a question (e.g. *"What does this function do?"*, *"Why is this failing?"*).
- **Result:** A floating Markdown popup appears with the answer. Press **`q`** or **`<Esc>`** to close.

### 2. ⚡ In-Place Code Editing (`<leader>ap`)
- Press **`<leader>ap`** and enter an edit instruction (e.g. *"Refactor this function to handle exceptions"*, *"Add docstrings"*).
- **Result:** `pi` modifies the file in the background, Neovim automatically reloads the buffer, and `mini.diff` highlights the changes in the gutter.

### 3. 🤖 Interactive Chat Panel (`<leader>at`)
- Press **`<leader>at`** to toggle open a dedicated Pi terminal panel on the right.
- `pi` automatically detects your active Neovim buffer via RPC.
- Press **`Ctrl + P`** inside Pi to cycle models.
- Press **`<leader>at`** (or **`q`** in Normal mode) to hide the panel. Your session and conversation history remain preserved.

### 4. 🛡️ Agentic Fallback (`<leader>aa` / `:Agentic`)
- If you need to switch to an ACP provider (DeepSeek, Kiro, Gemini), press **`<leader>aa`** or type **`:Agentic`** to open the `agentic.nvim` sidebar.
