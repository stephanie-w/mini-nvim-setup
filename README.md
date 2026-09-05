# Custom Isolated Neovim Configuration (Neovim 0.12)

This repository contains a highly optimized, fully sandboxed, and lightweight **Neovim 0.12** configuration environment. It is designed to run completely isolated from your global system configuration, targeting **Python** workflows with native performance and a minimal footprint.

---

## Architecture & Isolation

All configurations, data, cache, and state files are strictly scoped to this workspace. This isolation is achieved via the custom launcher script `./nv`, which overrides standard `XDG` environment variables.

### Directory Structure

*   **`./nv`**: The Python-based launcher script. Always run this instead of `nvim`.
*   **`config/nvim/`** (maps to `XDG_CONFIG_HOME`):
    *   `init.lua`: The entry point loading setup, autocommands, and keybindings.
    *   `lua/options.lua`: Basic editor options, leader key definitions, and automatic `.venv` detection.
    *   `lua/local_profile.lua`: Local coding assistant profile configs (git-ignored).
    *   `lsp/ruff.lua`: Native configuration file for the Ruff language server.
    *   `lsp/ty.lua`: Native configuration file for the ty language server/type checker.
    *   `colors/`: Directory containing custom colorschemes (`nord.lua`, `solarized-dark.lua`, `deep-teal.lua`).
*   **`data/`** (maps to `XDG_DATA_HOME`): Stores downloaded plugins (e.g., `mini.nvim`, `agentic.nvim`).
*   **`state/`** (maps to `XDG_STATE_HOME`): Stores search histories, transient states, and logs.
*   **`cache/`** (maps to `XDG_CACHE_HOME`): Editor cache files.

---

## Features

1.  **Lightweight Plugin Suite (`mini.nvim`)**
    *   **Theme**: Built-in colorschemes (`nord`, `solarized-dark`, and `deep-teal` using `mini.base16`). Custom status line.
    *   **UX Modules**: Automatic quote/bracket pairing, instant commenting (`gc`), text objects, auto-completion popups, and trailing whitespace highlighting/trimming.
    *   **File Explorer**: Integrated tree view explorer (`mini.files`).
2.  **Native LSP Setup (Ruff & ty)**
    *   Directly configured via native Neovim 0.12 LSP APIs (`vim.lsp.enable`).
    *   Ruff provides instant linting, formatting, and quick-fixes.
    *   ty provides fast static type-checking and type-based autocomplete.
3.  **Local Git HUD**
    *   Gutter hunk indications, hunk navigation, and commit diff inspection.

---

## Installation & Prerequisites

To use this configuration environment, make sure you have:
*   **Neovim 0.12+**
*   **Python 3**
*   **Ruff** (for code formatting/diagnostics and LSP keymaps like `<leader>ca`, `<leader>rn`)
*   **ty** (Astral's type checker, e.g. `pip install ty` or `uv tool install ty`)
*   **ripgrep (rg)** (required for the live grep picker keymap `<leader>pg`)
*   **fd** (recommended for the fast file finder picker keymap `<leader>pf`)

### Plugin Installation
Clone the `mini.nvim` and `agentic.nvim` repositories into the isolated configuration's package start directory:
```bash
git clone --depth 1 https://github.com/echasnovski/mini.nvim.git data/nvim/site/pack/plugins/start/mini.nvim
git clone --depth 1 https://github.com/carlos-algms/agentic.nvim.git data/nvim/site/pack/plugins/start/agentic.nvim
```

### Virtual Environments
This setup is aware of **`uv`** and standard `venv` workflows. It detects `.venv` at the root of the project and automatically adjusts your Python LSP path environment dynamically.

---

## Getting Started

To launch this configuration, use the local runner script:
```bash
./nv [file_paths...]
```

To edit the main configuration directly:
```bash
./nv config/nvim/init.lua
```

---

## ⌨️ Keybindings & Shortcuts

All keybindings are organized into a dedicated, categorized cheatsheet:

👉 **[View Full Keymaps & Shortcuts Cheatsheet (KEYMAPS.md)](KEYMAPS.md)**

### Quick Reference Highlights

| Category | Primary Keymaps | Description |
| :--- | :--- | :--- |
| **Navigation & Tabs** | `H` / `L`, `<leader>e`, `gt` | Tab switching & explorer |
| **LSP & Intelligence** | `K`, `<C-k>`, `gd`, `<leader>ca`, `<leader>d`, `]d`/`[d` | Hover docs, signatures, actions, diagnostics |
| **Autocomplete** | `<Tab>`, `<S-Tab>`, `<CR>` | Popup navigation & bracket matching |
| **Fuzzy Pickers** | `<leader>pf` (files), `<leader>pg` (grep), `<leader>pb` (buffers) | Fast fuzzy search (`mini.pick`) |
| **Git Operations** | `ghgh` (stage hunk), `<leader>td` (diff overlay), `<leader>gs` | Gutter diffs & repository HUD |
| **GitHub PRs** | `<leader>gpr` (list), `<leader>gpd` (diff with `delta`) | GitHub CLI review tools |
| **Coding Assistant** | `<leader>at` (sidebar), `<leader>ap` (prompt), `<leader>as` (stop) | Multi-provider ACP AI Agent |
| **Interactive REPL** | `<leader>rr` (send line / selection) | IPython terminal integration |
| **Live Keymap Finder** | `<leader>pka` | Interactive searchable keymap picker in Neovim |

---

## Daily Developer Git & Staging Workflow Scenario

Here is how a developer uses these integrated tools to review, navigate into changed files, stage granular hunks/files, and commit during a typical workday:

### 1. ☕ Morning Context & Branch Switching
- **View Full Repository Tree:** Press `<leader>gL` to open the graph log across all branches in a new tab. Press `<CR>` on any commit line to inspect its diff in-place, and `q` or `<BS>` to close the diff and return to the log.
- **Switch Branches:** Press `<leader>gb` to fuzzy pick and switch local or remote branches.

### 2. 🚀 Quick Shell Review & Navigate into Changed Files (`nvc`)
To quickly open all modified, staged, and newly created files across dedicated Neovim tabs directly from your terminal, add this helper function to your `~/.bashrc` or `~/.zshrc`:

```bash
# Open all changed, staged, and untracked files in isolated Neovim tabs (-p)
nvc() {
  local files
  files=$(git status --porcelain=v1 2>/dev/null | awk '$1 !~ /D/ {print $NF}' | sort -u)
  if [ -n "$files" ]; then
    ./nv -p $files
  else
    echo "✨ Clean working directory — no changed or created files."
  fi
}

# Fast alias to launch Neovim straight into the Git status tab
alias nvs='./nv -c "tab Git status"'
```

- **Run `nvc` in your terminal:** Neovim launches with every touched file open in its own tab.
- **Cycle through files:** Use **`H`** (previous tab) and **`L`** (next tab) to navigate between files effortlessly.

### 3. ✍️ Active Coding & Live Diff Tracking
- **Live Inline Diff Overlay:** Press `<leader>td` to toggle colored inline diff highlights directly inside your code buffer (`+` green, `-` red, with character-level word diffs).
- **Hunk Navigation:** Press `]h` or `[h` to jump directly to next or previous modified hunks.

### 4. ✂️ Granular Hunk, Line & File Staging
- **Stage Hunk Under Cursor:** Press **`ghgh`** to stage only the hunk under your cursor into the Git index. Notice the gutter sign updates immediately.
- **Stage Visual Selection / Lines:** Select lines in Visual mode (`v` or `V`) and press **`gh`** to stage only those specific lines.
- **Stage Single Line:** Press **`gh_`** on the current line.
- **Stage Entire Active File:** Run **`:Git add %`** in command line.
- **Discard Unwanted Edits (e.g. debug print lines):** Press **`gHgh`** on the hunk or select lines in Visual mode and press **`gH`** to revert them back to the Git index/HEAD.
- **Interactive Patch Mode:** Run **`:Git add -p`** to step through hunks in an interactive CLI split.

### 5. 📦 Status Verification & Committing
- **Status Dashboard Tab:** Press **`<leader>gs`** to open `:tab Git status` and review all staged vs unstaged files.
- **Inspect Staged Diff:** Run `:vert Git diff --staged` or `:Git diff --cached` to verify the final staged patch.
- **Commit with Interactive Editor:** Run **`:Git commit`** to open a Neovim split buffer for your commit message. Type your message, save and close with `:wq`.
- **Verify Log:** Press **`<leader>gL`** to admire your clean, granular commit graph.

---

## Daily Python Developer Workflow Scenario

Here is how a Python developer navigates, inspects documentation, debugs type errors, and executes code:

### 1. 🔍 Code Navigation & Exploring Method Signatures
- **Go to Definition:** Place cursor on any class, method, or function and press **`gd`** to jump directly to its source definition.
- **Inspect Method Documentation & Type Hints:** Press **`K`** on any function/class to pop up its full docstring, arguments, return type signature, and type hints provided natively by Ruff & `ty`.
- **List Buffer Methods & Classes:** Press **`<leader>ps`** (`MiniExtra.pickers.lsp`) to fuzzy-search all functions, classes, and methods defined in the current file.
- **Find References Across Project:** Press **`<leader>pr`** on any symbol to locate all usages across the repository.
- **Jump Back/Forward:** Press **`Ctrl-O`** to jump back to where you were, or **`Ctrl-I`** to jump forward.

### 2. 🐛 Investigating Linting & Typecheck Issues (Ruff & `ty`)
- **Live Diagnostics:** As you type, Ruff and `ty` display live diagnostic hints directly on the line.
- **Cycle Through Issues:** Press **`]d`** to jump to the **next** diagnostic error/warning, or **`[d`** for the **previous** one.
- **Inspect Detailed Error Info:** Press **`<leader>d`** to open a floating window showing the exact error code, message, and traceback.
- **Workspace Error Overview:** Press **`<leader>pd`** to open a fuzzy picker listing all linting and type errors across all currently active/loaded buffers in your session.

### 3. ⚡ Quick Fixes, Formatting & Refactoring
- **Auto-Fix & Import Support:** Press **`<leader>ca`** on a diagnostic line to trigger LSP code actions (e.g. automatically insert missing imports or apply Ruff quick-fixes).
- **Smart Symbol Rename:** Press **`<leader>rn`** on a function or variable to rename it cleanly across the file.
- **Format on Save:** Saving (`:w`) automatically formats Python code according to Ruff standards.

### 4. 🐍 Interactive REPL Testing
- **Send Line to REPL:** In Normal mode, press **`<leader>rr`** on any line to send it directly to an interactive IPython terminal split.
- **Send Selected Block:** Highlight a block in Visual mode (`v`) and press **`<leader>rr`** to execute the entire block in the REPL.

---

## Daily Agentic Coding Workflow Scenario

Here is how a developer leverages the integrated ACP AI coding assistant (`agentic.nvim`) throughout their daily coding tasks:

### 1. 🤖 Context-Aware Prompting & Selection
- **Quick Prompt Box (`<leader>ap`):** Highlight lines in Visual mode (or stay on current file in Normal mode) and press **`<leader>ap`** to open an interactive floating prompt box, type your prompt, and press `<CR>`. It automatically attaches your context, opens the chat, and places your query!
- **Add Selected Lines to Chat (`<leader>ac`):** Highlight line(s) in Visual mode (`v` or `V`) and press **`<leader>ac`** to add the selection directly to the Agentic chat context.
- **Toggle Chat Sidebar:** Press **`<leader>at`** to open or close the AI assistant sidebar alongside your active buffer.
- **Attach Relevant Workspace Files:** Inside the prompt window, type **`@`** to fuzzy-search and attach exact files from your repository so the model receives full context.
- **Yank & Paste directly:** Since standard Neovim buffers are used, you can yank (`yy` or visual `y`) lines from any code file and paste (`p`) directly into the Chat prompt window.

### 2. ⚡ Dynamic Model & Provider Switching
- **Switch AI Provider:** Press **`<localLeader>s`** inside the chat panel to switch between available providers (e.g., Gemini, DeepSeek, Kiro).
- **Switch Model:** Press **`<localLeader>m`** to change models on the fly (e.g., lightweight models for fast edits vs. reasoning models for deep refactoring).

### 3. 🛠️ Specialized Slash Commands
- **Execute Slash Commands:** Type **`/`** inside the chat prompt to view and run slash commands (such as `/plan`, `/goal`, `/learn`, `/browser`) to guide agentic tasks.

### 4. 🔄 Reviewing & Integrating Generated Code
- **Refine & Implement:** Direct the assistant to generate unit tests, explain complex logic, or refactor code blocks, then seamlessly apply suggested diffs back into your workspace buffers.

---

## Daily Multi-Tab Workspace & Navigation Scenario

Here is how a developer manages files across tabs and navigates project structure:

### 1. 🔍 Finding Files & Grepping
- **Fuzzy Find Project Files:** Press **`<leader>pf`** to quickly pick and open files by name.
- **Live Grep Search:** Press **`<leader>pg`** to search code patterns dynamically across the workspace.

### 2. 🗂️ Multi-Tab Context & Buffer Management
- **Open in New Tab from Explorer:** Open file explorer with **`<leader>e`**, navigate to a file, and press **`gt`** to open it in a new tab.
- **Switch Between Tabs:** Use **`H`** (previous tab) and **`L`** (next tab) to cycle through active tabs.
- **Switch Active Buffers:** Press **`<leader>pb`** to list and jump between open buffers in the editor session.

### 3. 💡 Interactive Keymap Clues
- **Keymap Hints (`mini.clue`):** Press `<Leader>` or key prefixes (`g`, `z`, `<C-w>`) and pause briefly to view contextual popup hints and descriptions inline.

---

## Daily Pre-Push Code Quality Audit Scenario

Here is how a developer conducts a full quality pass before committing and pushing code:

### 1. 🛡️ Session Diagnostics Pass
- **Active Session Diagnostics:** Press **`<leader>pd`** to bring up a fuzzy picker of all linting errors (Ruff) and type warnings (`ty`) across all active buffers in your editor session.
- **Inspect Floating Error Details:** Jump to an issue line and press **`<leader>d`** to view full floating diagnostic tracebacks.
- **In-Buffer Diagnostic Jump:** Press **`]d`** or **`[d`** to cycle through warnings and errors directly inside the active buffer.

### 2. ⚡ Code Actions & Refactoring
- **Trigger Quick-Fix Actions:** Press **`<leader>ca`** to run LSP code actions (auto-import missing modules, fix unused imports).
- **Smart Symbol Rename:** Press **`<leader>rn`** on any symbol to rename it safely across the file.
- **Trim Whitespace & Format:** Press **`<leader>tw`** to trim trailing whitespaces, and save (`:w`) to trigger automatic Ruff formatting.

### 3. 🔍 Final Diff Verification
- **Toggle Inline Diff Overlay:** Press **`<leader>td`** to visually highlight modified, added, or deleted lines against `HEAD`.
- **Review Git Status:** Press **`<leader>gs`** to open Git status in a dedicated tab before staging and committing.

---

## Daily GitHub PR Code Review Scenario

Here is how a developer uses the integrated GitHub CLI (`gh`) and `delta` tools to perform code reviews:

### 1. 🔍 PR Discovery & Overview
- **List Open PRs:** Press **`<leader>gpr`** to open a terminal tab displaying all open GitHub Pull Requests.
- **Inspect PR Details:** Press **`<leader>gpv`** to read the active PR description, comments, and review status.

### 2. ⚡ Interactive Checkout & Full PR Diff
- **Interactive Checkout:** Press **`<leader>gpc`** to select and checkout any PR branch interactively.
- **Syntax-Highlighted PR Diff:** Press **`<leader>gpd`** to open the entire PR diff rendered with `delta` side-by-side / inline syntax highlighting in a terminal tab.

### 3. 📜 Deep Context & Line History
- **Line Range History:** Highlight line ranges and press **`<leader>gh`** to inspect previous commit history for target files under review.

---

## Optional: Native Treesitter Syntax Highlighting

Neovim 0.12 has a built-in Treesitter engine, so you do **not** need to install any heavy Treesitter plugins to get high-performance syntax highlighting. However, you do need the compiled language parser (`python.so`) placed in your isolated runtime path.

### How to Compile `python.so` Manually
If you want to try Treesitter highlighting without installing any plugins:

1. **Clone the Python Treesitter grammar repo**:
   ```bash
   git clone --depth 1 https://github.com/tree-sitter/tree-sitter-python.git /tmp/tree-sitter-python
   cd /tmp/tree-sitter-python
   ```

2. **Compile the source files into a shared library**:
   * If `src/scanner.c` is present (using C):
     ```bash
     gcc -O3 -shared -fPIC -I./src src/parser.c src/scanner.c -o python.so
     ```
   * If `src/scanner.cc` is present (using C++):
     ```bash
     g++ -O3 -shared -fPIC -I./src src/parser.c src/scanner.cc -o python.so
     ```

3. **Install the parser into your isolated environment**:
   Create the parser directory inside the workspace and copy the compiled file:
   ```bash
   mkdir -p data/nvim/site/parser
   cp python.so data/nvim/site/parser/
   ```

4. **Uncomment the Treesitter block** inside your [init.lua](file:///home/stephanie/DEV/mini-nvim-setup/config/nvim/init.lua) under **Section 6** and reload Neovim!

