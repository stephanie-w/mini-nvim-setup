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


### Git Integration
*   `]h` / `[h` : Jump to the next / previous modified Git hunk.
*   `<leader>gl` : Open interactive Git log in a dedicated tab.
*   `<leader>gs` : Open Git status in a dedicated tab.
*   `<leader>gc` : Inspect the Git commit details for the line under your cursor.
*   `<leader>gh` : Open line range evolution history (Normal/Visual selection).

### ACP Coding Assistant (`agentic.nvim`)
*   `<leader>at` : Toggle the Assistant Chat Sidebar.
*   `<localLeader>s` (inside Chat) : Switch active ACP assistant provider (e.g. Gemini, DeepSeek, Kiro).
*   `<localLeader>m` (inside Chat) : Switch model for active provider.
*   `@` (inside Chat) : Add specific file from workspace to context.
*   `/` (inside Chat) : Run agent-specific slash commands.

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

