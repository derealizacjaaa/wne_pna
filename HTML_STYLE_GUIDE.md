# HTML Style Guide for AI Assistants

**Quick reference for AI assistants creating HTML content in V3 task files**

---

## Purpose

This guide covers **HTML elements only**. For complete task creation including R code execution, see [AI_TASK_CREATION_GUIDE.md](AI_TASK_CREATION_GUIDE.md).

Use this guide when you need to format educational content with proper styling.

---

## Headings

### H1 - Main Task Title
**Styling:** Red (#b1404f), bold, thick bottom border

```html
<h1>Zadanie 5: Analiza danych</h1>
```

Use for: Main task title (one per file)

---

### H2 - Section Title
**Styling:** Dark gray, red left border

```html
<h2>Część A: Podstawy</h2>
```

Use for: Major sections within a task

---

### H3 - Subsection
**Styling:** Medium gray, lighter red left border

```html
<h3>Krok 1: Przygotowanie danych</h3>
```

Use for: Steps, subsections

---

### H4 - Minor Heading
**Styling:** Dark gray, no border

```html
<h4>Uwaga techniczna</h4>
```

Use for: Small headings, box titles

---

## Text Formatting

### Paragraph
```html
<p>Zwykły tekst akapitu.</p>
```

**Line spacing:** 1.6 for readability

---

### Inline Code
```html
<p>Użyj funkcji <code>mean()</code> do obliczenia średniej.</p>
```

**Styling:** Red text, light gray background, monospace font

Use for: Function names, variable names, short code snippets

---

### Bold Text
```html
<p><strong>Ważne:</strong> Sprawdź typ danych!</p>
```

Use for: Emphasis, important terms

---

### Italic Text
```html
<p><em>Uwaga:</em> Ten krok jest opcjonalny.</p>
```

Use for: Subtle emphasis, notes

---

## Lists

### Unordered List
```html
<ul>
  <li>Pierwszy element</li>
  <li>Drugi element</li>
  <li>Trzeci element</li>
</ul>
```

---

### Ordered List
```html
<ol>
  <li>Krok pierwszy</li>
  <li>Krok drugi</li>
  <li>Krok trzeci</li>
</ol>
```

---

### Nested Lists
```html
<ol>
  <li>Główny punkt
    <ul>
      <li>Podpunkt a)</li>
      <li>Podpunkt b)</li>
    </ul>
  </li>
  <li>Kolejny punkt</li>
</ol>
```

---

## Content Boxes (4 Types)

### 1. Info Box (Blue)
**Use for:** Tips, helpful information, context

```html
<div class="info-box">
  <h4>Informacja</h4>
  <p>Będziemy używać zbioru danych <code>mtcars</code>.</p>
</div>
```

**Styling:** Light blue background (#e7f3ff), blue left border

---

### 2. Success Box (Green)
**Use for:** Correct results, achievements, confirmations

```html
<div class="success-box">
  <h4>Świetnie!</h4>
  <p>Jeśli otrzymałeś ten wynik, zadanie jest poprawne.</p>
</div>
```

**Styling:** Light green background (#e8f5e9), green left border

---

### 3. Definition Box (Red border)
**Use for:** Formal definitions, key concepts, terminology

```html
<div class="definition-box">
  <h4>Definicja: Wektor</h4>
  <p>Wektor to uporządkowany zbiór elementów tego samego typu.</p>
</div>
```

**Styling:** Light gray background (#f9f9f9), red border all around

---

### 4. Example Box (Gray, flexible width)
**Use for:** Examples, demonstrations, sample cases

```html
<div class="example-box">
  <h4>Przykład</h4>
  <p>Rozważmy wektor: <code>x <- c(1, 2, 3)</code></p>
  <p>Średnia wynosi: 2</p>
</div>
```

**Styling:** Light gray background (#fafafa), gray left border
**Behavior:** Width adjusts to content, centered automatically

---

## Mathematical Formulas

### Inline Math
Use single dollar signs `$...$` for formulas within text:

```html
<p>Średnia to $\bar{x} = \frac{1}{n}\sum_{i=1}^{n} x_i$</p>
```

**Renders as:** The formula appears inline with the text

---

### Display Math (Centered)
Use double dollar signs `$$...$$` for centered formulas:

```html
<p>Wzór na odchylenie standardowe:</p>

$$
s = \sqrt{\frac{1}{n-1}\sum_{i=1}^{n}(x_i - \bar{x})^2}
$$
```

**Renders as:** Centered formula in display mode

---

### Common LaTeX Syntax

```html
<!-- Fractions -->
$\frac{a}{b}$

<!-- Subscripts and superscripts -->
$x_i$, $x^2$, $x_i^2$

<!-- Greek letters -->
$\alpha, \beta, \gamma, \mu, \sigma, \pi$

<!-- Summation -->
$\sum_{i=1}^{n} x_i$

<!-- Square root -->
$\sqrt{x}$

<!-- Statistical notation -->
$\bar{x}$ (mean)
$\hat{\beta}$ (estimator)
$X \sim N(\mu, \sigma^2)$ (distribution)
```

---

## Tables

```html
<table>
  <thead>
    <tr>
      <th>Funkcja</th>
      <th>Opis</th>
      <th>Przykład</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <td><code>mean()</code></td>
      <td>Średnia</td>
      <td><code>mean(c(1,2,3))</code></td>
    </tr>
    <tr>
      <td><code>sd()</code></td>
      <td>Odchylenie standardowe</td>
      <td><code>sd(c(1,2,3))</code></td>
    </tr>
  </tbody>
</table>
```

**Styling:** Red header, alternating row colors, hover effect

---

## Other Elements

### Blockquote
```html
<blockquote>
  <p>"Ważny cytat lub informacja."</p>
</blockquote>
```

**Styling:** Gray background, red left border, italic

---

### Horizontal Rule
```html
<hr>
```

Use for: Separating major sections

---

### Links
```html
<p>Zobacz <a href="https://www.r-project.org/">dokumentację R</a>.</p>
```

**Styling:** Red color, underline on hover

---

## Quick Reference Table

| Element | HTML | Purpose |
|---------|------|---------|
| Main title | `<h1>` | Task title |
| Section | `<h2>` | Major sections |
| Subsection | `<h3>` | Steps, details |
| Paragraph | `<p>` | Regular text |
| Inline code | `<code>` | Function/variable names |
| Bold | `<strong>` | Emphasis |
| Info box | `<div class="info-box">` | Tips, context |
| Success box | `<div class="success-box">` | Correct results |
| Definition | `<div class="definition-box">` | Definitions |
| Example | `<div class="example-box">` | Examples (flexible width) |
| Inline math | `$...$` | Math in text |
| Display math | `$$...$$` | Centered formulas |
| List | `<ul>` or `<ol>` | Lists |
| Table | `<table>` | Tabular data |

---

## Best Practices for AI

### ✅ DO:

1. **Use semantic headings** - H1 → H2 → H3 hierarchy
2. **Choose appropriate boxes** - Info for tips, Success for results, Definition for concepts
3. **Format code inline** - Use `<code>` for function names in text
4. **Use LaTeX for math** - Inline `$...$` or display `$$...$$`
5. **Keep example boxes concise** - They adjust to content width
6. **Structure content clearly** - Use headings to organize

### ❌ DON'T:

1. **Don't skip heading levels** - Go H1 → H2, not H1 → H3
2. **Don't use deleted boxes** - No warning-box, error-box, or note-box
3. **Don't put large content in example-box** - It centers, use regular content instead
4. **Don't forget closing tags** - Always close `<div>`, `<p>`, etc.
5. **Don't use deprecated classes** - Stick to the 4 box types
6. **Don't escape LaTeX in formulas** - Use `$\bar{x}$` not `$\\bar{x}$`

---

## Complete HTML Example

```html
<h1>Zadanie 3: Statystyki opisowe</h1>

<p>W tym zadaniu nauczymy się podstawowych miar statystycznych.</p>

<div class="info-box">
  <h4>Zbiór danych</h4>
  <p>Użyjemy wbudowanego zbioru <code>mtcars</code>.</p>
</div>

<h2>Część A: Podstawowe miary</h2>

<p>Średnia arytmetyczna jest zdefiniowana jako:</p>

$$
\bar{x} = \frac{1}{n}\sum_{i=1}^{n} x_i
$$

<p>Podstawowe miary to:</p>

<ul>
  <li><strong>Średnia:</strong> $\bar{x}$</li>
  <li><strong>Mediana:</strong> wartość środkowa</li>
  <li><strong>Odchylenie standardowe:</strong> $s$</li>
</ul>

<div class="definition-box">
  <h4>Definicja: Mediana</h4>
  <p>Mediana to wartość środkowa w uporządkowanym zbiorze danych.</p>
</div>

<h2>Część B: Przykład</h2>

<div class="example-box">
  <h4>Przykład obliczenia</h4>
  <p>Dla wektora <code>x = c(1, 2, 3, 4, 5)</code>:</p>
  <ul>
    <li>Średnia: 3</li>
    <li>Mediana: 3</li>
  </ul>
</div>

<div class="success-box">
  <h4>Sprawdzenie</h4>
  <p>Jeśli Twoje wyniki się zgadzają, rozwiązanie jest poprawne!</p>
</div>

<h2>Tabela funkcji</h2>

<table>
  <thead>
    <tr>
      <th>Funkcja</th>
      <th>Opis</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <td><code>mean()</code></td>
      <td>Średnia arytmetyczna</td>
    </tr>
    <tr>
      <td><code>median()</code></td>
      <td>Mediana</td>
    </tr>
    <tr>
      <td><code>sd()</code></td>
      <td>Odchylenie standardowe</td>
    </tr>
  </tbody>
</table>

<hr>

<blockquote>
  <p>"Zawsze wizualizuj dane przed analizą!"</p>
</blockquote>
```

---

## Common Patterns

### Pattern 1: Definition + Example
```html
<div class="definition-box">
  <h4>Definicja: [Pojęcie]</h4>
  <p>[Formalna definicja]</p>
</div>

<div class="example-box">
  <h4>Przykład</h4>
  <p>[Konkretny przykład]</p>
</div>
```

### Pattern 2: Steps with Success Check
```html
<h3>Krok 1: [Tytuł]</h3>
<p>[Wyjaśnienie]</p>

<h3>Krok 2: [Tytuł]</h3>
<p>[Wyjaśnienie]</p>

<div class="success-box">
  <h4>Oczekiwany wynik</h4>
  <p>[Jak powinien wyglądać prawidłowy wynik]</p>
</div>
```

### Pattern 3: Theory + Formula
```html
<h2>Teoria</h2>
<p>[Wyjaśnienie koncepcji]</p>

<p>Wzór matematyczny:</p>

$$
[formula]
$$

<div class="info-box">
  <h4>Interpretacja</h4>
  <p>[Jak rozumieć ten wzór]</p>
</div>
```

---

## Troubleshooting

**Problem:** Math not rendering
- Check dollar signs: `$...$` for inline, `$$...$$` for display
- Verify LaTeX syntax
- Don't escape backslashes in formulas

**Problem:** Box not styling correctly
- Check class name spelling: `info-box`, `success-box`, `definition-box`, `example-box`
- Ensure proper `<div>` structure with closing `</div>`
- Don't use deleted classes (warning-box, error-box, note-box)

**Problem:** Example box too wide
- That's normal - it takes full width for large content
- For narrow content, it auto-adjusts and centers

---

**Last Updated:** 2025-12-06
**Version:** 2.0 (Updated for 4-box system)
**See Also:** [AI_TASK_CREATION_GUIDE.md](AI_TASK_CREATION_GUIDE.md) for complete task creation
