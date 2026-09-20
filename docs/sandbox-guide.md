# 🧪 Hands-on Sandbox Practice Walkthrough

This interactive walkthrough guides you step-by-step through practicing **Git workflows** and **LSP intelligence** in the isolated sandbox.

---

## 🛠️ Step 0: Initialize the Sandbox

From your terminal, run the sandbox generator:
```bash
python3 sandbox/reset_sandbox.py
```

This populates `sandbox/playground/service.py` with:
- 4 realistic uncommitted Git hunks
- Unused imports (Ruff `F401`)
- Type-checked functions and classes
- Documentation and docstrings

Now launch the isolated Neovim environment:
```bash
./nv sandbox/playground/service.py
```

---

## 🌿 Part 1: Git Workflow Practice Scenario

### Step 1.1: Gutter Inspection & Navigation
1. Notice the gutter indicators (`┃`) on the left side of your buffer.
2. Press **`]h`** repeatedly to jump smoothly through each modified hunk in the file.
3. Once you reach the end of the file, notice that **`]h` wraps around** back to the first hunk and notifies `(mini.diff) Wrapped around edge in direction "next"`.
4. Press **`[h`** to jump backward (and wrap back to the bottom).

### Step 1.2: Inline Diff Overlay
1. Place your cursor inside the `PaymentGateway.authorize` method.
2. Press **`<leader>td`**.
3. **Observation:** Neovim displays inline color-coded diff overlays highlighting the new timestamp line and modifications.
4. Press **`<leader>td`** again to toggle the overlay off.

### Step 1.3: Full Delta Terminal Diff
1. Press **`<leader>gd`**.
2. **Observation:** Neovim opens a dedicated tab running **`delta`**, showing syntax-highlighted side-by-side diffs of your uncommitted changes.
3. Press **`q`** to close the Delta tab and return to `sandbox/playground/service.py`.

### Step 1.4: Granular Hunk Staging (`<leader>ga` or `ghgh`)
1. Jump to Hunk 3 (`def refund(...)`) using **`]h`**.
2. Press **`<leader>ga`** (or type `ghgh` without leader) in Normal mode.
3. **Observation:** The gutter sign disappears for that hunk. It is now staged into the Git index!

### Step 1.5: Discarding an Unwanted Change (`<leader>gX` or `gHgh`)
1. Jump to Hunk 1 (the `import os` line) using **`[h`**.
2. Press **`<leader>gX`** (or type `gHgh` without leader) in Normal mode.
3. **Observation:** The `import os` line is immediately discarded back to HEAD!

### Step 1.6: Review Staging & Commit
1. Press **`<leader>gs`** to open `:tab Git status`.
2. Notice `sandbox/playground/service.py` has both staged and unstaged changes.
3. Type **`:Git commit`** and press Enter.
4. In the `COMMIT_EDITMSG` buffer, enter:
   ```
   feat(sandbox): add refund method to PaymentGateway
   ```
5. Save and close with **`:wq`**.
6. Switch back to your code tab with **`H`**.

### Step 1.7: History & Diff Exploration
1. Press **`<leader>gl`** to open the one-line Git log in a new tab.
2. Move your cursor over your newest commit and press **`<CR>`** (Enter).
3. **Observation:** The window immediately shows the full `git show` commit diff.
4. Press **`q`** to return to the log list.
5. Move cursor to any commit and press **`<leader>gd`** to view it formatted with **`delta`**.
6. Press **`q`** to exit delta, then close the tab with **`:tabclose`**.

---

## ⚡ Part 2: LSP & Code Intelligence Practice Scenario

### Step 2.1: Navigating Diagnostics
1. In `sandbox/playground/service.py`, press **`]d`**.
2. **Observation:** Neovim jumps to the next diagnostic line and automatically opens a floating window displaying:
   `[ruff] `math` imported but unused [F401]`
3. Press **`]d`** again to jump to the `sys` unused import.
4. Press **`[d`** to navigate backward.

### Step 2.2: Line Inspection & Code Action Autofix
1. With your cursor on `import math`, press **`<leader>d`** to inspect the full diagnostic float.
2. Press **`<leader>ca`** (Code Action).
3. Select `Ruff: Remove unused import 'math'` and press **`<CR>`**.
4. **Observation:** The unused import is automatically removed cleanly! Repeat for `import sys`.

### Step 2.3: Hover Docs & Signatures
1. Move your cursor over the word `PaymentGateway` and press **`K`**.
2. **Observation:** A clean Markdown popup displays the docstring and class documentation.
3. Press **`K`** or **`<Esc>`** to close the popup.
4. In `process_order`, place your cursor inside `self.calculate_discount(|)` and press **`<C-k>`**.
5. **Observation:** A signature popup appears with parameters `(total: float, rate: float) -> float`.

### Step 2.4: Cross-File Definition & References
1. Open `sandbox/playground/client.py` using the file picker (**`<leader>pf`**, type `client.py`, press `<CR>`).
2. Move your cursor over `OrderProcessor` and press **`gd`**.
3. **Observation:** Neovim instantly jumps to `sandbox/playground/service.py` at the class declaration.
4. Press **`<C-o>`** to jump back to `sandbox/playground/client.py`.
5. Place your cursor on `process_order` and press **`<leader>pr`**.
6. **Observation:** A picker opens showing all occurrences in both `service.py` and `client.py`.

### Step 2.5: Smart Rename Across Files
1. In `sandbox/playground/client.py`, place your cursor on `process_order`.
2. Press **`<leader>rn`**.
3. Type `submit_order` and press **`<CR>`**.
4. **Observation:** The method is renamed across both `client.py` and `service.py` simultaneously!

### Step 2.6: Format-on-Save
1. In `sandbox/playground/service.py`, introduce random messy spacing or unformatted lines.
2. Press **`:w`**.
3. **Observation:** Ruff immediately auto-formats the file into clean PEP 8 standard code upon saving!

---

## 🔄 Resetting the Sandbox

Whenever you want to practice again from scratch:
```bash
python3 sandbox/reset_sandbox.py
```
Or reset cleanly without any diffs:
```bash
python3 sandbox/reset_sandbox.py --clean
```
