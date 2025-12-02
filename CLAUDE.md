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
- **Application Type:** Traditional Shiny app (app.R)
- **Package Manager:** renv (for reproducible environments)
- **Styling:** Custom CSS (8 modular CSS files in www/css/)
- **Runtime:** Shiny Server

## Repository Structure

```
wne_pna/
├── app.R                      # Main Shiny application file
├── app.Rmd                    # Legacy R Markdown version (deprecated)
├── manifest.json              # Shiny Server deployment manifest
├── renv.lock                  # Locked R package dependencies
├── .Rprofile                  # R environment configuration
├── wne_pna.Rproj              # RStudio project file
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
├── css/                       # Original CSS directory (kept for compatibility)
│
├── tasks/                     # Task content organized by lists
│   ├── helpers.R             # Helper functions for code display
│   ├── task_loader.R         # Unified task loading system
│   │
│   ├── list1/                # Lista I - Podstawy R
│   │   ├── task1/
│   │   │   ├── content.txt   # Task description (HTML supported)
│   │   │   └── code.txt      # Solution code (optional)
│   │   ├── task2/
│   │   └── ...
│   │
│   ├── list2/                # Lista II - Wizualizacja
│   ├── list3/                # Lista III - Struktury danych
│   ├── list4/                # Lista IV - Analiza statystyczna
│   ├── list5/                # Lista V - Programowanie
│   ├── list6/                # Lista VI - Zaawansowane
│   └── list7/                # Lista VII - Projekty
│
└── renv/                      # R package environment (managed by renv)
    ├── activate.R
    └── settings.json
```

## Application Structure (app.R)

The application follows the standard **Shiny app.R** structure with UI and Server components:

### Main Components

1. **Libraries & Setup** (Lines 1-13)
   - Loads required packages: shiny, bslib, dplyr, base64enc, fontawesome, maxLik
   - Sources helper functions: `tasks/helpers.R`
   - Sources task loader: `tasks/task_loader.R`
   - Loads all tasks: `all_lists <- load_all_tasks()`

2. **List Metadata** (Lines 20-59)
   - Defines 7 lists (list1-list7) with names and subtitles
   - Used for navigation and display

3. **UI Helper Functions** (Lines 64-229)
   - `generate_list_sidebar()`: Creates left sidebar with list navigation
   - `generate_task_sidebar()`: Creates right sidebar with task navigation

4. **UI Definition** (Lines 234-316)
   - `fluidPage()` container
   - CSS includes from `www/css/` directory
   - Hero header with course information
   - Dynamic layout container

5. **Server Logic** (Lines 321-461)
   - Reactive values: `current_list()`, `current_task()`, `sidebar_collapsed()`
   - Observers for navigation events
   - Rendering functions: `output$list_sidebar`, `output$task_sidebar`, `output$main_content`
   - Dynamic layout rendering

6. **App Initialization** (Lines 466-468)
   - `shinyApp(ui = ui, server = server)`

### Key Differences from app.Rmd

| Aspect | app.Rmd (Old) | app.R (New) |
|--------|---------------|-------------|
| Structure | R Markdown chunks | Traditional Shiny structure |
| CSS Loading | Inline via `readLines()` | External links in `<head>` |
| CSS Location | `css/` directory | `www/css/` directory (Shiny convention) |
| Execution | `rmarkdown::run()` | `shiny::runApp()` |
| Debugging | More complex | Easier with standard Shiny tools |
| Deployment | Works but non-standard | Standard Shiny Server deployment |

## Task Organization System

### Three Loading Modes

The application supports **three different modes** for loading tasks:

#### 1. AUTO-GENERATED (Recommended for Simple Tasks)

**Mode A: Content Only (Uncompleted Task)**
```
tasks/list1/task1/
  └── content.txt    # Task description (HTML supported)
```
- Creates **single tab**: "Treść"
- Marks as `completed = FALSE`
- Use for tasks awaiting solution

**Mode B: Content + Code (Completed Task)**
```
tasks/list1/task1/
  ├── content.txt    # Task description
  └── code.txt       # R code solution
```
- Creates **3 tabs**: "Treść", "Kod", "Wynik"
- Marks as `completed = TRUE`
- Auto-executes code and displays output

#### 2. MANUAL (For Complex/Special Tasks)

```
tasks/list1/task2/
  ├── task.R         # Custom create_task() function
  ├── content.txt    # (ignored if task.R exists)
  └── code.txt       # (ignored if task.R exists)
```
- Full control over task rendering
- Must define `create_task()` function
- Can create custom tab layouts

#### 3. LEGACY (Backward Compatibility)

```
tasks/list1/
  └── task3.R        # Old-style task file
```
- Supports older task structure
- Must define `create_task()` function

### Task Metadata

Metadata is **automatically inferred**:
- **List number:** From folder name (`list1` → 1)
- **Task number:** From folder/file name (`task1` → 1)
- **Completion status:** From task definition or auto-determined

## Key Helper Functions

### In `tasks/helpers.R`

1. **`code_block(code, language = "r", padding = "15px")`**
   - Creates styled code block with syntax highlighting
   - Removes leading/trailing empty lines
   - Uses consistent styling (gray background, red left border)

2. **`code_output(output)`**
   - Displays execution output
   - Supports both text and plots
   - Green left border for output blocks

3. **`execute_code(code, use_auto_labels = TRUE, use_comments = TRUE, envir = NULL)`**
   - Executes R code with smart output formatting
   - Captures both text output and plots
   - Three labeling methods:
     - **OPTION 1:** `cat()` in code (highest priority)
     - **OPTION 2:** Comments as labels (medium priority)
     - **OPTION 3:** Automatic labels (lowest priority)

4. **`create_code_output_tabs(code, ...)`**
   - Creates two tabs: "Kod" and "Wynik"
   - Auto-executes code if `auto_execute = TRUE`
   - Supports custom tab titles

5. **`create_multi_code_tabs(exercises, ...)`**
   - For exercises with multiple sub-tasks
   - Uses **shared environment** between code blocks
   - Variables persist across sub-tasks

6. **`auto_generate_basic_task(task_dir)`**
   - Core auto-generation function
   - Reads `content.txt` and `code.txt`
   - Returns task structure with completion status

### In `tasks/task_loader.R`

1. **`load_all_tasks(tasks_dir = "tasks")`**
   - Main loader function
   - Scans all list directories
   - Loads tasks using appropriate mode
   - Returns nested list structure: `all_lists[[list_id]][[task_id]]`

2. **`get_list_stats(all_lists, list_id)`**
   - Calculates completion statistics for a list
   - Returns: total, completed, remaining, percentage

3. **`get_overall_stats(all_lists)`**
   - Calculates overall progress across all lists
   - Returns: total_lists, total_tasks, completed_tasks, percentage

## Application Architecture

### Reactive Structure

The app uses Shiny's reactive programming model:

```r
# Reactive values
current_list <- reactiveVal(NULL)    # Selected list ID
current_task <- reactiveVal(NULL)    # Selected task ID
sidebar_collapsed <- reactiveVal(FALSE)

# Reactive expression
current_list_tasks <- reactive({
  if (is.null(current_list())) return(NULL)
  all_lists[[current_list()]]
})
```

### Three-Panel Layout

1. **Left Sidebar** - List selection (collapsible)
   - Lists 1-7 with progress bars
   - Overall progress summary card
   - Home button to reset view

2. **Main Content** - Task display area
   - Dynamic navbar with task navigation
   - Tabbed content (Treść/Kod/Wynik)
   - Welcome screen when no task selected

3. **Right Sidebar** - Task selection within list
   - Numbered task list
   - Completion status indicators (checkmark icons)
   - Current list name header

## Styling System

### CSS Loading Order

CSS files are loaded in **specific order** for proper cascading (see app.Rmd:36-45):

```r
css_order <- c(
  "css/main.css",           # 1. Base styles
  "css/header.css",         # 2. Hero header
  "css/navbar.css",         # 3. Navigation
  "css/layout.css",         # 4. Layout grid
  "css/left-sidebar.css",   # 5. Left panel
  "css/right-sidebar.css",  # 6. Right panel
  "css/progress-card.css",  # 7. Progress UI
  "css/main-content.css"    # 8. Content area
)
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
- `.app-container` - Main layout container
- `.left-sidebar` / `.right-sidebar` - Side panels
- `.main-content` - Central content area
- `.code-block` - Code display blocks
- `.code-output` - Execution output blocks
- `.task-item` / `.list-item` - Navigation items
- `.progress-bar-container-vertical` - Progress indicators

## Development Workflow

### Setting Up the Environment

```r
# 1. Open RStudio and load the project
# Double-click wne_pna.Rproj

# 2. Restore R package environment
renv::restore()

# 3. Run the Shiny app
# Click "Run App" button in RStudio
# Or use: shiny::runApp()
# Or from command line: R -e "shiny::runApp()"
```

### Adding a New Task

**Simple Task (Auto-Generated):**

```bash
# 1. Create task directory
mkdir -p tasks/list1/task11

# 2. Add content
cat > tasks/list1/task11/content.txt << 'EOF'
<h2>Zadanie 11: Nowe zadanie</h2>
<p>Opis zadania...</p>
EOF

# 3. Add solution (optional)
cat > tasks/list1/task11/code.txt << 'EOF'
# Rozwiązanie
x <- 1:10
mean(x)
EOF

# 4. Reload app - task appears automatically!
```

**Complex Task (Manual):**

```r
# tasks/list1/task12/task.R

create_task <- function() {
  list(
    content = page_navbar(
      title = "",
      id = "task_tabs",
      nav_panel(
        title = "Treść",
        div(
          class = "task-tab-content-simple",
          h2("Custom Task"),
          p("Custom content...")
        )
      )
    ),
    completed = FALSE,
    name = "Custom Task Name"  # Optional
  )
}
```

### Modifying CSS

1. **Identify the appropriate CSS file** based on the component
2. **Edit the file** - changes apply immediately on reload
3. **Test across different screen sizes** (responsive design)
4. **Maintain the color scheme** consistency

### Adding New R Dependencies

```r
# In R console
renv::install("package_name")

# Update lockfile
renv::snapshot()
```

## R Code Conventions

### Code Style (from .Rproj)

- **Indentation:** 2 spaces (not tabs)
- **Encoding:** UTF-8
- **Line endings:** Unix-style (LF)

### Naming Conventions

- **Functions:** `snake_case` (e.g., `create_code_output_tabs`)
- **Variables:** `snake_case` (e.g., `current_list`, `task_id`)
- **Lists:** `list1`, `list2`, ... `list7`
- **Tasks:** `task1`, `task2`, ... `taskN`

### Common Patterns

**Creating Task Tabs:**
```r
# Pattern 1: Simple code/output
create_code_output_tabs(
  code = "x <- 1:10\nmean(x)",
  code_tab_title = "Kod",
  output_tab_title = "Wynik"
)

# Pattern 2: Multiple exercises with shared environment
create_multi_code_tabs(
  exercises = list(
    list(title = "A)", code = "x <- 1:10"),
    list(title = "B)", code = "mean(x)")  # uses x from A)
  )
)
```

**HTML in content.txt:**
```html
<h2>Zadanie X: Tytuł</h2>
<p>Opis...</p>
<ol style="list-style-type: lower-alpha">
  <li>Podpunkt a)</li>
  <li>Podpunkt b)</li>
</ol>
<code>kod_inline</code>
<strong>Uwaga:</strong>
```

## Git Workflow

### Branch Naming Convention

- **Feature branches:** `claude/claude-md-{session-id}`
- **Main branch:** (not specified - check with `git branch`)

### Git Operations Guidelines

**Pushing:**
- Always use: `git push -u origin <branch-name>`
- Branch must start with `claude/` and match session ID
- Retry on network errors: up to 4 times with exponential backoff (2s, 4s, 8s, 16s)

**Fetching/Pulling:**
- Prefer specific branches: `git fetch origin <branch-name>`
- Retry on network errors: up to 4 times with exponential backoff

**Committing:**
- Use descriptive commit messages in Polish or English
- Follow conventional format: "Add task X to list Y" or "Update CSS styling"

## AI Assistant Guidelines

### When Working on This Codebase

1. **Always check task organization** before adding tasks
   - Use auto-generation for simple tasks (content.txt + code.txt)
   - Use manual mode (task.R) only for complex layouts

2. **Preserve the Polish language** in:
   - Task descriptions (content.txt files)
   - UI labels and buttons
   - Comments in R code (optional but preferred)
   - Commit messages (Polish or English acceptable)

3. **Maintain CSS consistency**
   - Load CSS files in the specified order
   - Use the established color scheme
   - Test responsive behavior

4. **R code execution**
   - Use `execute_code()` for automatic output generation
   - Leverage shared environments for multi-part exercises
   - Follow the three-tier labeling system (cat > comments > auto)

5. **Dependencies**
   - Always update `renv.lock` after adding packages
   - Use `renv::install()` and `renv::snapshot()`

6. **Testing**
   - Test task loading with `load_all_tasks()`
   - Check progress calculations with `get_list_stats()`
   - Verify UI rendering in browser

7. **File modifications**
   - Read existing files before editing
   - Preserve formatting and indentation (2 spaces)
   - Maintain UTF-8 encoding

### Common Tasks for AI Assistants

**Adding a new task to a list:**
```bash
# 1. Create directory structure
mkdir -p tasks/list2/task18

# 2. Create content.txt with task description
# 3. Create code.txt with solution (optional)
# 4. Reload app to see changes
```

**Updating task completion status:**
- Add or remove `code.txt` file
- OR modify `create_task()` to set `completed = TRUE/FALSE`

**Fixing broken tasks:**
1. Check task directory structure
2. Verify `content.txt` exists and has valid HTML
3. Check `code.txt` for syntax errors
4. Review error messages in R console

**Modifying UI layout:**
1. Identify the component (header, sidebar, content)
2. Edit the corresponding CSS file in `www/css/`
3. For structural changes, edit `app.R` (ui or server sections)
4. Test in browser

### Key Files to Reference

| File | Purpose | When to Modify |
|------|---------|----------------|
| `app.R` | Main Shiny application (UI + Server) | Changing layout, adding features, modifying reactivity |
| `tasks/helpers.R` | Display functions | Changing code/output rendering |
| `tasks/task_loader.R` | Task loading | Changing task organization |
| `www/css/*.css` | Styling | Changing appearance |
| `renv.lock` | Dependencies | After adding packages |
| `manifest.json` | Deployment | Changing Shiny Server config |

### Warning: Do Not Modify

- `.git/` directory contents
- `renv/` directory contents (managed by renv)
- `.Rprofile` (unless changing renv configuration)
- File encoding (must stay UTF-8)

## Deployment

The application is configured for **Shiny Server** deployment via `manifest.json`.

**Key Settings:**
- Runtime: Shiny
- R Version: 4.5.2
- Package Manager: renv

**Deployment Steps:**
1. Ensure `renv.lock` is up to date
2. Commit all changes
3. Push to deployment server
4. Shiny Server reads `manifest.json` and restores environment

## Troubleshooting

### Task Not Loading

- **Check:** Does `content.txt` exist?
- **Check:** Is the task directory named correctly? (`taskN` format)
- **Check:** Are there R syntax errors in `code.txt` or `task.R`?
- **Solution:** Review console output for error messages

### CSS Not Applying

- **Check:** Is the CSS file in the correct order in `css_order`?
- **Check:** Are there syntax errors in the CSS file?
- **Solution:** Clear browser cache and reload

### Code Output Not Displaying

- **Check:** Does the code have syntax errors?
- **Check:** Is `auto_execute = TRUE` in `create_code_output_tabs()`?
- **Solution:** Test code in R console first

### Package Installation Fails

- **Check:** Is the package name correct?
- **Check:** Is CRAN repository accessible?
- **Solution:** Use `renv::install("package", repos = "https://cran.r-project.org")`

## Additional Resources

- **Shiny Documentation:** https://shiny.rstudio.com/
- **R Markdown Guide:** https://rmarkdown.rstudio.com/
- **bslib Package:** https://rstudio.github.io/bslib/
- **renv Documentation:** https://rstudio.github.io/renv/

---

**Last Updated:** 2025-11-22
**Repository:** derealizacjaaa/wne_pna
**Current Branch:** claude/claude-md-miaq6a6vfckupui9-01Jead37LZox8k923nxytkCF
