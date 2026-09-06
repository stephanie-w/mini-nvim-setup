# ⌨️ Neovim Keymaps & Shortcuts Cheatsheet

> **Leader Key:** `<Space>` &nbsp;|&nbsp; **LocalLeader Key:** `\`

---

## 📑 Quick Navigation Table

| Section | Prefix / Scope | Description |
| :--- | :--- | :--- |
| [1. Navigation & Tabs](#1-navigation--tabs) | `H`, `L`, `gt`, `<C-w>` | Tab cycling and window navigation |
| [2. LSP & Diagnostics](#2-lsp-code-intelligence--diagnostics) | `<leader>d`, `gd`, `K`, `<C-k>`, `]d`/`[d` | Hover, signatures, code actions & errors |
| [3. Autocomplete & Insert Mode](#3-autocomplete--insert-mode) | `<Tab>`, `<S-Tab>`, `<CR>` | Popup navigation and bracket pairing |
| [4. Fuzzy Pickers (`mini.pick`)](#4-fuzzy-pickers-minipick) | `<leader>p...` | Files, live grep, buffers, symbols |
| [5. Git Operations & Gutter Diffs](#5-git-operations--gutter-diffs) | `<leader>g...`, `gh`, `gH`, `]h`/`[h` | Hunk staging, commits, log graphs |
| [6. GitHub PR Integration](#6-github-cli-gh--pr-integration) | `<leader>gp...` | PR listings, diffs, interactive checkout |
| [7. Pi AI Coding Assistant](#7-pi-ai-coding-assistant) | `<leader>ap`, `<leader>at`, `<leader>as` | Fast prompt/edit, chat sidebar, task cancellation |
| [8. Agentic Fallback (`agentic.nvim`)](#8-agentic-fallback-agenticnvim) | `<leader>aa`, `:Agentic` | ACP sidebar fallback (DeepSeek, Kiro, Gemini) |
| [9. Python Interactive REPL](#9-python-interactive-repl) | `<leader>rr` | Send lines or selections to IPython |
| [10. Live Keymap Discovery in Editor](#10-live-keymap-discovery-in-editor) | `<leader>pka`, `<leader>pk*` | Search all active keymaps on the fly |

---

## 1. Navigation & Tabs

| Keymap | Mode | Action |
| :--- | :--- | :--- |
| **`H`** | Normal | Switch to the **previous tab** (`:tabprevious`) |
| **`L`** | Normal | Switch to the **next tab** (`:tabnext`) |
| **`<leader>e`** | Normal | Toggle File Explorer panel (`mini.files`) |
| **`gt`** | Normal *(inside explorer)* | Open selected file in a **new tab** and close explorer |
| **`<C-w>h / j / k / l`** | Normal | Move cursor to split Left / Down / Up / Right |
| **`<C-w>v` / `<C-w>s`** | Normal | Split window vertically / horizontally |

---

## 2. LSP, Code Intelligence & Diagnostics

| Keymap | Mode | Action |
| :--- | :--- | :--- |
| **`K`** | Normal | Show documentation & type annotations hover popup |
| **`<C-k>`** | Insert / Normal | Show active function signature & parameter popup |
| **`gd`** | Normal | Go to definition of symbol under cursor |
| **`<leader>rn`** | Normal | Smart LSP rename symbol across file |
| **`<leader>ca`** | Normal | Trigger LSP code actions (auto-import, quick fixes) |
| **`<leader>d`** | Normal | Show full floating diagnostic details (error code, message) |
| **`]d`** | Normal | Jump to **next** diagnostic (auto-opens full message float) |
| **`[d`** | Normal | Jump to **previous** diagnostic (auto-opens full message float) |
| **`<leader>pd`** | Normal | Search and pick diagnostics across active session |
| **`<leader>ps`** | Normal | Search & pick document symbols (classes, methods, functions) |
| **`<leader>pr`** | Normal | Search & pick references across the project |
| **`<leader>tw`** | Normal | Manually trim trailing whitespace across current buffer |

---

## 3. Autocomplete & Insert Mode

| Keymap | Mode | Action |
| :--- | :--- | :--- |
| **`<Tab>`** | Insert | Select next item in autocomplete popup |
| **`<S-Tab>`** | Insert | Select previous item in autocomplete popup |
| **`<CR>`** (Enter) | Insert | Accept selected completion (or handle bracket pairing) |
| **`gc`** | Normal / Visual | Toggle comment on line or visual selection (`mini.comment`) |

---

## 4. Fuzzy Pickers (`mini.pick`)

| Keymap | Action |
| :--- | :--- |
| **`<leader>pf`** | Fuzzy find project files |
| **`<leader>pg`** | Live grep text search across project (`ripgrep`) |
| **`<leader>pb`** | List and switch open buffers |
| **`<leader>ph`** | Search Neovim help tags |
| **`<leader>pd`** | Search workspace diagnostics (Ruff & `ty`) |
| **`<leader>ps`** | Search LSP document symbols |
| **`<leader>pr`** | Search LSP references |
| **`<leader>pc`** | Search and inspect Git commits |
| **`<leader>pS`** | Search Git stashes with live diff preview |
| **`<leader>gb`** | Search, preview, and switch Git branches |

---

## 5. Git Operations & Gutter Diffs

| Keymap | Mode | Action |
| :--- | :--- | :--- |
| **`]h`** | Normal | Jump to next modified Git hunk (`mini.diff`) |
| **`[h`** | Normal | Jump to previous modified Git hunk (`mini.diff`) |
| **`<leader>td`** | Normal | Toggle inline color-coded diff overlays |
| **`ghgh`** | Normal | **Stage hunk** under cursor to Git index |
| **`gh`** | Visual | **Stage visually selected lines** to Git index |
| **`gh_`** | Normal | **Stage current line** to Git index |
| **`gHgh`** | Normal | **Reset / discard hunk** under cursor |
| **`gH`** | Visual | **Reset / discard visually selected lines** |
| **`gH_`** | Normal | **Reset / discard current line** |
| **`<leader>gs`** | Normal | Open Git status in dedicated tab |
| **`<leader>gl`** | Normal | Open Git log in dedicated tab |
| **`<leader>gL`** | Normal | Open Git log commit graph across all branches |
| **`<leader>gf`** | Normal | Open Git log for current active file |
| **`<leader>gS`** | Normal | Open Git stash list in dedicated tab |
| **`<CR>`** | Normal *(inside log/stash)* | Show commit or stash diff in-place |
| **`q` / `<BS>`** | Normal *(inside diff)* | Close diff and return to log or stash list |
| **`<leader>gc`** | Normal | Inspect commit under cursor in right vertical split |
| **`<leader>gd`** | Normal | Show commit / stash diff with **`delta`** in terminal tab |
| **`<leader>gh`** | Normal / Visual | Show line range evolution history |

---

## 6. GitHub CLI (`gh`) & PR Integration

| Keymap | Mode | Action |
| :--- | :--- | :--- |
| **`<leader>gpr`** | Normal | List open GitHub Pull Requests in terminal tab |
| **`<leader>gpc`** | Normal | Interactive GitHub PR checkout |
| **`<leader>gpv`** | Normal | View active GitHub PR overview details |
| **`<leader>gpd`** | Normal | View active GitHub PR diff using **`delta`** |

---

## 7. Pi AI Coding Assistant

| Keymap | Mode | Action |
| :--- | :--- | :--- |
| **`<leader>ap`** | Normal | **Prompt Pi** on active file (auto-detects questions vs edits) |
| **`<leader>ap`** | Visual | **Prompt Pi** targeting selected line range |
| **`<leader>at`** | Normal / Visual | **Toggle Pi Chat Panel** (opens/hides persistent sidebar split) |
| **`<leader>as`** | Normal | **Stop / Cancel** active background Pi generation |
| **`q`** | Normal *(inside chat)* | Hide Pi chat panel (preserves session history) |
| **`q` / `<Esc>`** | Normal *(in popup)* | Close read-only floating answer popup |

---

## 8. Agentic Fallback (`agentic.nvim`)

| Keymap / Command | Mode | Action |
| :--- | :--- | :--- |
| **`<leader>aa`** | Normal / Visual | Toggle `agentic.nvim` ACP sidebar (fallback) |
| **`:Agentic`** | Command | Toggle `agentic.nvim` sidebar |
| **`:AgenticToggle`** | Command | Toggle `agentic.nvim` sidebar |

---

## 9. Python Interactive REPL

| Keymap | Mode | Action |
| :--- | :--- | :--- |
| **`<leader>rr`** | Normal | Send current line to IPython terminal split |
| **`<leader>rr`** | Visual | Send highlighted code block to IPython terminal split |

---

## 10. Live Keymap Discovery in Editor

If you ever forget a keybinding while inside Neovim:

* **`<leader>pka`** : Open interactive fuzzy search for **all keymaps** with descriptions.
* **`mini.clue`** : Press `<Space>` (Leader) or `g`, `z`, `<C-w>` and pause for 0.5s to see an interactive popup menu of available following keys.
