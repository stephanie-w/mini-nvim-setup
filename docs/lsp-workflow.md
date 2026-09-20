# ⚡ Daily LSP & Code Intelligence Workflow Guide

This guide details how to leverage native **Language Server Protocol (LSP)** in Neovim for ultra-fast diagnostics, type checking, code navigation, instant auto-fixes, and refactoring.

---

## 🏗️ Architecture: The Dual-Engine Setup

Your environment runs two complementary language servers simultaneously:

```
                  ┌─────────────────────────────────────────┐
                  │               Neovim 0.12               │
                  └────────────┬──────────────┬─────────────┘
                               │              │
              ┌────────────────▼──┐        ┌──▼────────────────┐
              │    Ruff Server    │        │     ty Server     │
              ├───────────────────┤        ├───────────────────┤
              │ • Instant Linting │        │ • Static Typing   │
              │ • Auto-formatting │        │ • Type Autocomp.  │
              │ • Code Actions    │        │ • Signature Hints │
              │ • Docstring/Hover │        │ • Cross-file 'gd' │
              └───────────────────┘        └───────────────────┘
```

Both servers run asynchronously with zero lag, displaying diagnostics with explicit source tags (`ruff: ...` or `ty: ...`).

---

## 1. 🚨 Diagnostics HUD & Navigation

Diagnostics update live as you type (`update_in_insert = true`).

### Quick Jumps Between Issues
* **`]d`** : Jump to the **next** diagnostic error or warning. Neovim automatically opens a floating window showing the exact error code, message, and server source.
* **`[d`** : Jump to the **previous** diagnostic error or warning.

### Inspecting Line Diagnostics (`<leader>d`)
* Place cursor on any highlighted line and press **`<leader>d`**.
* A floating popup opens displaying full diagnostic details (including linter rule IDs like `F401`, `E501`, or `ty` type mismatches).

### Workspace Diagnostics Picker (`<leader>pd`)
* Press **`<leader>pd`** to launch the fuzzy-picker listing all diagnostic issues across your active session.
* Filter diagnostics in real-time by typing keywords (e.g. `unused`, `type`, filename).
* Press **`<CR>`** to jump straight to the issue.

---

## 2. 💡 Instant Auto-Fixes & Code Actions (`<leader>ca`)

When Ruff flags an issue (e.g. unused imports, unformatted expressions, missing `__all__`, import sorting):

1. Position your cursor on the line with the diagnostic.
2. Press **`<leader>ca`** (Code Action).
3. A menu opens with available automated fixes (e.g. `Ruff: Remove unused import 'math'`).
4. Select the action by number or press **`<CR>`** to execute it instantly.

---

## 3. 🔎 Code Comprehension & Exploration

### Documentation Hover (`K`)
* Place your cursor on any function, class, method, or standard library module and press **`K`**.
* A clean floating Markdown popup renders:
  - Full docstrings and descriptions.
  - Parameter signatures and return types.
  - Type annotations inferred by `ty`.
* Press **`K`** (or **`q`** / **`<Esc>`**) to dismiss the popup.

### Parameter Signature Help (`<C-k>`)
* While writing or reviewing function calls (e.g. `processor.process_order(|)`), press **`<C-k>`** in Insert or Normal mode.
* Neovim displays a signature popup highlighting the **active argument** you are currently filling out.

### Go to Definition (`gd`)
* Place cursor on any class name, function, variable, or imported module and press **`gd`**.
* Jumps instantly to the source declaration (even across multiple files or installed virtual environment packages).
* Use standard **`<C-o>`** to jump back to your previous cursor location.

### Document Symbols Picker (`<leader>ps`)
* Press **`<leader>ps`** to open the fuzzy symbol picker.
* View and filter all classes, methods, functions, and variables declared within the current file.

### Cross-File References (`<leader>pr`)
* Place cursor on any symbol (e.g. `process_order`) and press **`<leader>pr`**.
* A picker lists every location across your entire workspace where that symbol is referenced, called, or imported.
* Press **`<CR>`** to jump to any reference.

---

## 4. 🔄 Smart Renaming & Refactoring (`<leader>rn`)

Avoid error-prone find-and-replace across your codebase:

1. Place your cursor on any variable, function, or class name.
2. Press **`<leader>rn`**.
3. A prompt appears: `New Name:`.
4. Type the new identifier (e.g. `execute_order`) and press **`<CR>`**.
5. The LSP automatically renames all references and imports across all open buffers cleanly.

---

## 5. 🧹 Instant Formatting & Whitespace Trimming

### Format on Save (`:w`)
* Every time you save a Python file (**`:w`** or **`:x`**), Neovim synchronously invokes Ruff's ultra-fast native formatter.
* Code is immediately formatted according to PEP 8 / project rules without any latency.

### Manual Trailing Whitespace Trim (`<leader>tw`)
* `mini.trailspace` highlights stray trailing spaces in red.
* Press **`<leader>tw`** to trim all trailing spaces across the current buffer in one stroke.

---

## 6. 🐍 Interactive Python REPL (`<leader>rr`)

Need to test a snippet of code interactively without leaving Neovim?

* **Send Current Line:** In Normal mode, press **`<leader>rr`** on any line to launch or send it to an IPython / Python terminal split.
* **Send Highlighted Block:** Select multiple lines in Visual mode (`V`) and press **`<leader>rr`** to execute the entire block in the REPL.

---

## ⚡ Quick Reference Cheatsheet

| Keymap | Mode | Action |
| :--- | :--- | :--- |
| **`]d` / `[d`** | Normal | Next / Previous diagnostic (opens float) |
| **`<leader>d`** | Normal | Show floating line diagnostic details |
| **`<leader>pd`** | Normal | Fuzzy pick workspace diagnostics |
| **`<leader>ca`** | Normal | Trigger LSP Code Actions (autofix) |
| **`K`** | Normal | Show documentation & type annotations |
| **`<C-k>`** | Insert / Normal | Show active parameter signature help |
| **`gd`** | Normal | Go to definition |
| **`<C-o>`** | Normal | Jump back after `gd` |
| **`<leader>ps`** | Normal | Search & pick document symbols |
| **`<leader>pr`** | Normal | Search & pick workspace references |
| **`<leader>rn`** | Normal | Smart rename symbol across workspace |
| **`:w`** | Command | Auto-format Python buffer via Ruff |
| **`<leader>tw`** | Normal | Trim trailing whitespace |
| **`<leader>rr`** | Normal / Visual | Send line or selection to Python REPL |
