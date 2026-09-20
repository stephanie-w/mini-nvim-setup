# 🌿 Daily Git Workflow & Code Review Guide

This guide walks through an end-to-end, frictionless daily Git workflow entirely from within Neovim. No switching back and forth between external terminal windows or GUI clients required.

---

## 🧭 The Daily Git Development Cycle

```
 ┌─────────────────────────────────────────────────────────────┐
 │ 1. Review & Navigate Changes (]h, [h, <leader>td, <leader>gd)│
 └──────────────────────────────┬──────────────────────────────┘
                                │
 ┌──────────────────────────────▼──────────────────────────────┐
 │ 2. Granular Staging & Discarding (ghgh, gh, gHgh, gH)        │
 └──────────────────────────────┬──────────────────────────────┘
                                │
 ┌──────────────────────────────▼──────────────────────────────┐
 │ 3. Staging Review & Committing (<leader>gs, :Git commit)     │
 └──────────────────────────────┬──────────────────────────────┘
                                │
 ┌──────────────────────────────▼──────────────────────────────┐
 │ 4. History, Diff & Branch Auditing (<leader>gl, <leader>gd)  │
 └─────────────────────────────────────────────────────────────┘
```

---

## 1. 🔍 Reviewing & Navigating Code Changes

When you edit files, Neovim tracks your changes in real-time against the Git index via `mini.diff`.

### Visual Gutters
* **`┃` (Green tint):** Added lines.
* **`┃` (Blue tint):** Modified lines.
* **`━` (Red tint):** Deleted lines.

### Navigation Shortcuts (Automatic Wrap-Around)
* **`]h`** : Jump to the **next** modified Git hunk (automatically wraps around edges and notifies `Wrapped around edge in direction "next"`).
* **`[h`** : Jump to the **previous** modified Git hunk.
* **`[H`** : Jump to the **first** modified hunk in the file.
* **`]H`** : Jump to the **last** modified hunk in the file.

### Inline Diff Overlays (`<leader>td`)
Want to see exact deleted or replaced text without opening a split?
* Press **`<leader>td`** to toggle inline color-coded diff overlays.
* Deleted and altered words appear highlighted directly above the current lines.
* Press **`<leader>td`** again to toggle back to standard editing mode.

### Full Working Tree Diff with Delta (`<leader>gd`)
* Press **`<leader>gd`** inside any code buffer.
* Neovim opens a dedicated terminal tab running **`delta`** (`git diff HEAD | delta --paging=always`) with syntax-highlighted side-by-side or line diffs.
* Press **`q`** to close Delta and return to your code.

---

## 2. ✂️ Granular Hunk, Line, and Selection Staging

You don't need to stage entire files. Stage only what belongs in your next logical commit:

### Fast Leader Shortcuts (Recommended)
* **`<leader>ga`** : **Stage the hunk under your cursor** into the Git index (`Git Add`). In Visual mode, stages selected lines.
* **`<leader>gX`** : **Discard/reset the hunk under cursor** back to HEAD. In Visual mode, discards selected lines.

### Native `mini.diff` Operator Shortcuts (No Leader)
| Action | Shortcut | Mode | Description |
| :--- | :--- | :--- | :--- |
| **Stage Hunk** | **`ghgh`** | Normal | Stage the entire Git hunk under your cursor into the index (*Note: type `ghgh` without `<Space>`*). |
| **Stage Current Line** | **`gh_`** | Normal | Stage only the active single line. |
| **Stage Selection** | **`gh`** | Visual | Highlight lines in visual mode (`V`), then press `gh` to stage only those lines. |
| **Discard Hunk** | **`gHgh`** | Normal | Revert/discard the hunk under your cursor back to HEAD. |
| **Discard Current Line** | **`gH_`** | Normal | Revert/discard the active line. |
| **Discard Selection** | **`gH`** | Visual | Revert/discard highlighted lines. |
| **Hunk Text Object** | **`vgh`** / **`dgh`** | Normal | Select or delete the entire hunk text object. |

> [!NOTE]
> **Difference between `ghgh` and `<leader>gh`:**
> * **`ghgh`** (direct `g`, no space): `mini.diff` operator to **stage hunks**.
> * **`<leader>gh`** (`<Space>gh`): `mini.git` viewer for **historical line evolution**. This command queries `git log -L` on committed lines and expects your buffer to be committed or stashed.

---

## 3. 📝 Staging Status & Committing

### Check Status (`<leader>gs`)
* Press **`<leader>gs`** to open **`:tab Git status`** in a dedicated tab.
* See your staged changes, unstaged modifications, and untracked files in a clean Neovim buffer.
* Press **`H`** / **`L`** to cycle between your working tab and the status tab.

### Stage or Unstage Whole Files
* **`:Git add %`** : Stage the active file.
* **`:Git reset %`** : Unstage the active file.

### Make an Interactive Commit (`:Git commit`)
* Type **`:Git commit`** and press Enter.
* Neovim opens a split buffer with `COMMIT_EDITMSG`.
* Type your commit title and body (e.g. `feat: add refund payment processing`).
* Save and close (**`:wq`** or **`ZZ`**) to finalize and record the commit.

---

## 4. 📜 Inspecting History, Graphs & Diffs

### Git Log Views
* **`<leader>gl`** : Open a dedicated tab with a clean one-line Git log (`Git log --oneline`).
* **`<leader>gL`** : Open a dedicated tab with a full branch commit graph (`Git log --graph --oneline --decorate --all`).
* **`<leader>gf`** : Open Git log filtered exclusively for the **current active file**.
* **`<leader>pc`** : Open an interactive fuzzy-finder picker to search commits by message or author (`mini.pick`).

### Interactive Commit Inspection (Zero-Friction Diffing)
Inside any Git log buffer (`<leader>gl` or `<leader>gL`):
1. **In-place Diff Preview:** Move your cursor to any commit line and press **`<CR>`** (Enter). The window immediately displays the full `git show <commit>` diff.
2. **Back to Log:** Press **`q`** or **`<BS>`** (Backspace) to return back to the log list.
3. **Side-by-Side Inspection:** Press **`<leader>gc`** to open a dedicated vertical panel on the right showing the commit details while keeping the log open.
4. **Syntax-Highlighted Delta:** Press **`<leader>gd`** on any commit line to view the commit in **`delta`** in a dedicated terminal tab.

---

## 5. 📦 Stashes & Line Range History

### Git Stashes
* **`<leader>pS`** : Open the interactive Git stash picker. As you cycle through stashes, a **live diff preview** is rendered in real time. Press **`<CR>`** to open the full diff in **`delta`**.
* **`<leader>gS`** : Open `:tab Git stash list` in a dedicated tab. Press **`<CR>`** on any stash to view its diff in-place, and **`q`** to close.

### Line Evolution History (`<leader>gh`)
* Curious how a specific line or function evolved over time?
* Place your cursor on the line (or visually select a range) and press **`<leader>gh`**.
* Neovim opens the isolated commit history (`git log -L`) for that exact block of code.

---

## 6. 🐙 GitHub PR Integration (GitHub CLI `gh`)

If you work with GitHub pull requests, these keymaps provide instant terminal reviews:
* **`<leader>gpr`** : List open pull requests (`gh pr list`).
* **`<leader>gpv`** : View details and comments of the active PR (`gh pr view`).
* **`<leader>gpd`** : Review PR diffs formatted via **`delta`** (`gh pr diff | delta`).
* **`<leader>gpc`** : Interactively checkout PR branches (`gh pr checkout`).

---

## ⚡ Quick Reference Cheatsheet

| Keymap | Mode | Action |
| :--- | :--- | :--- |
| **`]h` / `[h`** | Normal | Next / Previous Git hunk |
| **`<leader>td`** | Normal | Toggle inline diff overlay in buffer |
| **`ghgh`** | Normal | Stage hunk under cursor |
| **`gh_` / `gh`** | Normal / Visual | Stage current line / visual selection |
| **`gHgh`** | Normal | Discard hunk under cursor |
| **`gH_` / `gH`** | Normal / Visual | Discard line / visual selection |
| **`<leader>gs`** | Normal | Open Git status tab |
| **`:Git commit`** | Command | Open commit editor split |
| **`<leader>gl`** | Normal | Open Git log tab |
| **`<leader>gL`** | Normal | Open Git graph across all branches |
| **`<leader>gf`** | Normal | Open Git log for current file |
| **`<CR>`** | Normal *(in log)* | Inspect commit diff in-place |
| **`q` / `<BS>`** | Normal *(in diff)* | Return to log / stash list |
| **`<leader>gc`** | Normal | Inspect commit in right vertical split |
| **`<leader>gd`** | Normal | Open Delta diff tab (working tree or commit) |
| **`<leader>pS`** | Normal | Pick stashes with live diff preview |
| **`<leader>gh`** | Normal / Visual | Line range evolution history |
| **`<leader>gb`** | Normal | Pick and switch Git branches |
