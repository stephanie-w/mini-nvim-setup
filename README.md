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

## Key Keyboard Shortcuts

*   **Leader Key**: `<Space>`

### Navigation & Layout
*   `<leader>e` : Toggle File Explorer panel (`mini.files`).
*   `gt` : (Within explorer) Open selected file in a **new tab** (and close explorer).
*   `H` : Switch to the previous tab.
*   `L` : Switch to the next tab.

### Autocomplete (Insert Mode)
*   `<Tab>` : Select next item when the autocomplete popup is visible.
*   `<S-Tab>` : Select previous item when the autocomplete popup is visible.
*   `<CR>` (Enter) : Accept the highlighted autocomplete suggestion (retains brackets auto-pairing if popup is closed).

### Fuzzy Pickers (`mini.pick` & `mini.extra`)
*   `<leader>pf` : Search files in project.
*   `<leader>pg` : Search query using live grep (requires `ripgrep`).
*   `<leader>pb` : List active buffers.
*   `<leader>ph` : Search help tags.
*   `<leader>pd` : List and search workspace diagnostics.
*   `<leader>pka` : List and search all active keymaps.
*   `<leader>pkl` : List and search LSP keymaps.
*   `<leader>pkg` : List and search Git keymaps.
*   `<leader>pkp` : List and search picker keymaps.
*   `<leader>pc` : Search and pick Git commits.
*   `<leader>ps` : Search and pick LSP document symbols in active buffer.
*   `<leader>pr` : Search and pick LSP references under cursor.

### LSP (Language Server Protocol) & Diagnostics
*   `gd` : Go to definition.
*   `K` : Show hover documentation.
*   `<leader>rn` : Smart LSP rename.
*   `<leader>ca` : Trigger LSP code actions (quick-fixes, auto-imports).
*   `]d` / `[d` : Jump to the next / previous diagnostic issue.
*   `<leader>d` : Show details of the current line diagnostic in a floating window.
*   `<leader>tw` : Manually trim trailing whitespaces.

### Python REPL Integration
*   `<leader>rr` : (Normal mode) Send current line to Python terminal REPL.
*   `<leader>rr` : (Visual mode) Send selected block to Python terminal REPL.


### Git Integration & Diff Tools
*   `]h` / `[h` : Jump to the next / previous modified Git hunk (`mini.diff`).
*   `<leader>td` : Toggle live inline color-coded diff overlays in active buffer (`mini.diff`).
*   `<leader>gb` : Search, preview, and switch Git branches (`mini.extra`).
*   `<leader>gL` : Open interactive commit graph across **all branches** (`git log --graph --all`).
*   `<leader>gl` : Open repository Git log in a dedicated tab.
*   `<leader>gf` : Open Git log for current active file.
*   `<leader>gs` : Open Git status in a dedicated tab.
*   `<leader>gc` : Open vertical pane to inspect commit under cursor.
*   `<leader>gd` : Open full syntax-highlighted commit diff using **`delta`** in a terminal tab.
*   `<leader>gh` : Open line range evolution history (Normal/Visual selection).

### ACP Coding Assistant (`agentic.nvim`)
*   `<leader>at` : Toggle the Assistant Chat Sidebar.
*   `<leader>ac` : Add visual selection or active file to Agentic chat context.
*   `<leader>ap` : Open Quick Prompt Box to type a prompt (attaches selection/file context automatically).
*   `\m` or `<localLeader>m` (inside Chat) : Open model switcher modal to select model.
*   `\s` or `<localLeader>s` (inside Chat) : Open provider switcher modal (DeepSeek, Kiro, etc.).
*   `\t` or `<localLeader>t` (inside Chat) : Switch reasoning / thought effort level.
*   `@` (inside Chat) : Add specific file from workspace to context.
*   `/` (inside Chat) : Run agent-specific slash commands.

---

## Daily Developer Git Workflow Scenario

Here is how a developer uses these integrated tools during a typical workday:

### 1. ☕ Morning Context & Branch Switching
- **View Full Repository Tree:** Press `<leader>gL` to open the graph log across all branches in a new tab. Press `<CR>` on any commit line to inspect its diff in-place, and `q` or `<BS>` to close the diff and return to the log.
- **Switch Branches:** Press `<leader>gb` to fuzzy pick and switch local or remote branches.

### 2. 🔍 Investigating History & Debugging
- **Line-by-Line Evolution History:** Select lines in Visual mode (or place cursor on a line) and press `<leader>gh` to see who changed those specific lines and why.
- **Fuzzy Search Commits:** Press `<leader>pc` to fuzzy search commit messages with live diff previews.
- **Current File History:** Press `<leader>gf` to view commits that modified your active file.

### 3. ✍️ Active Coding & Live Diff Tracking
- **Live Inline Diff Overlay:** Press `<leader>td` to toggle colored inline diff highlights directly inside your code buffer (`+` green, `-` red).
- **Hunk Navigation:** Press `]h` or `[h` to jump directly to next or previous modified hunks.

### 4. 📦 Review & Interactive Patch Staging
- **Status Panel:** Press `<leader>gs` to open your workspace status panel.
- **Interactive Patch Add:** Run `:Git add -p` inside Neovim to interactively stage hunks in a split buffer.

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
- **Workspace Error Overview:** Press **`<leader>pd`** to open a fuzzy picker listing all linting and type errors across the entire project.

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
   mkdir -p /home/stephanie/DEV/nvim-setup/data/nvim/parser
   cp python.so /home/stephanie/DEV/nvim-setup/data/nvim/parser/
   ```

4. **Uncomment the Treesitter block** inside your [init.lua](file:///home/stephanie/DEV/nvim-setup/config/nvim/init.lua) under **Section 6** and reload Neovim!

