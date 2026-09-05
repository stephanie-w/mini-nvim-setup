# GEMINI.md - Neovim Custom Isolated Config Context

This workspace contains a highly optimized, fully sandboxed, custom **Neovim 0.12** configuration environment. It is designed to be run isolated from the host machine's global configuration, targeting Python and modern web/text workflows with native performance.

---

## 1. Project Overview & Architecture

### Isolated Runtime Directory Structure
All user data, configurations, and cache files are strictly scoped to this workspace:
*   `./nv` : The master Python launcher script. It isolates Neovim by overriding standard XDG environment variables.
*   `./config/` : Houses configuration files (maps to `XDG_CONFIG_HOME`).
    *   `nvim/init.lua` : The primary entry point for Neovim config.
    *   `nvim/lua/options.lua` : Global Neovim options.
    *   `nvim/lua/local_profile.lua` : Local coding assistant profile configs (git-ignored).
    *   `nvim/lsp/ruff.lua` : Native configuration file for the Ruff language server.
    *   `nvim/lsp/ty.lua` : Native configuration file for the ty language server/type checker.
    *   `nvim/colors/` : Directory containing custom colorschemes (`nord.lua`, `solarized-dark.lua`, `deep-teal.lua`).
*   `./data/` : Contains installed plugins and runtime files (maps to `XDG_DATA_HOME`).
    *   `nvim/site/pack/plugins/start/mini.nvim/` : Cloned dependency providing the robust `mini` suite.
    *   `nvim/site/pack/plugins/start/agentic.nvim/` : Cloned ACP coding assistant plugin sidebar.
*   `./state/` : Stores transient state files, logs, and Neovim SHA-DA history (maps to `XDG_STATE_HOME`).
*   `./cache/` : Neovim cache (maps to `XDG_CACHE_HOME`).

### Core Features & Integrations
1.  **Lightweight Plugins (`mini.nvim`):**
    *   **Colors/Theme:** Integrated `colorschemes/` (`nord`, `solarized-dark`, and `deep-teal`) generated via `mini.base16` and a custom `mini.statusline`.
    *   **UX Modules:** Autocompletion popups (`mini.completion`), bracket/quote pairing (`mini.pairs`), and instant comment block toggles (`mini.comment` via `gc`).
    *   **Text Objects:** Rich text objects via `mini.ai` (e.g., selection inside functions or brackets).
    *   **File Tree:** Navigation and tree visualization via `mini.files`.
2.  **Native Language Server Protocol (LSP):**
    *   **Ruff:** Handled natively to provide instant linting, diagnostics, code actions, and hover documentation.
    *   **ty:** Handled natively to provide fast static type-checking and type-based autocomplete.
    *   **Auto-Formatting:** Saves on Python files trigger automatic synchronous Ruff formatting.
    *   **Virtual Environments:** Automatically detects and loads local `.venv` paths (compatible with `uv` virtual environments) to ensure LSP uses the exact local workspace packages.
3.  **Local Git HUD:**
    *   Visual gutters for file changes via `mini.diff`.
    *   Direct interactive commit inspection, navigation, and repository command status feedback with `mini.git`.

---

## 2. Building, Running, and Using the Environment

### Launching Neovim
Do **NOT** run standard `nvim` directly, as it will point to your global/home directory setup. Instead, always use the isolated local runner:
```bash
./nv [arguments] [file_paths...]
```
For example, to edit your main configuration:
```bash
./nv config/nvim/init.lua
```

### Essential Keyboard Shortcuts
*   **Leader Key:** `<Space>`

#### File Explorer (`mini.files`)
*   `<leader>e` : Toggle File Explorer panel.
*   `gt` : Within the explorer, open the selected file in a **new tab** (and automatically close the explorer).

#### Navigation & Layout
*   `H` : Switch to the previous tab (`:tabprevious`).
*   `L` : Switch to the next tab (`:tabnext`).
*   `Ctrl-W` bindings: Standard Neovim split pane navigation.

#### Autocomplete (Insert Mode)
*   `<Tab>` : Select next item when the autocomplete popup is visible.
*   `<S-Tab>` : Select previous item when the autocomplete popup is visible.
*   `<CR>` (Enter) : Accept highlighted suggestion (retains bracket auto-pairing if popup is closed).

#### Fuzzy Pickers (`mini.pick` & `mini.extra`)
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
*   `<leader>pS` : Search and pick Git stashes (with live diff preview).
*   `<leader>ps` : Search and pick LSP document symbols in active buffer.
*   `<leader>pr` : Search and pick LSP references under cursor.

#### Git Operations
*   `]h` / `[h` : Jump to the next / previous modified Git hunk.
*   `<leader>td` : Toggle live inline color-coded diff overlays in active buffer (`mini.diff`).
*   `ghgh` : Stage the Git hunk under cursor to the index (`mini.diff`).
*   `gh` : (Visual mode) Stage visually selected lines or range to the index (`mini.diff`).
*   `gh_` : Stage current line to Git index (`mini.diff`).
*   `gHgh` : Reset / discard Git hunk under cursor (`mini.diff`).
*   `gH` : (Visual mode) Reset / discard visually selected lines (`mini.diff`).
*   `gH_` : Reset / discard current line (`mini.diff`).
*   `:Git add %` : Stage current active file (`mini.git`).
*   `:Git commit` : Open interactive commit message editor split (`mini.git`).
*   `<leader>gl` : Open an interactive, formatted git log in a dedicated Neovim tab.
*   `<leader>gL` : Open interactive commit graph across all branches (`git log --graph --all`).
*   `<leader>gb` : Search, preview, and switch Git branches (`mini.extra`).
*   `<leader>gf` : Open Git log for current active file.
*   `<leader>gs` : Open Git status in a dedicated tab.
*   `<leader>gS` : Open Git stash list in a dedicated tab.
*   `<CR>` *(inside Git log / stash list)* : Show commit or stash diff directly in current window (replaces buffer).
*   `q` / `<BS>` *(inside commit / stash diff)* : Return back to Git log or stash list view.
*   `<leader>gc` : Open a vertical pane to inspect the specific Git commit under your cursor.
*   `<leader>gd` : Open full syntax-highlighted commit or stash diff using **`delta`** in a terminal tab.
*   `<leader>gh` : Open line range evolution history (Normal/Visual selection).
*   `<leader>gpr` : List open GitHub Pull Requests in terminal tab (`gh pr list`).
*   `<leader>gpc` : Interactive GitHub PR checkout in terminal tab (`gh pr checkout`).
*   `<leader>gpv` : View active GitHub PR overview details in terminal tab (`gh pr view`).
*   `<leader>gpd` : View active GitHub PR diff using **`delta`** in terminal tab (`gh pr diff`).

#### Native LSP Navigation & Diagnostics
*   `gd` : Go to definition.
*   `K` : Show documentation hover popup (docstrings, signatures, type hints).
*   `<C-k>` : Show active function signature & arguments popup (Insert/Normal mode).
*   `<leader>ps` : Search and pick LSP document symbols in active buffer.
*   `<leader>pr` : Search and pick LSP references under cursor across workspace.
*   `<leader>rn` : Smart LSP rename across the file.
*   `<leader>ca` : Trigger LSP code actions (auto-import, quick fixes, etc.).
*   `]d` / `[d` : Jump to the next / previous diagnostic issue.
*   `<leader>d` : Show details of the current line diagnostic in a floating window.
*   `<leader>pd` : Search diagnostic errors across active session buffers.
*   `<leader>tw` : Manually trim trailing whitespaces across the current buffer.

#### Python REPL Integration
*   `<leader>rr` : (Normal mode) Send current line to Python terminal REPL.
*   `<leader>rr` : (Visual mode) Send selected block to Python terminal REPL.


#### ACP Coding Assistant (`agentic.nvim`)
*   `<leader>at` : Toggle the Assistant Chat Sidebar.
*   `<leader>aw` : Toggle Assistant Sidebar Width (35% compact vs 65% wide view).
*   `<leader>ac` : Add visual line selection or active file to Chat context.
*   `<leader>ap` : Open Quick Prompt Box to type a prompt (attaches selection/file context automatically).
*   `<leader>as` : **Interrupt & Stop** the agent's current generation / cancel turn.
*   `<C-c>` *(inside Chat)* : Stop current generation immediately.
*   `<S-Tab>` *(inside Chat)* : Switch agent operating mode (e.g., code, ask, architect, plan).
*   `\m` or `<localLeader>m` *(inside Chat)* : Open model switcher modal to select model.
*   `\s` or `<localLeader>s` *(inside Chat)* : Open provider switcher modal (DeepSeek, Kiro, etc.).
*   `\t` or `<localLeader>t` *(inside Chat)* : Switch reasoning / thought effort level.
*   `@` *(inside Chat)* : Add specific file from workspace to context.
*   `/` *(inside Chat)* : Run agent-specific slash commands.
*   `1` / `2` / `3` / `4` *(on pending permission)* : 1=Allow once, 2=Allow always, 3=Reject once, 4=Reject always.
*   `]c` / `[c` *(in Diff Preview)* : Navigate through proposed diff hunks before accepting.

---

## 3. Development Conventions & Workflow Guides

### Lua Style Guide
*   **Formatters:** This project conforms to **StyLua** specifications (e.g., 2-space tab indentations for options/init, clean grouping of setups, standard keyword spaces).
*   **Adding Plugins:** Drop additional plugins into `./data/nvim/site/pack/plugins/start/` to let Neovim automatically pick them up on the next isolated boot.

### Python / Virtual Environments
*   This project is configured to work out-of-the-box with **`uv`** or standard `venv` workflows.
*   Always initialize virtual environments in the root directory as `.venv`:
    ```bash
    uv venv
    # or
    python3 -m venv .venv
    ```
*   The isolated Neovim configuration detects `.venv` automatically and adjusts your Python environment and linter search paths seamlessly.
