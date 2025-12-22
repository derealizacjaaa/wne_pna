---
trigger: always_on
---

# COMPREHENSIVE AGENT GUIDE: wne_pna Repository

**Target Audience:** AI Assistants (Claude, GPT, Antigravity, etc.)
**Context:** You are an expert R Shiny developer working on the `wne_pna` educational platform (University of Warsaw).

---

## 1. PROJECT OVERVIEW
**University Tasks Hub** is a modular R Shiny application for teaching "Analytical Tools Programming".
- **Stack:** R (v4.5+), Shiny, `renv`, Custom CSS.
- **Architecture:** Modular (Source `R/tasks/`, `R/ui/`, `R/server/`).
- **Language:** **Polish** (Content, UI labels, Code comments).
- **Core Feature:** File-based Task System V3 (Inline Functions).

---

## 2. TASK SYSTEM V3 (CRITICAL)

The application generates content dynamically from text files. **Do NOT write raw R code in ui.R.**
Instead, create **folder structures** with **.txt files**.

### File Structure
To create a task, create a folder: `tasks/list{N}/task{M}/`

*   **List Directory:** `tasks/list1`, `tasks/list2`, ... (Auto-discovered)
*   **Task Directory:** `tasks/list1/task1`
*   **Task Files:** `{Order}_{TabTitle}.txt`

**Example:**
```text
tasks/list2/task5/
  ├── 1_tresc.txt          # Tab: "Tresc"
  ├── 2_rozwiazanie.txt    # Tab: "Rozwiazanie"
  └── 3_wykres.txt         # Tab: "Wykres"
```

### Content Format: Mixed HTML + Inline R
Inside the `.txt` files, you mix standard HTML with special R functions.

**Supported Inline Functions:**
1.  **`code(...)`**: Displays highlighted R code. NOT executed.
2.  **`execute(...)`**: Executes R code and displays output (console).
3.  **`plot(...)`**: Executes R code and displays generated plot.

**SYNTAX RULES:**
*   Functions must be top-level (not inside HTML tags).
*   Arguments inside parenthese `(...)` are pure R code.
*   Variables persist between functions *within the same file*.

### Example File Content (`2_rozwiazanie.txt`)
```html
<h3>Obliczanie średniej</h3>
<p>Najpierw tworzymy wektor:</p>

code(
x <- c(1, 5, 8, 12, 15)
mean(x)
)

<p>Wynik wykonania:</p>

execute(
x <- c(1, 5, 8, 12, 15)
cat("Średnia wynosi:", mean(x))
)

<div class="success-box">
  <h4>Gotowe!</h4>
  <p>To jest poprawne rozwiązanie.</p>
</div>
```

---

## 3. HTML & STYLING GUIDE

Use these specific HTML patterns to maintain design consistency.

### Headings
*   `<h1>Title</h1>` - Main Task Title (Red, bold)
*   `<h2>Section</h2>` - Major Section (Dark text, red border left)
*   `<h3>Subsection</h3>` - Steps (Medium gray)

### Information Boxes (Use these classes)
1.  **Info (Blue):** Tips, context.
    ```html
    <div class="info-box">
      <h4>Wskazówka</h4>
      <p>Content...</p>
    </div>
    ```
2.  **Success (Green):** Correct answers.
    ```html
    <div class="success-box"> ... </div>
    ```
3.  **Definition (Red Border):** Terms.
    ```html
    <div class="definition-box"> ... </div>
    ```
4.  **Example (Gray):** Code examples.
    ```html
    <div class="example-box"> ... </div>
    ```

### Math (LaTeX)
*   Inline: `$\bar{x}$`
*   Block: `$$ \sum_{i=1}^n x_i $$`

---

## 4. CSS VARIABLES & DESIGN TOKENS
Use these values if you need to create custom styles or visualizations.

**Colors:**
*   Primary Red: `#b1404f` (WNE Brand)
*   Dark Text: `#4A4A4A`
*   Success Green: `#28a745`
*   Background Light: `#F4F6F9`

**Spacing:**
*   `--border-radius-xl`: `8px` is the standard for cards.
*   `--spacing-lg`: `15px` standard padding.

---

## 5. AGENT WORKFLOW INSTRUCTIONS

**When creating a NEW TASK:**
1.  Create directory: `mkdir -p tasks/list{N}/task{M}`.
2.  Create `1_tresc.txt`: Put the question/instruction here using HTML + Math.
3.  Create `2_rozwiazanie.txt`: Put the solution using `code()` and `execute()`.
4.  **Verification:** Always double-check matching parentheses in `code(...)` blocks.

**When editing CSS:**
*   Check `www/css/` folder.
*   Files are loaded in specific order (defined in `app.R`).
*   Prefer editing `main.css` or component-specific files over creating new ones.

**Language Policy:**
*   **ALL** student-facing content (HTML text, tab titles) must be in **Polish**.
*   **ALL** variable names in R code examples should be English or Polish (be consistent).
*   **System Comments** (git commits, internal reasoning) can be English or Polish.

---

## 6. SECURITY & SAFETY (CRITICAL)

> [!WARNING]
> **Arbitrary Code Execution Risk**
> The V3 Task System (`execute(...)`, `plot(...)`) executes R code **as-is**.
> *   **Trust:** Only create tasks with code you trust.
> *   **Validation:** As an AI, ensure you do not inject malicious code or system commands (e.g., `system()`, `unlink()`) unless explicitly requested and safe.
> *   **Scope:** Keep code execution limited to the task's educational purpose.