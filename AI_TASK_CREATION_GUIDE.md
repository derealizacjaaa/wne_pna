# AI Assistant Guide: Creating V3 Tasks

**Quick reference for AI assistants (Claude, ChatGPT, Gemini, etc.) on how to create tasks in this R Shiny educational app**

---

## Overview

This app uses **V3 inline functions** to create educational programming tasks. Tasks are text files containing HTML and special R functions.

### Key Concepts

- **One task = one folder** with numbered `.txt` files
- **File names = tab titles**: `1_tresc.txt` → "Treść" tab
- **Mix HTML with inline functions** for rich educational content
- **Shared environment** across all code execution in a task

---

## File Naming Convention

```
tasks/list1/task5/
  ├── 1_tresc.txt           # Tab 1: "Treść" (content)
  ├── 2_rozwiazanie.txt     # Tab 2: "Rozwiązanie" (solution)
  └── 3_przyklad.txt        # Tab 3: "Przyklad" (example)
```

**Rules:**
- Start with number: `1_`, `2_`, `3_`, etc. (determines tab order)
- After underscore: tab title (will be capitalized: `tresc` → "Treść")
- Extension: always `.txt`
- Subtasks: use letters `2a_`, `2b_` (both go in same tab)

---

## Inline Functions

### `code(...)`
**Display R code with syntax highlighting (not executed)**

```html
<p>Here's the code:</p>

code(
x <- 1:10
mean(x)
)
```

**When to use:** Show code examples, display syntax, teaching code structure

---

### `execute(...)`
**Execute R code and display output**

```html
<p>Let's calculate the mean:</p>

execute(
x <- 1:10
cat("Mean:", mean(x), "\n")
cat("Sum:", sum(x), "\n")
)
```

**Output labeling (automatic priority):**
1. `cat()` statements (highest priority)
2. `# Comments` in code
3. Auto-generated labels (lowest priority)

**When to use:** Show computational results, demonstrate R output

---

### `plot(...)`
**Execute R code and display plots**

```html
<p>Visualization:</p>

plot(
x <- 1:10
barplot(x, col = "steelblue", main = "Data visualization")
)
```

**When to use:** Create graphs, charts, visualizations

---

### `run(...)`
**Execute R code silently (no output displayed)**

```html
run(
# Load libraries
library(ggplot2)
library(dplyr)

# Define helper function
my_function <- function(x) {
  x^2 + 2*x + 1
}

# Load data
data <- read.csv("data.csv")
)

<p>Now we can use the loaded data:</p>

execute(
summary(data)
)
```

**When to use:** Setup code, load libraries, define functions, prepare data

**Important:** Variables/functions defined in `run()` are available in all subsequent blocks!

---

## Shared Environment

**All inline functions share the same R environment within a task!**

```html
run(
x <- 1:100
)

execute(
# x is available here!
cat("Mean of x:", mean(x), "\n")
)

plot(
# x is still available here!
hist(x)
)
```

This enables **multi-step analyses** where each block builds on previous ones.

---

## HTML Elements

### Headings

```html
<h1>Main Task Title</h1>
<h2>Section Title</h2>
<h3>Subsection</h3>
<h4>Minor Heading</h4>
```

**Styling:**
- `<h1>`: Red accent (#b1404f), thick bottom border
- `<h2>`: Red left border
- `<h3>`: Lighter red left border
- `<h4>`: No border

---

### Text Formatting

```html
<p>Regular paragraph text.</p>
<p>Use <strong>bold</strong> for emphasis.</p>
<p>Use <em>italic</em> for subtle emphasis.</p>
<p>Inline code: <code>mean(x)</code></p>
```

---

### Lists

```html
<ul>
  <li>First item</li>
  <li>Second item</li>
  <li>Third item</li>
</ul>

<ol>
  <li>Step 1</li>
  <li>Step 2</li>
  <li>Step 3</li>
</ol>
```

---

### Content Boxes

**4 box types available:**

#### Info Box (Blue)
```html
<div class="info-box">
  <h4>Information</h4>
  <p>Helpful tip or additional context.</p>
</div>
```

#### Success Box (Green)
```html
<div class="success-box">
  <h4>Success!</h4>
  <p>Expected result or correct answer confirmation.</p>
</div>
```

#### Definition Box (Red border)
```html
<div class="definition-box">
  <h4>Definition: Vector</h4>
  <p>A vector is an ordered collection of elements of the same type.</p>
</div>
```

#### Example Box (Gray, flexible width)
```html
<div class="example-box">
  <h4>Example</h4>
  <p>Consider the vector: <code>x <- c(1, 2, 3)</code></p>
  <p>The mean is 2.</p>
</div>
```

**Note:** Example boxes adjust to content width and center automatically.

---

### Mathematical Formulas

**Inline math:** `$formula$`

```html
<p>The mean is calculated as $\bar{x} = \frac{1}{n}\sum_{i=1}^{n} x_i$</p>
```

**Display math (centered):** `$$formula$$`

```html
<p>Standard deviation formula:</p>

$$
s = \sqrt{\frac{1}{n-1}\sum_{i=1}^{n}(x_i - \bar{x})^2}
$$
```

**Common LaTeX:**
- Fractions: `\frac{a}{b}`
- Summation: `\sum_{i=1}^{n}`
- Square root: `\sqrt{x}`
- Greek letters: `\alpha, \beta, \mu, \sigma`
- Subscripts/superscripts: `x_i, x^2`

---

### Tables

```html
<table>
  <thead>
    <tr>
      <th>Function</th>
      <th>Description</th>
      <th>Example</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <td><code>mean()</code></td>
      <td>Calculate mean</td>
      <td><code>mean(c(1,2,3))</code></td>
    </tr>
    <tr>
      <td><code>sd()</code></td>
      <td>Standard deviation</td>
      <td><code>sd(c(1,2,3))</code></td>
    </tr>
  </tbody>
</table>
```

**Styling:** Red header, alternating row colors, hover effect

---

## Complete Task Example

```html
<h1>Task 5: Descriptive Statistics</h1>

<p>In this task we'll learn basic statistical measures in R.</p>

<div class="info-box">
  <h4>Dataset</h4>
  <p>We'll use the built-in <code>mtcars</code> dataset.</p>
</div>

<h2>Part A: Basic Calculations</h2>

<p>The arithmetic mean is defined as:</p>

$$
\bar{x} = \frac{1}{n}\sum_{i=1}^{n} x_i
$$

<p>Let's load the data first:</p>

run(
data(mtcars)
mpg_data <- mtcars$mpg
)

<p>Now calculate basic statistics:</p>

execute(
cat("Mean MPG:", mean(mpg_data), "\n")
cat("Median MPG:", median(mpg_data), "\n")
cat("Std Dev:", sd(mpg_data), "\n")
)

<div class="success-box">
  <h4>Expected Result</h4>
  <p>Mean should be approximately <strong>20.09</strong></p>
</div>

<h2>Part B: Visualization</h2>

<p>Create a histogram:</p>

plot(
hist(mpg_data,
     main = "Distribution of MPG",
     xlab = "Miles per gallon",
     ylab = "Frequency",
     col = "steelblue",
     border = "white")
)

<div class="definition-box">
  <h4>Definition: Histogram</h4>
  <p>A histogram displays the distribution of a continuous variable by dividing data into bins.</p>
</div>

<h2>Summary</h2>

<p>You've learned:</p>

<ol>
  <li>How to calculate basic statistics with <code>mean()</code> and <code>sd()</code></li>
  <li>How to create histograms with <code>hist()</code></li>
  <li>How to interpret statistical results</li>
</ol>
```

---

## Best Practices for AI Assistants

### ✅ DO:

1. **Start with clear structure** - Use H1 for main title, H2 for sections
2. **Mix explanations with code** - Don't just show code, explain concepts
3. **Use `run()` for setup** - Load libraries and data invisibly
4. **Use appropriate boxes** - Info for tips, Success for results, Definition for concepts
5. **Label outputs clearly** - Use `cat()` for explicit output labels
6. **Build progressively** - Each code block can use variables from previous blocks
7. **Add mathematical notation** - Use LaTeX for formulas when teaching statistics
8. **Keep filenames simple** - `1_tresc.txt`, `2_rozwiazanie.txt`, etc.

### ❌ DON'T:

1. **Don't repeat setup code** - Use `run()` once at the beginning
2. **Don't forget the shared environment** - Variables persist across blocks
3. **Don't use deprecated classes** - Only use: info-box, success-box, definition-box, example-box
4. **Don't put code in HTML** - Use inline functions instead
5. **Don't create full-width boxes for small content** - example-box adjusts to content
6. **Don't skip explanations** - This is educational content, explain concepts
7. **Don't use manual task.R files** - Use V3 inline functions instead

---

## Common Patterns

### Pattern 1: Theory + Practice

```html
<h2>Theory</h2>
<p>Explanation of concept...</p>
$$formula$$

<h2>Practice</h2>
<p>Let's apply it:</p>
execute(...)
```

### Pattern 2: Step-by-Step Analysis

```html
run(
# Setup
library(dplyr)
data <- load_data()
)

<h3>Step 1: Data Cleaning</h3>
execute(
data_clean <- data %>% filter(!is.na(value))
cat("Rows after cleaning:", nrow(data_clean), "\n")
)

<h3>Step 2: Analysis</h3>
execute(
result <- data_clean %>% summarise(mean = mean(value))
print(result)
)

<h3>Step 3: Visualization</h3>
plot(
ggplot(data_clean, aes(x = value)) + geom_histogram()
)
```

### Pattern 3: Multiple Examples

```html
<div class="example-box">
  <h4>Example 1</h4>
  <p>Simple case:</p>
  execute(
  x <- c(1, 2, 3)
  cat("Mean:", mean(x), "\n")
  )
</div>

<div class="example-box">
  <h4>Example 2</h4>
  <p>With missing values:</p>
  execute(
  y <- c(1, 2, NA, 4)
  cat("Mean (removing NA):", mean(y, na.rm = TRUE), "\n")
  )
</div>
```

---

## File Structure Template

When creating a new task, use this structure:

```
tasks/list[N]/task[M]/
  └── 1_tresc.txt
```

**Minimal task (1_tresc.txt):**
```html
<h1>Task [M]: [Title]</h1>

<p>[Description of the task]</p>

<h2>Solution</h2>

<p>[Explanation]</p>

execute(
# Your code here
)

<div class="success-box">
  <h4>Expected Output</h4>
  <p>[What the student should see]</p>
</div>
```

---

## Quick Reference Card

| Element | Syntax | Purpose |
|---------|--------|---------|
| Display code | `code(...)` | Show R code without execution |
| Execute code | `execute(...)` | Run code, show output |
| Create plot | `plot(...)` | Run code, show visualization |
| Silent execution | `run(...)` | Setup without output |
| Inline math | `$...$` | Formula in text |
| Display math | `$$...$$` | Centered formula |
| Info box | `<div class="info-box">` | Tips, context |
| Success box | `<div class="success-box">` | Correct results |
| Definition | `<div class="definition-box">` | Formal definitions |
| Example | `<div class="example-box">` | Example cases |
| Inline code | `<code>...</code>` | Function/variable names |

---

## Troubleshooting

**Problem:** Code in `execute()` shows no output
**Solution:** Use explicit `cat()` or `print()` statements

**Problem:** Variables not available in later blocks
**Solution:** Check that earlier code executed successfully (use `run()` or `execute()`)

**Problem:** Math formulas not rendering
**Solution:** Ensure proper `$...$` or `$$...$$` delimiters, check LaTeX syntax

**Problem:** Box not displaying correctly
**Solution:** Check class name spelling, ensure proper `<div>` structure

**Problem:** Task not loading
**Solution:** Check filename pattern (`N_title.txt`), verify folder is named `taskN`

---

**Last Updated:** 2025-12-06
**Version:** 1.0
**For:** V3 Task System
