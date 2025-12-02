# Task System V3 Guide - Inline Functions

## 🎯 Overview

**Version 3** of the file-based task system uses **inline functions** inside .txt files instead of type-based filenames.

**Key Innovation:**
- **Filename = Tab title** (e.g., `2_rozwiazanie.txt` → Tab: "Rozwiązanie")
- **Content = Mixed HTML + R functions** (`code(...)`, `execute(...)`, `plot(...)`)

---

## 📁 File Naming

### **Pattern: `{order}{subtask}_{title}.txt`**

- **order**: Number (1, 2, 3, ...) - tab position left-to-right
- **subtask**: Letter (a, b, c, ...) - optional, groups in same tab
- **title**: Tab title (e.g., "rozwiazanie" → "Rozwiązanie")

### **Examples:**

```
1_tresc.txt           → Tab: "Treść"
2_rozwiazanie.txt     → Tab: "Rozwiązanie"
2a_przyklad.txt       → Tab: "Przyklad" (subtask A)
2b_przyklad.txt       → Tab: "Przyklad" (subtask B)
3_wykres.txt          → Tab: "Wykres"
4_dodatkowe.txt       → Tab: "Dodatkowe"
```

**Tab title formatting:**
- First letter automatically capitalized
- `rozwiazanie` → "Rozwiazanie"
- `kod` → "Kod"
- `wynik` → "Wynik"

---

## 🔧 Inline Functions

Inside .txt files, use special functions to control rendering:

### **1. `code(...)`** - Display R Code

Shows R code with syntax highlighting. **Not executed**.

```
code(
# Utworzenie wektora
x <- 1:10
mean(x)
)
```

**Result:** Syntax-highlighted code block (gray background, red border)

### **2. `execute(...)`** - Execute & Show Output

Executes R code and displays the output.

```
execute(
x <- 1:100
cat("Średnia:", mean(x), "\n")
cat("Suma:", sum(x), "\n")
)
```

**Result:**
```
Średnia: 50.5
Suma: 5050
```

### **3. `plot(...)`** - Execute & Show Plot

Executes R code that creates a plot and embeds it.

```
plot(
x <- seq(-10, 10, length.out = 100)
y <- x^2
plot(x, y, type = "l", col = "blue")
)
```

**Result:** Embedded PNG image of the plot

### **4. Plain HTML** - Display As-Is

Any text outside of functions is treated as HTML:

```html
<h3>Introduction</h3>
<p>This is a <strong>paragraph</strong> with HTML.</p>
<ul>
  <li>Item 1</li>
  <li>Item 2</li>
</ul>
```

---

## 🎨 Mixing Content Types

**The power of V3:** Mix HTML and R functions in the same file!

**Example file (`2_rozwiazanie.txt`):**

```html
<h3>Rozwiązanie zadania</h3>

<p>Najpierw utworzymy wektor:</p>

code(
numbers <- 1:50
)

<p>Teraz obliczymy średnią:</p>

execute(
numbers <- 1:50
cat("Średnia:", mean(numbers), "\n")
)

<p>I narysujemy histogram:</p>

plot(
numbers <- 1:50
hist(numbers, col = "lightblue", main = "Histogram")
)

<p>Gotowe!</p>
```

**Result:** One tab with mixed HTML text, code display, execution output, and plot!

---

## 📂 Task Structure Examples

### **Example 1: Simple Task**

```
tasks/list1/task1/
  ├── 1_tresc.txt
  └── 2_rozwiazanie.txt
```

**1_tresc.txt:**
```html
<h2>Zadanie 1: Podstawy R</h2>
<p>Oblicz średnią liczb od 1 do 100.</p>
```

**2_rozwiazanie.txt:**
```html
<p>Rozwiązanie:</p>

code(
x <- 1:100
mean(x)
)

<p>Wynik:</p>

execute(
x <- 1:100
cat("Średnia:", mean(x))
)
```

**Result:** 2 tabs - "Treść" and "Rozwiązanie"

### **Example 2: Multi-Part Exercise**

```
tasks/list1/task2/
  ├── 1_tresc.txt
  ├── 2a_rozwiazanie.txt
  ├── 2b_rozwiazanie.txt
  └── 3_wykres.txt
```

**2a_rozwiazanie.txt:**
```html
<p>Część A: Utworzenie wektora</p>

execute(
x <- 1:20
print(x)
)
```

**2b_rozwiazanie.txt:**
```html
<p>Część B: Statystyki</p>

execute(
x <- 1:20
cat("Średnia:", mean(x), "\n")
cat("Odchylenie:", sd(x), "\n")
)
```

**Result:**
- Tab 1: "Treść"
- Tab 2: "Rozwiązanie" with sections A) and B)
- Tab 3: "Wykres"

### **Example 3: Complex Mixed Content**

```
tasks/list1/task3/
  ├── 1_wprowadzenie.txt
  ├── 2_teoria.txt
  └── 3_praktyka.txt
```

**3_praktyka.txt:**
```html
<h3>Przykład praktyczny</h3>

<p>Poniższy kod pokazuje jak obliczyć odchylenie standardowe:</p>

code(
data <- c(12, 15, 18, 20, 22, 25, 28)
sd_value <- sd(data)
)

<p>Wykonajmy to:</p>

execute(
data <- c(12, 15, 18, 20, 22, 25, 28)
cat("Dane:", paste(data, collapse = ", "), "\n")
cat("Odchylenie standardowe:", round(sd(data), 2), "\n")
)

<p>Wizualizacja:</p>

plot(
data <- c(12, 15, 18, 20, 22, 25, 28)
barplot(data, col = "steelblue",
        main = "Dane", ylab = "Wartość")
abline(h = mean(data), col = "red", lwd = 2)
)

<p><em>Czerwona linia pokazuje średnią.</em></p>
```

**Result:** One tab with narrative text, code display, execution, and plot all mixed together!

---

## 🚀 Quick Start

### **Create a New Task (2 minutes)**

```bash
# 1. Create folder
mkdir -p tasks/list1/task25

# 2. Content
cat > tasks/list1/task25/1_tresc.txt << 'EOF'
<h2>Zadanie 25: Wektor i statystyki</h2>
<p>Utwórz wektor liczb od 1 do 50 i oblicz średnią oraz medianę.</p>
EOF

# 3. Solution with mixed content
cat > tasks/list1/task25/2_rozwiazanie.txt << 'EOF'
<h3>Rozwiązanie</h3>

<p>Utworzenie wektora:</p>

code(
numbers <- 1:50
)

<p>Obliczanie statystyk:</p>

execute(
numbers <- 1:50
cat("Średnia:", mean(numbers), "\n")
cat("Mediana:", median(numbers), "\n")
)
EOF

# Done! Reload app.
```

---

## 💡 Advanced Features

### **Shared Variables Across Functions**

Variables defined in one function are available in the next (same file):

```
execute(
x <- 1:100
cat("Utworzono wektor x\n")
)

<p>Teraz użyjemy zmiennej x:</p>

execute(
cat("Średnia x:", mean(x), "\n")
)
```

**Works!** Variables persist within the same file.

### **Complex HTML Layouts**

```html
<div style="background: #f0f0f0; padding: 20px; border-radius: 8px;">
  <h3>Uwaga!</h3>
  <p>Poniższy kod jest <strong>bardzo ważny</strong>.</p>
</div>

code(
important_function <- function(x) {
  return(x^2 + 2*x + 1)
}
)
```

### **Multiple Code Blocks**

You can have as many function blocks as you want:

```
code(...)
execute(...)
code(...)
execute(...)
plot(...)
```

---

## 📊 Comparison: V2 vs V3

| Feature | V2 (Type in filename) | V3 (Inline functions) |
|---------|----------------------|----------------------|
| **Filename** | `2_code.txt` | `2_rozwiazanie.txt` |
| **Tab title** | Auto ("Kod") | From filename ("Rozwiązanie") |
| **Content** | Only R code | HTML + inline functions |
| **Mixing** | No | Yes! |
| **Flexibility** | Medium | Very High |
| **Best for** | Simple code display | Narrative + code |

---

## 🔄 Migration from V2

**V2 style:**
```
tasks/list1/task1/
  ├── 1_content.txt       (HTML only)
  ├── 2_code.txt          (R code only)
  └── 3_execute.txt       (R code only)
```

**V3 style:**
```
tasks/list1/task1/
  ├── 1_tresc.txt         (HTML only)
  └── 2_rozwiazanie.txt   (HTML + code(...) + execute(...))
```

**V3 combines multiple V2 files into one!**

**Migration example:**

**Old (V2):**

`2_code.txt`:
```r
x <- 1:10
mean(x)
```

`3_execute.txt`:
```r
x <- 1:10
cat("Mean:", mean(x))
```

**New (V3):**

`2_rozwiazanie.txt`:
```html
<p>Kod:</p>

code(
x <- 1:10
mean(x)
)

<p>Wynik:</p>

execute(
x <- 1:10
cat("Mean:", mean(x))
)
```

---

## 🎯 Best Practices

### **1. Use Descriptive Tab Titles**

```
2_rozwiazanie.txt     ✓ Clear
2_sol.txt             ✗ Cryptic
```

### **2. Structure Your Content**

Use headings to organize within tabs:

```html
<h3>Część 1: Podstawy</h3>
code(...)

<h3>Część 2: Zastosowanie</h3>
execute(...)
```

### **3. Add Explanations**

Don't just show code - explain it:

```html
<p>Poniższy kod oblicza średnią ruchomą:</p>

code(
moving_avg <- function(x, n) {
  filter(x, rep(1/n, n), sides = 2)
}
)

<p>Zastosujmy ją do naszych danych:</p>

execute(...)
```

### **4. Use `code()` Before `execute()`**

Show the code first, then execute:

```html
code(...)
<p>Wynik:</p>
execute(...)
```

### **5. Keep Functions Focused**

Don't put too much in one function:

```
code(
# Just show the function definition
calculate_stats <- function(x) {
  list(mean = mean(x), sd = sd(x))
}
)

execute(
# Use the function
data <- 1:100
stats <- calculate_stats(data)
print(stats)
)
```

---

## 🐛 Troubleshooting

### **Syntax in function blocks**

**Problem:** Code not rendering
**Solution:** Check parentheses balance in `code(...)`, `execute(...)`, `plot(...)`

**Wrong:**
```
code(
x <- c(1, 2, 3)
# Missing closing parenthesis
```

**Correct:**
```
code(
x <- c(1, 2, 3)
)
```

### **HTML not rendering**

**Problem:** HTML showing as text
**Solution:** HTML must be **outside** function blocks

**Wrong:**
```
code(
<p>This is HTML</p>
)
```

**Correct:**
```
<p>This is HTML</p>

code(
# R code here
)
```

### **Variables not found**

**Problem:** `Error: object 'x' not found`
**Solution:** Define variables in the same function block or earlier in the file

**Wrong:**
```
code(
x <- 1:10
)

execute(
mean(x)  # x not available!
)
```

**Correct:**
```
execute(
x <- 1:10
mean(x)  # x defined in same block
)
```

---

## 📝 Summary

**V3 System = Ultimate Flexibility**

✅ **Filenames = Tab titles** (full control)
✅ **Inline functions** (`code()`, `execute()`, `plot()`)
✅ **Mix HTML + R** in same file
✅ **Narrative + Code** together
✅ **Simple .txt files** (no R programming needed)

**Perfect for:**
- Educational content
- Step-by-step tutorials
- Complex exercises with explanations
- Tasks that need context

**Quick checklist:**

1. Create folder: `tasks/listN/taskM/`
2. Add `1_tresc.txt` (instructions)
3. Add `2_rozwiazanie.txt` (solution with inline functions)
4. Use `code(...)`, `execute(...)`, `plot(...)` inside files
5. Reload app → Task appears!

**No R programming, no complex setup - just text files with simple functions!** 🎉

---

## 🔗 Related Documentation

- **CLAUDE.md** - Project overview
- **FILE_BASED_TASKS_GUIDE.md** - V2 system (typed files)
- **REBUILD_NOTES.md** - Architecture overview

**Created:** 2025-11-30
**Version:** 3.0 (Inline Functions)
