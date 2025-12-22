# CLAUDE.md - AI Assistant Guide for wne_pna Repository

## Project Overview

**University Tasks Hub** is an interactive R Shiny web application designed for managing and displaying programming exercises for an analytics course ("Programowanie narzędzi analitycznych") at the University of Warsaw, Faculty of Economic Sciences (WNE UW).

**Course Information:**
- **Course:** Programowanie narzędzi analitycznych (Analytical Tools Programming)
- **Group:** 16:45
- **Instructor:** Maksymilian Okumski
- **Semester:** Winter 2025/26

## Technology Stack

- **Primary Language:** R (v4.5.2)
- **Framework:** Shiny (reactive web framework)
- **Architecture:** Modular (rebuilt 2025-11-30)
- **Application Type:** Traditional Shiny app (app.R)
- **Package Manager:** renv (for reproducible environments)
- **Styling:** Custom CSS (8 modular CSS files in www/css/)
- **Runtime:** Shiny Server

## Repository Structure

```
wne_pna/
├── app.R                      # Main Shiny application (122 lines - orchestrator)
├── app.Rmd                    # Legacy R Markdown version (deprecated)
├── manifest.json              # Shiny Server deployment manifest
├── renv.lock                  # Locked R package dependencies
├── .Rprofile                  # R environment configuration
├── wne_pna.Rproj              # RStudio project file
│
├── R/                         # Modular R source code (NEW!)
│   ├── config/
│   │   └── metadata.R         # Dynamic list discovery & metadata
│   │
│   ├── tasks/
│   │   ├── display.R          # Code block rendering (code_block, code_output)
│   │   ├── executor.R         # Code execution engine with smart labeling
│   │   ├── builder.R          # Task tab builders (V1 manual tasks)
│   │   ├── builder_v2.R       # File-based builder (typed files)
│   │   ├── builder_v3.R       # File-based builder (inline functions)
│   │   └── loader.R           # Task loading system
│   │
│   ├── ui/
│   │   ├── components.R       # Reusable UI components
│   │   ├── sidebar_left.R     # List selection sidebar (5-slot pagination)
│   │   ├── sidebar_right.R    # Task selection sidebar
│   │   └── main_content.R     # Main content area & welcome screen
│   │
│   └── server/
│       ├── state.R            # Reactive state management
│       ├── observers.R        # Event handlers
│       └── renderers.R        # Output rendering
│
├── www/                       # Static web resources (Shiny convention)
│   └── css/                   # Modular CSS files (loaded in specific order)
│       ├── main.css          # Base styles
│       ├── header.css        # Hero header styling
│       ├── navbar.css        # Navigation bar
│       ├── layout.css        # Overall layout
│       ├── left-sidebar.css  # List selection sidebar
│       ├── right-sidebar.css # Task selection sidebar
│       ├── progress-card.css # Progress tracking components
│       └── main-content.css  # Main content area
│
├── tasks/                     # Task content organized by lists
│   ├── helpers.R             # Legacy helper functions (kept for compatibility)
│   ├── task_loader.R         # Legacy task loader (kept for compatibility)
│   │
│   ├── list1/                # Lista I (auto-discovered)
│   │   ├── task1/
│   │   │   ├── 1_tresc.txt           # V3: Tab title from filename
│   │   │   └── 2_rozwiazanie.txt     # V3: Mixed HTML + inline functions
│   │   ├── task2/
│   │   │   ├── 1_content.txt         # V2: Content tab
│   │   │   ├── 2_code.txt           # V2: Code display
│   │   │   └── 3_execute.txt        # V2: Code execution
│   │   └── task3/
│   │       └── task.R                # V1: Manual create_task() function
│   │
│   ├── list2/                # Lista II
│   ├── list3/                # Lista III
│   ├── list4/                # Lista IV
│   ├── list5/                # Lista V
│   ├── list6/                # Lista VI
│   └── list7/                # Lista VII
│
├── backup/                    # Backup of old monolithic files
│   ├── helpers.R.bak
│   └── task_loader.R.bak
│
├── .agent/                    # Agent configuration (AI assistant rules)
│   └── rules/
│       └── overall.md         # Quick-reference guide for AI agents
│
├── .kombai/                   # Kombai configuration (alternative agent system)
│   └── rules/
│       └── overall.md         # Quick-reference guide (identical to .agent)
│
├── CLAUDE.md                  # This file
├── REBUILD_NOTES.md          # Architecture rebuild documentation
├── TASK_SYSTEM_V3_GUIDE.md   # V3 inline functions guide
├── FILE_BASED_TASKS_GUIDE.md # V2 typed files guide
├── DYNAMIC_LISTS_GUIDE.md    # Dynamic list discovery guide
│
└── renv/                      # R package environment (managed by renv)
    ├── activate.R
    └── settings.json
```

## Major Architecture Changes (2025-11-30)

### Before: Monolithic Structure
```
app.R                (570 lines - mixed concerns)
tasks/helpers.R      (399 lines - fat functions)
tasks/task_loader.R  (233 lines)
```

### After: Modular Architecture
```
app.R                (122 lines - clean orchestrator)
R/                   (14 focused modules)
├── config/          (Dynamic list discovery)
├── tasks/           (Display, execution, building, loading)
├── ui/              (Components, sidebars, content)
└── server/          (State, observers, renderers)
```

**Benefits:**
- ✅ **79% reduction** in app.R lines
- ✅ **Smaller, focused functions** (~50 lines avg, was ~170 max)
- ✅ **Clear separation of concerns**
- ✅ **Easy to navigate and modify**
- ✅ **Better testability**
- ✅ **Preserved all functionality**

## Application Structure (app.R)

The main app.R is now a **minimal orchestrator** that sources modules and initializes the app:

### Main Sections (126 lines total)

1. **Libraries** (Lines 7-14)
   - Loads: shiny, bslib, dplyr, base64enc, fontawesome, maxLik, ggplot2

2. **Source Modules** (Lines 16-40)
   - Configuration: `R/config/metadata.R`
   - Task system: `R/tasks/*.R`
   - UI components: `R/ui/*.R`
   - Server logic: `R/server/*.R`

3. **Data Initialization** (Lines 42-49)
   - **Dynamic list discovery**: `list_metadata <- get_list_metadata()`
   - Auto-loads all tasks: `all_lists <- load_all_tasks()`

4. **UI Definition** (Lines 51-100)
   - `fluidPage()` container
   - CSS includes (8 files in order)
   - Hero header with course info
   - Dynamic layout container

5. **Server Logic** (Lines 102-119)
   - Initializes reactive state
   - Creates reactive expressions
   - Sets up observers and renderers

6. **App Launch** (Line 125)
   - `shinyApp(ui = ui, server = server)`

## Modular Architecture Details

### Configuration Layer (`R/config/`)

**R/config/metadata.R** - Dynamic list discovery
- `discover_lists(tasks_dir)` - Scans `tasks/` for `listN` folders
- `generate_list_metadata(list_id)` - Creates metadata on-the-fly
- `get_list_metadata()` - Returns all discovered lists
- **No manual configuration needed!** Just create `tasks/listN/` folder

### Task System (`R/tasks/`)

**R/tasks/display.R** - Visual rendering
- `code_block(code, language, padding)` - Syntax-highlighted code display
- `code_output(output)` - Execution output display
- Gray background, red border for code; green border for output

**R/tasks/executor.R** - Code execution engine
- `execute_code(code, use_auto_labels, use_comments, envir)` - Smart execution
- `capture_plot(code, envir)` - Plot capture and embedding
- `capture_text_output(code, envir)` - Console output capture
- Three-tier labeling: `cat()` > comments > auto-labels

**R/tasks/builder.R** - V1 Manual task builders
- `create_code_output_tabs(code, ...)` - Standard Kod/Wynik tabs
- `create_multi_code_tabs(exercises, ...)` - Multi-part exercises
- `auto_generate_basic_task(task_dir)` - Simple content.txt + code.txt

**R/tasks/builder_v2.R** - V2 Typed file tasks
- Filenames indicate type: `2_code.txt`, `3_execute.txt`, `4_plot.txt`
- `build_task_from_typed_files(task_dir)` - Assembles tabs from files

**R/tasks/builder_v3.R** - V3 Inline function tasks
- Filenames = tab titles: `2_rozwiazanie.txt` → "Rozwiązanie" tab
- Inline functions: `code(...)`, `execute(...)`, `plot(...)`
- `build_task_from_inline_files(task_dir)` - Parses mixed HTML + R

**R/tasks/loader.R** - Task loading system
- `load_all_tasks(tasks_dir)` - Main loader
- `find_list_directories(tasks_dir)` - Discovers lists
- `find_all_tasks(list_dir)` - Finds tasks (folders & legacy files)
- `load_single_task(task_path, list_id, list_num)` - Loads one task
- Returns structure: `all_lists[[list_id]][[task_id]]`

### UI Layer (`R/ui/`)

**R/ui/components.R** - Reusable UI elements
- `create_progress_bar(percentage, ...)` - Vertical progress bars
- `create_task_counter(completed, total)` - Task completion badges
- `create_list_item(list_id, ...)` - List sidebar buttons
- `create_empty_list_slot()` - Empty slot placeholders

**R/ui/sidebar_left.R** - List selection sidebar
- `generate_list_sidebar(all_lists, list_metadata, ...)` - Main generator
- **Fixed 5-slot layout** with pagination
- Progress bars and overall stats
- Home button and collapsible

**R/ui/sidebar_right.R** - Task selection sidebar
- `generate_task_sidebar(tasks, list_id, ...)` - Task list generator
- Numbered task buttons with completion icons
- Current list header

**R/ui/main_content.R** - Main content area
- `generate_main_content(task)` - Renders task content
- `generate_welcome_screen()` - Landing page
- Task navigation navbar

### Server Layer (`R/server/`)

**R/server/state.R** - Reactive state management
- `init_reactive_state()` - Initializes reactive values
- `current_list()`, `current_task()`, `sidebar_collapsed()`
- `create_current_list_tasks(state, all_lists)` - Reactive expression

**R/server/observers.R** - Event handlers
- `setup_observers(input, state, ...)` - Configures all observers
- List selection clicks
- Task selection clicks
- Navigation buttons (prev/next task, home)
- Sidebar collapse/expand
- Pagination (prev/next page)

**R/server/renderers.R** - Output rendering
- `setup_renderers(output, state, ...)` - Configures all renderers
- `output$dynamic_layout` - Main layout
- `output$list_sidebar` - Left sidebar
- `output$task_sidebar` - Right sidebar
- `output$main_content` - Content area

## 📘 Quick Start for AI Assistants

**If you're an AI assistant (Claude, ChatGPT, Gemini, etc.) creating tasks for this app:**

→ **Read [AI_TASK_CREATION_GUIDE.md](AI_TASK_CREATION_GUIDE.md) first!**

This comprehensive guide provides:
- ✅ Complete syntax reference for V3 inline functions (`code()`, `execute()`, `plot()`, `run()`)
- ✅ HTML elements and styling (headings, boxes, math formulas, tables)
- ✅ Best practices and common patterns
- ✅ Working examples and templates
- ✅ Troubleshooting tips

**For quick reference:** The guide includes a summary table of all available elements and their usage.

### Agent Rules Quick Reference

For rapid task creation and execution, see the concise agent guide:
- **[.agent/rules/overall.md](.agent/rules/overall.md)** - Action-oriented quick reference
  - ✅ V3 Task System essentials (file structure, inline functions)
  - ✅ HTML styling patterns (info-box, success-box, definition-box)
  - ✅ CSS design tokens (colors, spacing)
  - ✅ Step-by-step workflow instructions
  - ✅ Security guidelines for code execution

**When to use each guide:**
- **AI_TASK_CREATION_GUIDE.md** → Creating task content (syntax, examples, HTML)
- **.agent/rules/overall.md** → Quick workflow + safety rules
- **CLAUDE.md** (this file) → Comprehensive architecture reference

---

## Task Organization System

The app supports **THREE task creation methods**, auto-detected by the loader:

### V1: Manual Tasks (Full Control)

**Use for:** Complex tasks with custom layouts

```
tasks/list1/task1/
  └── task.R         # Must define create_task() function
```

**task.R example:**
```r
create_task <- function() {
  list(
    content = page_navbar(
      title = "",
      id = "task_tabs",
      nav_panel(
        title = "Treść",
        div(class = "task-tab-content-simple", h2("Custom Task"))
      ),
      nav_panel(
        title = "Rozwiązanie",
        div(class = "task-tab-content-simple", p("Custom content..."))
      )
    ),
    completed = TRUE,
    name = "Custom Task Name"  # Optional
  )
}
```

### V2: Typed Files (Simple File-Based)

**Use for:** Standard tasks with separate code/execution files

**Filename types:**
- `N_content.txt` → Content tab (HTML)
- `N_code.txt` → Code display tab (R code, not executed)
- `N_execute.txt` → Execution tab (R code, executed, shows output)
- `N_plot.txt` → Plot tab (R code, executed, shows plot)

```
tasks/list1/task2/
  ├── 1_content.txt    # HTML content
  ├── 2_code.txt       # R code to display
  └── 3_execute.txt    # R code to execute
```

**Order number (N)** determines tab position (1, 2, 3, ...)

**See:** FILE_BASED_TASKS_GUIDE.md for details

### V3: Inline Functions (Recommended)

**Use for:** Rich narrative content mixing HTML and R code

**Filename = Tab title:**
- `1_tresc.txt` → "Treść" tab
- `2_rozwiazanie.txt` → "Rozwiązanie" tab
- `2a_przyklad.txt`, `2b_przyklad.txt` → Both in "Przyklad" tab (subtasks)

**Inside files, mix HTML and inline functions:**

```html
<h3>Rozwiązanie zadania</h3>

<p>Najpierw utworzymy wektor:</p>

code(
x <- 1:10
mean(x)
)

<p>Teraz wykonajmy kod:</p>

execute(
x <- 1:10
cat("Średnia:", mean(x), "\n")
)

<p>I narysujmy wykres:</p>

plot(
x <- 1:10
barplot(x, col = "steelblue")
)
```

**Inline functions:**
- `code(...)` - Display R code (syntax highlighted, not executed)
- `execute(...)` - Execute R code and show output
- `plot(...)` - Execute R code and embed plot

**See:** TASK_SYSTEM_V3_GUIDE.md for detailed guide

### Auto-Generation (Legacy/Fallback)

**Simplest method** for basic tasks:

```
tasks/list1/task3/
  ├── content.txt    # HTML content
  └── code.txt       # Optional: R code (if present, creates Kod/Wynik tabs)
```

- With `code.txt`: Creates 3 tabs (Treść/Kod/Wynik), `completed = TRUE`
- Without `code.txt`: Creates 1 tab (Treść), `completed = FALSE`

### Task Loading Priority

When loading tasks, the system checks in this order:

1. **Inline functions (V3)?** → Files matching `N_*.txt` with `code(...)` etc.
2. **Typed files (V2)?** → Files matching `N_content.txt`, `N_code.txt`, etc.
3. **Manual (V1)?** → `task.R` file exists
4. **Auto-generation?** → `content.txt` (± `code.txt`)

## Dynamic List Discovery

**No manual configuration needed!** Lists are auto-discovered.

### How It Works

1. **Scan `tasks/` directory** for folders matching `listN` pattern
2. **Generate metadata on-the-fly** with Roman numerals
3. **Display in fixed 5-slot layout** with pagination

```bash
# Just create a folder - it appears automatically!
mkdir tasks/list8
# Reload app → "Lista VIII" appears in sidebar
```

### 5-Slot Pagination

The left sidebar **always shows exactly 5 list slots** per page:

**Example with 7 lists:**
- **Page 1:** Lists 1-5
- **Page 2:** Lists 6-7 + 3 empty slots (grayed out, non-clickable)

**See:** DYNAMIC_LISTS_GUIDE.md for details

## Styling System

### CSS Loading Order

**IMPORTANT:** CSS files must load in this order (app.R:60-67):

```r
tags$link(rel = "stylesheet", type = "text/css", href = "css/main.css"),
tags$link(rel = "stylesheet", type = "text/css", href = "css/header.css"),
tags$link(rel = "stylesheet", type = "text/css", href = "css/navbar.css"),
tags$link(rel = "stylesheet", type = "text/css", href = "css/layout.css"),
tags$link(rel = "stylesheet", type = "text/css", href = "css/left-sidebar.css"),
tags$link(rel = "stylesheet", type = "text/css", href = "css/right-sidebar.css"),
tags$link(rel = "stylesheet", type = "text/css", href = "css/progress-card.css"),
tags$link(rel = "stylesheet", type = "text/css", href = "css/main-content.css")
```

### Color Scheme

- **Primary Red:** `#b1404f` (WNE brand color)
- **Dark Gray:** `#4A4A4A` (text, borders)
- **Medium Gray:** `#606060` (secondary text)
- **Light Gray:** `#F4F6F9` (backgrounds)
- **Success Green:** `#28a745` (output, completion)
- **White:** `#ffffff` (content backgrounds)

### Key CSS Classes

- `.hero-header` - Top banner with logo
- `.app-container` / `.content-wrapper-dual` - Main layout
- `.left-sidebar` / `.right-sidebar` - Side panels
- `.main-content` - Central content area
- `.code-block` - Code display (gray bg, red left border)
- `.code-output` - Execution output (green left border)
- `.task-item` / `.list-item` - Navigation buttons
- `.list-item-empty` - Empty list slots (grayed out)
- `.progress-bar-container-vertical` - Progress indicators

### Three-Panel Responsive Layout

1. **Left Sidebar** - List selection (collapsible on small screens)
   - 5-slot fixed layout
   - Progress bars per list
   - Overall stats card
   - Pagination controls

2. **Main Content** - Task display
   - Dynamic navbar for task tabs
   - Tabbed content (Treść/Kod/Wynik/etc.)
   - Welcome screen when no selection

3. **Right Sidebar** - Task selection
   - Numbered task buttons
   - Completion status icons (✓)
   - Current list header

## Development Workflow

### Setting Up the Environment

```r
# 1. Open RStudio and load the project
# Double-click wne_pna.Rproj

# 2. Restore R package environment
renv::restore()

# 3. Run the Shiny app
# Option A: Click "Run App" button in RStudio
# Option B: In R console
shiny::runApp()

# Option C: From command line
R -e "shiny::runApp()"
```

### Adding a New Task

**Method 1: V3 Inline Functions (Recommended)**

```bash
# 1. Create task directory
mkdir -p tasks/list1/task20

# 2. Add content tab
cat > tasks/list1/task20/1_tresc.txt << 'EOF'
<h2>Zadanie 20: Nowe zadanie</h2>
<p>Opis zadania tutaj...</p>
EOF

# 3. Add solution tab with mixed content
cat > tasks/list1/task20/2_rozwiazanie.txt << 'EOF'
<h3>Rozwiązanie</h3>
<p>Kod:</p>

code(
x <- 1:100
mean(x)
)

<p>Wynik:</p>

execute(
x <- 1:100
cat("Średnia:", mean(x), "\n")
)
EOF

# 4. Reload app → Task appears automatically!
```

**Method 2: V2 Typed Files**

```bash
mkdir -p tasks/list1/task21
echo "<h2>Zadanie 21</h2>" > tasks/list1/task21/1_content.txt
echo "x <- 1:10\nmean(x)" > tasks/list1/task21/2_code.txt
echo "x <- 1:10\ncat('Mean:', mean(x))" > tasks/list1/task21/3_execute.txt
```

**Method 3: V1 Manual (Complex Tasks)**

Create `tasks/list1/task22/task.R` with `create_task()` function.

### Adding a New List

```bash
# Just create the directory!
mkdir tasks/list8

# Add first task
mkdir tasks/list8/task1
echo "<h2>First task in list 8</h2>" > tasks/list8/task1/1_tresc.txt

# Reload app → "Lista VIII" appears automatically
```

### Modifying UI Components

```r
# Example: Change list sidebar appearance
# Edit: R/ui/sidebar_left.R

# Example: Change task display
# Edit: R/ui/main_content.R

# Example: Change CSS styling
# Edit: www/css/[component].css
```

### Adding New R Dependencies

```r
# In R console
renv::install("package_name")

# Update lockfile
renv::snapshot()

# Commit both renv.lock and (if changed) manifest.json
```

## R Code Conventions

### Code Style (.Rproj settings)

- **Indentation:** 2 spaces (not tabs)
- **Encoding:** UTF-8
- **Line endings:** Unix-style (LF)

### Naming Conventions

- **Functions:** `snake_case` (e.g., `generate_list_sidebar`, `load_all_tasks`)
- **Variables:** `snake_case` (e.g., `current_list`, `task_id`, `all_lists`)
- **Reactive values:** `camelCase()` (e.g., `current_list()`, `sidebar_collapsed()`)
- **Lists:** `list1`, `list2`, ..., `listN`
- **Tasks:** `task1`, `task2`, ..., `taskN`

### Common Patterns

**Creating task tabs (V1 manual):**
```r
# Simple code/output tabs
create_code_output_tabs(
  code = "x <- 1:10\nmean(x)",
  code_tab_title = "Kod",
  output_tab_title = "Wynik"
)

# Multi-part exercise with shared environment
create_multi_code_tabs(
  exercises = list(
    list(title = "A)", code = "x <- 1:10"),
    list(title = "B)", code = "mean(x)")  # x available from A)
  )
)
```

**HTML in content files:**
```html
<h2>Zadanie X: Tytuł</h2>
<p>Opis zadania z <strong>formatowaniem</strong>.</p>
<ol style="list-style-type: lower-alpha">
  <li>Podpunkt a)</li>
  <li>Podpunkt b)</li>
</ol>
<code>inline_code()</code>
```

## Git Workflow

### Current Branch

**Development branch:** `claude/claude-md-miojn0a5oswhhnd9-01YSMpwnYoMcJ7CWR8feDfa2`

### Branch Naming Convention

- **Feature branches:** `claude/claude-md-{random-id}-{session-id}`
- Must start with `claude/` and end with matching session ID
- Main branch: (check with `git branch` or GitHub)

### Git Operations Guidelines

**Pushing:**
```bash
# Always use -u flag for first push
git push -u origin claude/claude-md-miojn0a5oswhhnd9-01YSMpwnYoMcJ7CWR8feDfa2

# Retry on network errors: up to 4 times with exponential backoff
# (2s, 4s, 8s, 16s)
```

**Fetching/Pulling:**
```bash
# Prefer specific branch
git fetch origin claude/claude-md-miojn0a5oswhhnd9-01YSMpwnYoMcJ7CWR8feDfa2
git pull origin claude/claude-md-miojn0a5oswhhnd9-01YSMpwnYoMcJ7CWR8feDfa2

# Retry on network errors with same backoff strategy
```

**Committing:**
- Use descriptive messages in Polish or English
- Examples:
  - "Add task 5 to list 3"
  - "Update left sidebar CSS for better responsiveness"
  - "Fix ggplot rendering in execute_code"
  - "Dodaj zadanie 7 do listy 2"

## AI Assistant Guidelines

### When Working on This Codebase

1. **Understand the modular architecture**
   - Find code by function: check R/ subdirectories
   - UI changes → `R/ui/*.R` + `www/css/*.css`
   - Task behavior → `R/tasks/*.R`
   - Server logic → `R/server/*.R`

2. **Choose the right task creation method**
   - **V3 (inline functions):** For educational content with narrative
   - **V2 (typed files):** For simple separation of code/execution
   - **V1 (manual):** For complex custom layouts
   - **Auto-generation:** For very simple tasks

3. **Preserve the Polish language** in:
   - Task descriptions and content
   - UI labels (tab titles, buttons)
   - Commit messages (Polish or English acceptable)

4. **Maintain CSS consistency**
   - Load CSS in the specified order
   - Use the established color scheme
   - Test responsive behavior (desktop, tablet, mobile)

5. **R code execution**
   - Use `execute_code()` for automatic output generation
   - Leverage shared environments for multi-part exercises
   - Follow three-tier labeling: `cat()` > comments > auto-labels

6. **Dependencies**
   - Always update `renv.lock` after adding packages
   - Use `renv::install()` and `renv::snapshot()`

7. **Testing before committing**
   - Test task loading: `source("R/tasks/loader.R"); load_all_tasks()`
   - Check list discovery: `source("R/config/metadata.R"); get_list_metadata()`
   - Verify UI rendering in browser
   - Test on multiple screen sizes

8. **File modifications**
   - **Always read files before editing**
   - Preserve formatting and indentation (2 spaces)
   - Maintain UTF-8 encoding
   - Don't modify files outside the project scope

### Common Tasks for AI Assistants

#### Adding a new task to existing list

```bash
# V3 method (recommended)
mkdir -p tasks/list2/task25
cat > tasks/list2/task25/1_tresc.txt << 'EOF'
<h2>Zadanie 25: Opis</h2>
<p>Treść zadania...</p>
EOF

cat > tasks/list2/task25/2_rozwiazanie.txt << 'EOF'
<p>Rozwiązanie:</p>
code(...)
execute(...)
EOF
```

#### Updating task completion status

- **V3/V2:** Presence of execution determines completion
- **V1 manual:** Set `completed = TRUE/FALSE` in `create_task()`
- **Auto-generation:** Add or remove `code.txt`

#### Fixing broken tasks

1. Check directory structure: `ls -la tasks/listN/taskM/`
2. Verify files exist and have valid syntax
3. Check R console for error messages during `load_all_tasks()`
4. Test task parsing manually:
   ```r
   source("R/tasks/loader.R")
   task <- load_single_task("tasks/list1/task1", "list1", 1)
   ```

#### Modifying UI layout

1. **Identify component:** Header? Sidebar? Content?
2. **For structure changes:** Edit `R/ui/[component].R`
3. **For styling changes:** Edit `www/css/[component].css`
4. **Test in browser** after changes
5. **Check responsive behavior** on different screen sizes

#### Adding a new feature to task system

1. **Display functions:** Add to `R/tasks/display.R`
2. **Execution logic:** Modify `R/tasks/executor.R`
3. **Task building:** Extend appropriate builder (`R/tasks/builder*.R`)
4. **Update documentation:** Add examples to relevant guide

### Key Files Reference

| File | Purpose | When to Modify |
|------|---------|----------------|
| `app.R` | Main orchestrator | Rarely (only for major structural changes) |
| `R/config/metadata.R` | List discovery | To customize list metadata logic |
| `R/tasks/display.R` | Code rendering | To change code/output appearance |
| `R/tasks/executor.R` | Code execution | To modify execution behavior |
| `R/tasks/builder.R` | V1 task builder | To add new V1 task patterns |
| `R/tasks/builder_v2.R` | V2 task builder | To modify typed file behavior |
| `R/tasks/builder_v3.R` | V3 task builder | To modify inline function parsing |
| `R/tasks/loader.R` | Task loading | To change task discovery logic |
| `R/ui/sidebar_left.R` | List sidebar | To modify list navigation |
| `R/ui/sidebar_right.R` | Task sidebar | To modify task navigation |
| `R/ui/main_content.R` | Content area | To modify task display |
| `R/ui/components.R` | UI components | To add reusable UI elements |
| `R/server/state.R` | Reactive state | To add new reactive values |
| `R/server/observers.R` | Event handlers | To add new interactions |
| `R/server/renderers.R` | Output rendering | To add new outputs |
| `www/css/*.css` | Styling | To change appearance |
| `renv.lock` | Dependencies | After `renv::snapshot()` |
| `manifest.json` | Deployment | After changing R version or dependencies |

### Warning: Do Not Modify

- `.git/` directory contents
- `renv/` directory contents (managed by renv)
- `.Rprofile` (unless changing renv configuration)
- File encoding (must stay UTF-8)
- `backup/` directory (historical reference)

### Best Practices

1. **Read before you write**
   - Always read existing files before modifying
   - Understand context and conventions

2. **Test incrementally**
   - Test after each change
   - Don't batch multiple untested changes

3. **Use appropriate abstraction level**
   - V3 for most new tasks (easiest for content creators)
   - V2 for simple code/execution separation
   - V1 only when custom layouts are essential

4. **Keep functions focused**
   - Each function should do one thing well
   - Average function size: ~30-50 lines

5. **Document complex logic**
   - Add comments for non-obvious code
   - Update guides when adding new features

6. **Commit atomically**
   - One logical change per commit
   - Clear, descriptive commit messages

## Deployment

The application is configured for **Shiny Server** deployment via `manifest.json`.

**Key Settings:**
- Runtime: Shiny
- R Version: 4.5.2
- Package Manager: renv

**Deployment Steps:**
1. Ensure all changes committed
2. Ensure `renv.lock` is up to date
3. Push to deployment server
4. Shiny Server reads `manifest.json` and restores environment via renv

## Troubleshooting

### Task Not Loading

**Symptoms:** Task doesn't appear in UI

**Diagnosis:**
```r
# Check if task is loaded
source("R/tasks/loader.R")
all_lists <- load_all_tasks()
all_lists$list1$task1  # Should show task object
```

**Common causes:**
- Task directory named incorrectly (must be `taskN`)
- Missing required files (V3: no `N_*.txt`, V2: no `N_content.txt`, etc.)
- Syntax errors in R code
- Malformed `create_task()` function (V1)

**Solution:** Check R console for error messages during loading

### CSS Not Applying

**Symptoms:** Styles not visible or incorrect

**Diagnosis:**
- Check CSS file exists in `www/css/`
- Check CSS file linked in correct order in `app.R`
- Clear browser cache and hard reload (Ctrl+Shift+R)

**Solution:**
- Verify CSS file path
- Check for syntax errors in CSS
- Ensure CSS loaded before files that depend on it

### Code Output Not Displaying

**Symptoms:** Code executes but no output shown

**Diagnosis:**
```r
# Test execution directly
source("R/tasks/executor.R")
source("R/tasks/display.R")
result <- execute_code("x <- 1:10\ncat('Mean:', mean(x))")
print(result)
```

**Common causes:**
- Code has no output (no `cat()`, `print()`, or return value)
- Code has errors (check for error messages)
- Inline function syntax error (V3): unbalanced parentheses

**Solution:**
- Add explicit output with `cat()` or `print()`
- Fix code syntax errors
- Check parentheses balance in `code(...)`, `execute(...)`, `plot(...)`

### List Not Discovered

**Symptoms:** New list folder doesn't appear in sidebar

**Diagnosis:**
```r
source("R/config/metadata.R")
discover_lists("tasks")  # Should include your new list
```

**Common causes:**
- Folder not named `listN` (must match pattern exactly)
- Folder empty (no tasks inside)

**Solution:**
- Rename folder to `listN` format
- Add at least one task to the list

### Package Installation Fails

**Symptoms:** `renv::install()` fails

**Common causes:**
- Package name incorrect
- CRAN repository unreachable
- Package requires system dependencies

**Solution:**
```r
# Try with explicit CRAN repo
renv::install("package_name", repos = "https://cran.r-project.org")

# Check available packages
available.packages()

# For system dependencies, install via system package manager first
# Example: sudo apt-get install libcurl4-openssl-dev
```

### App Won't Start

**Symptoms:** `shiny::runApp()` fails

**Diagnosis:**
- Check R console for error messages
- Verify all source files exist
- Check for syntax errors in R files

**Common causes:**
- Missing source file in `R/` directory
- Syntax error in sourced file
- Missing required package

**Solution:**
```r
# Test sourcing files individually
source("R/config/metadata.R")
source("R/tasks/display.R")
# ... etc

# Restore packages if needed
renv::restore()
```

## Performance Considerations

### Task Loading

- Tasks loaded once at app startup
- Large numbers of tasks: consider lazy loading (future enhancement)
- Complex V1 tasks: cache rendered content (future enhancement)

### Code Execution

- Code executed on demand (when tab opened)
- Plots cached as base64 PNG
- Text output captured efficiently

### CSS and Assets

- CSS files loaded once, cached by browser
- External logo image (WNE UW) - consider local copy for offline use

## Additional Resources

### Official Documentation

- **Shiny:** https://shiny.rstudio.com/
- **bslib Package:** https://rstudio.github.io/bslib/
- **renv:** https://rstudio.github.io/renv/
- **R Markdown:** https://rmarkdown.rstudio.com/

### Project-Specific Guides

- **REBUILD_NOTES.md** - Architecture refactoring details
- **TASK_SYSTEM_V3_GUIDE.md** - V3 inline functions comprehensive guide
- **FILE_BASED_TASKS_GUIDE.md** - V2 typed files guide
- **DYNAMIC_LISTS_GUIDE.md** - Dynamic list discovery guide

### Learning Resources

- **R for Data Science:** https://r4ds.had.co.nz/
- **Advanced R:** https://adv-r.hadley.nz/
- **Shiny Tutorial:** https://shiny.rstudio.com/tutorial/

---

## Quick Reference

### Task Creation Cheat Sheet

```bash
# V3 (Recommended) - Inline functions
mkdir -p tasks/list1/task99
cat > tasks/list1/task99/1_tresc.txt << 'EOF'
<h2>Zadanie</h2>
EOF

cat > tasks/list1/task99/2_rozwiazanie.txt << 'EOF'
code(...)
execute(...)
plot(...)
EOF

# V2 - Typed files
mkdir -p tasks/list1/task99
echo "content" > tasks/list1/task99/1_content.txt
echo "code" > tasks/list1/task99/2_code.txt
echo "code" > tasks/list1/task99/3_execute.txt

# V1 - Manual
mkdir -p tasks/list1/task99
cat > tasks/list1/task99/task.R << 'EOF'
create_task <- function() {
  list(content = ..., completed = TRUE)
}
EOF
```

### Common Commands

```r
# Restore environment
renv::restore()

# Run app
shiny::runApp()

# Add package
renv::install("package_name")
renv::snapshot()

# Test task loading
source("R/tasks/loader.R")
all_lists <- load_all_tasks()

# Test list discovery
source("R/config/metadata.R")
get_list_metadata()
```

### File Structure Quick Lookup

```
Need to modify...         →  Edit file...
─────────────────────────────────────────────────────
List discovery logic      →  R/config/metadata.R
Task loading logic        →  R/tasks/loader.R
Code rendering            →  R/tasks/display.R
Code execution            →  R/tasks/executor.R
V1 task building          →  R/tasks/builder.R
V2 task building          →  R/tasks/builder_v2.R
V3 task building          →  R/tasks/builder_v3.R
Left sidebar UI           →  R/ui/sidebar_left.R
Right sidebar UI          →  R/ui/sidebar_right.R
Main content UI           →  R/ui/main_content.R
UI components             →  R/ui/components.R
Reactive state            →  R/server/state.R
Event handling            →  R/server/observers.R
Output rendering          →  R/server/renderers.R
Styling                   →  www/css/[component].css
```

---

**Last Updated:** 2025-12-02
**Repository:** derealizacjaaa/wne_pna
**Current Branch:** claude/claude-md-miojn0a5oswhhnd9-01YSMpwnYoMcJ7CWR8feDfa2
**Architecture Version:** 2.0 (Modular, post-rebuild)
**Task System:** V1 (Manual) + V2 (Typed Files) + V3 (Inline Functions)
