# File-Based Task System Guide

## 🎯 Overview

The new file-based task system lets you create tasks using **numbered .txt files** instead of defining tabs in code. The system automatically builds navbar tabs from your files based on their names.

**Key Benefits:**
- ✅ No R coding needed for most tasks
- ✅ Intuitive file naming determines tab order
- ✅ Easy multi-part exercises (2a, 2b, 2c)
- ✅ All files are simple .txt format
- ✅ Auto-generates tabs, code display, and execution

---

## 📁 File Naming Convention

### **Pattern: `{order}{subtask}_{type}.txt`**

- **order**: Number (1, 2, 3, ...) - determines tab position left-to-right
- **subtask**: Letter (a, b, c, ...) - optional, for multiple blocks in same tab
- **type**: content, code, execute, or plot

### **Examples:**

```
1_content.txt       → Tab 1: "Treść" (HTML content)
2_code.txt          → Tab 2: "Kod" (display R code)
2a_code.txt         → Tab 2: "Kod" (Exercise A)
2b_code.txt         → Tab 2: "Kod" (Exercise B, auto-separated)
3_execute.txt       → Tab 3: "Wynik" (execute code + output)
4_plot.txt          → Tab 4: "Wykres" (execute code with plot)
```

---

## 📂 Task Structure

### **Simple Task (3 tabs)**

```
tasks/list1/task1/
  ├── 1_content.txt      # Tab 1: Task description (HTML)
  ├── 2_code.txt         # Tab 2: Display R code
  └── 3_execute.txt      # Tab 3: Execute code and show output
```

**Result:**
- Tab 1: "Treść" - task description
- Tab 2: "Kod" - syntax-highlighted code
- Tab 3: "Wynik" - executed output

### **Multi-Part Exercise (same tab)**

```
tasks/list1/task2/
  ├── 1_content.txt      # Tab 1: Instructions
  ├── 2a_code.txt        # Tab 2: Exercise A
  ├── 2b_code.txt        # Tab 2: Exercise B (auto-separated with header)
  ├── 2c_code.txt        # Tab 2: Exercise C
  └── 3_execute.txt      # Tab 3: Execute all
```

**Result:**
- Tab 1: "Treść"
- Tab 2: "Kod" with three sections:
  ```
  A)
  [code from 2a_code.txt]

  B)
  [code from 2b_code.txt]

  C)
  [code from 2c_code.txt]
  ```
- Tab 3: "Wynik" - execution output

### **Task with Plot**

```
tasks/list1/task3/
  ├── 1_content.txt      # Task description
  ├── 2_code.txt         # Code to display
  └── 3_plot.txt         # Execute code that creates plot
```

---

## 🔧 File Types

### **1. `*_content.txt` (HTML Content)**

Raw HTML displayed as-is in the tab.

**Example (1_content.txt):**
```html
<h2>Zadanie 1: Podstawy R</h2>

<p>W tym zadaniu nauczysz się:</p>
<ul>
  <li>Tworzyć wektory</li>
  <li>Obliczać statystyki</li>
  <li>Generować wykresy</li>
</ul>

<h3>Zadanie:</h3>
<ol style="list-style-type: lower-alpha">
  <li>Utwórz wektor liczb od 1 do 100</li>
  <li>Oblicz średnią i odchylenie standardowe</li>
  <li>Narysuj wykres</li>
</ol>
```

### **2. `*_code.txt` (Display Code)**

R code displayed with syntax highlighting. **Not executed**, just shown.

**Example (2_code.txt):**
```r
# Tworzenie wektora
numbers <- 1:100

# Obliczanie statystyk
mean(numbers)     # Średnia
sd(numbers)       # Odchylenie standardowe
```

**Renders as:**
- Syntax-highlighted code block
- Gray background, red left border
- Monospace font

### **3. `*_execute.txt` (Execute & Show Output)**

R code that is **executed automatically** and output is displayed.

**Example (3_execute.txt):**
```r
# Wykonanie obliczeń
x <- 1:100
cat("Średnia:", mean(x), "\n")
cat("Suma:", sum(x), "\n")
cat("Mediana:", median(x), "\n")
```

**Output:**
```
Średnia: 50.5
Suma: 5050
Mediana: 50.5
```

**Features:**
- Auto-executes on load
- Captures text output
- Smart labeling (auto-detects `mean()`, `sd()`, etc.)
- Supports `cat()` for custom labels

### **4. `*_plot.txt` (Execute & Show Plot)**

R code that creates a plot. **Executed automatically**, plot is embedded.

**Example (4_plot.txt):**
```r
# Wykres funkcji kwadratowej
x <- seq(-10, 10, length.out = 100)
y <- x^2
plot(x, y, type = "l", col = "blue",
     main = "f(x) = x²", xlab = "x", ylab = "y")
```

**Output:**
- Embedded PNG image
- Auto-sized to fit container
- Border and shadow styling

---

## 🎨 Tab Titles (Auto-Generated)

| Order | Primary Type | Tab Title |
|-------|--------------|-----------|
| 1 | any | "Treść" |
| any | content | "Treść" |
| any | code | "Kod" |
| any | execute | "Wynik" |
| any | plot | "Wykres" |

---

## ⚙️ How It Works

### **Loading Process**

1. **App starts** → `load_all_tasks()` runs
2. **For each task folder:**
   - Check for `task.R` (manual mode) → use if exists
   - Check for numbered `.txt` files → use new file-based system
   - Check for `content.txt` + `code.txt` → use old auto-generation
3. **File-based builder:**
   - Find all `*.txt` files
   - Parse filenames: `{order}{subtask}_{type}.txt`
   - Group by order number
   - Sort subtasks alphabetically (a, b, c)
   - Build tabs from grouped files
4. **Auto-generate navbar** with tabs

### **Example Parsing**

**Files:**
```
1_content.txt
2a_code.txt
2b_code.txt
3_execute.txt
```

**Parsed:**
```
File: 1_content.txt   → order=1, subtask="main", type="content"
File: 2a_code.txt     → order=2, subtask="a",    type="code"
File: 2b_code.txt     → order=2, subtask="b",    type="code"
File: 3_execute.txt   → order=3, subtask="main", type="execute"
```

**Grouped by order:**
```
Order 1: [1_content.txt]
Order 2: [2a_code.txt, 2b_code.txt]
Order 3: [3_execute.txt]
```

**Result:**
- **Tab 1:** "Treść" (content)
- **Tab 2:** "Kod" (code, 2 subtasks: A and B)
- **Tab 3:** "Wynik" (execute)

---

## 🚀 Quick Start Examples

### **Example 1: Simple Task (1 solution)**

```bash
mkdir -p tasks/list1/task15

# 1. Content
cat > tasks/list1/task15/1_content.txt << 'EOF'
<h2>Zadanie 15: Podstawy wektorów</h2>
<p>Utwórz wektor liczb od 1 do 50 i oblicz jego sumę.</p>
EOF

# 2. Code
cat > tasks/list1/task15/2_code.txt << 'EOF'
# Utworzenie wektora
numbers <- 1:50

# Suma elementów
sum(numbers)
EOF

# 3. Execution
cat > tasks/list1/task15/3_execute.txt << 'EOF'
numbers <- 1:50
cat("Suma:", sum(numbers), "\n")
EOF

# Done! Reload app to see it.
```

### **Example 2: Multi-Part Exercise**

```bash
mkdir -p tasks/list1/task16

# Content
cat > tasks/list1/task16/1_content.txt << 'EOF'
<h2>Zadanie 16: Statystyki opisowe</h2>
<p>Dla wektora liczb od 1 do 100:</p>
<ol style="list-style-type: lower-alpha">
  <li>Oblicz średnią</li>
  <li>Oblicz odchylenie standardowe</li>
  <li>Oblicz medianę</li>
</ol>
EOF

# Exercise A
cat > tasks/list1/task16/2a_code.txt << 'EOF'
# Utworzenie wektora
x <- 1:100

# Obliczenie średniej
mean(x)
EOF

# Exercise B
cat > tasks/list1/task16/2b_code.txt << 'EOF'
# Odchylenie standardowe
sd(x)
EOF

# Exercise C
cat > tasks/list1/task16/2c_code.txt << 'EOF'
# Mediana
median(x)
EOF

# Execution
cat > tasks/list1/task16/3_execute.txt << 'EOF'
x <- 1:100
cat("A) Średnia:", mean(x), "\n")
cat("B) Odchylenie:", sd(x), "\n")
cat("C) Mediana:", median(x), "\n")
EOF
```

### **Example 3: Plot Task**

```bash
mkdir -p tasks/list1/task17

# Content
cat > tasks/list1/task17/1_content.txt << 'EOF'
<h2>Zadanie 17: Wykres funkcji</h2>
<p>Narysuj wykres funkcji y = sin(x) dla x ∈ [-2π, 2π]</p>
EOF

# Code
cat > tasks/list1/task17/2_code.txt << 'EOF'
# Przygotowanie danych
x <- seq(-2*pi, 2*pi, length.out = 200)
y <- sin(x)

# Wykres
plot(x, y, type = "l", col = "red",
     main = "Funkcja sinus",
     xlab = "x", ylab = "sin(x)")
abline(h = 0, lty = 2, col = "gray")
EOF

# Plot execution
cat > tasks/list1/task17/3_plot.txt << 'EOF'
x <- seq(-2*pi, 2*pi, length.out = 200)
y <- sin(x)
plot(x, y, type = "l", col = "red",
     main = "Funkcja sinus",
     xlab = "x", ylab = "sin(x)")
abline(h = 0, lty = 2, col = "gray")
EOF
```

---

## 🔄 Migration from Old System

### **Old System (content.txt + code.txt)**

```
tasks/list1/task1/
  ├── content.txt
  └── code.txt
```

### **New System (numbered files)**

```
tasks/list1/task1/
  ├── 1_content.txt     (rename from content.txt)
  ├── 2_code.txt        (add - display code)
  └── 3_execute.txt     (rename from code.txt)
```

**Migration Script:**

```bash
# For each old task
cd tasks/list1/task1

# Rename content
mv content.txt 1_content.txt

# Split code.txt into display and execution
cp code.txt 2_code.txt
mv code.txt 3_execute.txt
```

---

## 🎯 Best Practices

### **1. Always start with `1_content.txt`**

Your first file should always be the content/instructions.

### **2. Use subtasks (a, b, c) for related exercises**

If you have multiple related code blocks, use subtasks:
- `2a_code.txt`, `2b_code.txt`, `2c_code.txt`

### **3. Separate display from execution**

- `2_code.txt` → Show the code (for reference)
- `3_execute.txt` → Execute and show output

### **4. Use descriptive file types**

Choose the right type for your content:
- `content` - HTML instructions
- `code` - R code to display
- `execute` - R code to run
- `plot` - R code that creates plots

### **5. Keep files simple**

Each file should contain one clear piece of content.

---

## 🛠️ Advanced Features

### **Custom Tab Ordering**

Want content → plot → code? Easy!

```
tasks/list1/task/
  ├── 1_content.txt      # Tab 1
  ├── 2_plot.txt         # Tab 2
  └── 3_code.txt         # Tab 3
```

### **Mixed Content Types**

You can mix types freely:

```
tasks/list1/task/
  ├── 1_content.txt      # Instructions
  ├── 2a_code.txt        # Show code part 1
  ├── 2b_execute.txt     # Execute part 2
  └── 3_plot.txt         # Plot
```

### **HTML in Content Files**

Full HTML support:

```html
<h2>Zadanie</h2>
<p>Opis z <strong>pogrubieniem</strong> i <em>kursywą</em></p>

<pre><code>
inline_code <- "example"
</code></pre>

<table>
  <tr><th>X</th><th>Y</th></tr>
  <tr><td>1</td><td>2</td></tr>
</table>
```

---

## 📊 Comparison: Old vs New

| Feature | Old System | New File-Based System |
|---------|------------|----------------------|
| **Files** | content.txt + code.txt | Numbered .txt files |
| **Tab Control** | Automatic (fixed 3 tabs) | You control order |
| **Multi-exercises** | Requires task.R | Use 2a, 2b, 2c |
| **Code display** | Combined with execution | Separate files |
| **Flexibility** | Low | High |
| **Learning curve** | Very easy | Easy |
| **Maintenance** | Easy | Very easy |

---

## 🐛 Troubleshooting

### **Task not loading**

✅ Check filename format: `{number}{letter}_{type}.txt`
✅ Must have at least `1_content.txt`
✅ File types: content, code, execute, plot

### **Tabs in wrong order**

✅ Check order numbers (1, 2, 3, ...)
✅ Subtasks: a before b before c

### **Code not executing**

✅ Use `*_execute.txt` or `*_plot.txt` (not `*_code.txt`)
✅ Check for syntax errors in R code

### **Subtasks not showing**

✅ Use same order number: `2a_`, `2b_`, `2c_`
✅ Subtask must be lowercase letter

---

## 📝 Summary

**New file-based task system:**

✅ **Simple** - Just create numbered .txt files
✅ **Flexible** - Control tab order and content
✅ **Intuitive** - Filename = tab structure
✅ **Powerful** - Multi-exercises, plots, execution
✅ **Maintainable** - Easy to edit and update

**Quick checklist for new task:**

1. Create folder: `tasks/listN/taskM/`
2. Add `1_content.txt` (HTML instructions)
3. Add `2_code.txt` (display R code)
4. Add `3_execute.txt` (execute R code)
5. Optional: `4_plot.txt` (plots)
6. Reload app → Task appears!

**That's it! No R programming needed for most tasks.** 🎉

---

## 🔗 Related Documentation

- **CLAUDE.md** - Overall project guide
- **REBUILD_NOTES.md** - Modular architecture overview
- **DYNAMIC_LISTS_GUIDE.md** - List auto-discovery system

**Created:** 2025-11-30
**Version:** 2.0 (File-Based System)
