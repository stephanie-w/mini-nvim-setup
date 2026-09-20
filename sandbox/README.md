# 🧪 Neovim Interactive Developer Sandbox

This directory provides a safe, realistic playground to test and master both **Git workflows** and **LSP intelligence** without touching any production code.

---

## 🚀 Quick Start

1. **Populate the sandbox with live Git hunks & LSP test cases:**
   ```bash
   python3 sandbox/reset_sandbox.py
   ```

2. **Open the test file in isolated Neovim:**
   ```bash
   ./nv sandbox/playground/service.py
   ```

3. **Reset back to clean state at any time:**
   ```bash
   python3 sandbox/reset_sandbox.py --clean
   ```

---

## 🎯 What You Can Practice

### 1. 🌿 Git Workflows & Gutter Diffs
* **Navigate Hunks:** Press **`]h`** (next hunk) and **`[h`** (previous hunk).
* **Inline Diff Overlay:** Press **`<leader>td`** to toggle full line-by-line colored diff overlays directly inside your buffer.
* **Hunk Staging:** Press **`ghgh`** to stage only the hunk under your cursor into the Git index.
* **Line Staging:** Press **`gh_`** (or select lines in visual mode and press **`gh`**) to stage individual lines.
* **Discard Changes:** Press **`gHgh`** to discard the hunk under cursor, or **`gH_`** / **`gH`** (visual) to discard lines.
* **Git Status:** Press **`<leader>gs`** to open `:tab Git status` in a dedicated tab.
* **Commit:** Type **`:Git commit`** to open the interactive commit message editor.
* **Delta Full Diff:** Press **`<leader>gd`** to view all working tree diffs in a syntax-highlighted **Delta** terminal tab.
* **Inspect Commits & Graphs:** Press **`<leader>gl`** (one-line log) or **`<leader>gL`** (branch graph), then hit **`<CR>`** on any commit line to preview its diff in-place, or **`<leader>gc`** to open a split inspection panel.

### 2. ⚡ LSP Diagnostics, Code Actions & Navigation
* **Navigate Diagnostics:** Press **`]d`** and **`[d`** to cycle between Ruff and `ty` issues (auto-opens the diagnostic float).
* **Line Diagnostic Details:** Press **`<leader>d`** on lines with unused imports (`os`, `math`, `sys`) to see rule details (e.g. `ruff: F401`).
* **Auto-Fix Code Action:** Place your cursor on an unused import or lint error and press **`<leader>ca`** to execute Ruff's automatic quick-fix.
* **Documentation Hover:** Place your cursor over `PaymentGateway` or `OrderProcessor` and press **`K`** to inspect the docstring and typing.
* **Signature Help:** Inside any function call arguments (e.g. `process_order(`), press **`<C-k>`** to view active parameter signatures.
* **Go to Definition:** Open `sandbox/playground/client.py` and press **`gd`** over `PaymentGateway` to jump straight to its definition in `sandbox/playground/service.py`.
* **LSP Symbols & References:** Press **`<leader>ps`** to fuzzy-search document symbols in the file, and **`<leader>pr`** to find all cross-file references of a function or class.
* **Smart Rename:** Place your cursor on `process_order` and press **`<leader>rn`** to rename the symbol across both `service.py` and `client.py` simultaneously.
* **Format-on-Save:** Make any formatting mess and simply press **`:w`** — Ruff autoformats the code instantly.

---

## 📂 Sandbox Structure Overview

| Location | Purpose |
| :--- | :--- |
| **`sandbox/playground/`** | Isolated Git repository (`.git`) created automatically by `reset_sandbox.py` (git-ignored from main repo). |
| **`sandbox/playground/service.py`** | E-commerce order processing module containing intentional lint issues, type checks, docstrings, and 4 live git hunks. |
| **`sandbox/playground/client.py`** | Consumer script for testing cross-file `gd`, `<leader>pr` references, `<leader>rn` rename, and `<leader>rr` REPL. |
| **`sandbox/reset_sandbox.py`** | Generator & reset script to initialize the isolated git repo with commits, branches, stashes, and hunks. |
