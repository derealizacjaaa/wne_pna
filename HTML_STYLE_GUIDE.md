# HTML Style Guide for V3 Tasks

**Comprehensive guide to standardized HTML elements for creating beautiful, consistent task content**

---

## Table of Contents

1. [Headings](#headings)
2. [Text Formatting](#text-formatting)
3. [Lists](#lists)
4. [Callout Boxes](#callout-boxes)
5. [Special Content Boxes](#special-content-boxes)
6. [Mathematical Formulas](#mathematical-formulas)
7. [Tables](#tables)
8. [Other Elements](#other-elements)
9. [Complete Example](#complete-example)

---

## Headings

### Main Title (H1) - Red accent with bottom border

```html
<h1>Zadanie 1: Wprowadzenie do wektorów</h1>
```

**Use for:** Main task title, primary heading

**Styling:** Red color (#b1404f), bold, thick bottom border

---

### Subtitle (H2) - Dark gray with red left border

```html
<h2>Część A: Tworzenie wektorów</h2>
```

**Use for:** Major sections within a task

**Styling:** Dark gray text, red left border accent

---

### Sub-subtitle (H3) - Medium gray with lighter red accent

```html
<h3>Krok 1: Inicjalizacja danych</h3>
```

**Use for:** Subsections, steps within a major section

**Styling:** Medium gray text, lighter red left border

---

### Small Heading (H4)

```html
<h4>Uwaga techniczna</h4>
```

**Use for:** Minor headings, notes, technical details

**Styling:** Dark gray, smaller font, no border

---

## Text Formatting

### Paragraphs

```html
<p>To jest zwykły akapit tekstu z wyjaśnieniem koncepcji.</p>
```

**Styling:** Standard text, comfortable line spacing (1.6)

---

### Inline Code

```html
<p>Użyj funkcji <code>mean()</code> do obliczenia średniej.</p>
```

**Use for:** Function names, variable names, short code snippets in text

**Styling:** Red text, light gray background, monospace font

---

### Bold Text

```html
<p><strong>Ważne:</strong> Zawsze sprawdzaj typ danych!</p>
```

**Use for:** Emphasis, important terms

---

### Italic Text

```html
<p><em>Uwaga:</em> Ten krok jest opcjonalny.</p>
```

**Use for:** Subtle emphasis, notes, foreign words

---

## Lists

### Unordered List

```html
<ul>
  <li>Pierwszy element listy</li>
  <li>Drugi element listy</li>
  <li>Trzeci element listy</li>
</ul>
```

---

### Ordered List

```html
<ol>
  <li>Najpierw zrób to</li>
  <li>Potem zrób tamto</li>
  <li>Na końcu to</li>
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
  <li>Kolejny główny punkt</li>
</ol>
```

---

## Callout Boxes

### Info Box (Blue)

```html
<div class="info-box">
  <h4>Informacja</h4>
  <p>To jest przydatna informacja dla studenta.</p>
</div>
```

**Use for:** Helpful tips, additional information, context

**Styling:** Light blue background, blue left border

---

### Warning Box (Orange/Yellow)

```html
<div class="warning-box">
  <h4>Uwaga!</h4>
  <p>Upewnij się, że dane są prawidłowo wczytane przed kontynuowaniem.</p>
</div>
```

**Use for:** Warnings, cautions, things to watch out for

**Styling:** Light yellow background, orange left border

---

### Success Box (Green)

```html
<div class="success-box">
  <h4>Świetnie!</h4>
  <p>Jeśli otrzymałeś ten wynik, zadanie jest wykonane poprawnie.</p>
</div>
```

**Use for:** Success messages, correct answers, achievements

**Styling:** Light green background, green left border

---

### Error Box (Red)

```html
<div class="error-box">
  <h4>Błąd!</h4>
  <p>Ten kod zwróci błąd, ponieważ...</p>
</div>
```

**Use for:** Common errors, mistakes to avoid, error explanations

**Styling:** Light red background, red left border

---

## Special Content Boxes

### Definition Box

```html
<div class="definition-box">
  <h4>Definicja: Wektor</h4>
  <p>Wektor to uporządkowany zbiór elementów tego samego typu.</p>
</div>
```

**Use for:** Formal definitions, key concepts, terminology

**Styling:** Light gray background, red border all around

---

### Example Box

```html
<div class="example-box">
  <h4>Przykład</h4>
  <p>Rozważmy wektor: <code>x <- c(1, 2, 3, 4, 5)</code></p>
  <p>Średnia to: 3</p>
</div>
```

**Use for:** Examples, demonstrations, sample cases

**Styling:** Light gray background, gray left border

---

### Note Box

```html
<div class="note-box">
  <h4>Notatka</h4>
  <p>Pamiętaj, że R jest case-sensitive!</p>
</div>
```

**Use for:** Side notes, reminders, quick tips

**Styling:** Light yellow/cream background, yellow left border

---

## Mathematical Formulas

### Inline Math

Use single dollar signs `$...$` for math within text:

```html
<p>Średnia arytmetyczna to $\bar{x} = \frac{1}{n}\sum_{i=1}^{n} x_i$</p>
```

**Alternative:** `\(...\)` also works for inline math.

---

### Display Math (Block)

Use double dollar signs `$$...$$` for centered math blocks:

```html
<p>Wzór na odchylenie standardowe:</p>

$$
s = \sqrt{\frac{1}{n-1}\sum_{i=1}^{n}(x_i - \bar{x})^2}
$$
```

**Alternative:** `\[...\]` also works for display math.

---

### Common Mathematical Notation

```html
<!-- Fractions -->
$\frac{a}{b}$

<!-- Subscripts and superscripts -->
$x_i$, $x^2$, $x_i^2$

<!-- Greek letters -->
$\alpha$, $\beta$, $\gamma$, $\mu$, $\sigma$, $\pi$

<!-- Summation -->
$\sum_{i=1}^{n} x_i$

<!-- Integral -->
$\int_{a}^{b} f(x) dx$

<!-- Square root -->
$\sqrt{x}$, $\sqrt[n]{x}$

<!-- Matrices -->
$$
\begin{bmatrix}
1 & 2 & 3 \\
4 & 5 & 6 \\
7 & 8 & 9
\end{bmatrix}
$$

<!-- Statistical notation -->
$\bar{x}$ (mean), $\hat{\beta}$ (estimator), $x \sim N(\mu, \sigma^2)$ (distribution)
```

---

## Tables

```html
<table>
  <thead>
    <tr>
      <th>Zmienna</th>
      <th>Typ</th>
      <th>Opis</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <td><code>x</code></td>
      <td>numeric</td>
      <td>Wektor liczb</td>
    </tr>
    <tr>
      <td><code>y</code></td>
      <td>character</td>
      <td>Wektor tekstowy</td>
    </tr>
    <tr>
      <td><code>z</code></td>
      <td>logical</td>
      <td>Wektor logiczny</td>
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
  <p>"To jest cytat lub ważna informacja."</p>
</blockquote>
```

**Use for:** Quotes, highlighted information, excerpts

---

### Horizontal Rule

```html
<hr>
```

**Use for:** Separating major sections

---

### Links

```html
<p>Więcej informacji znajdziesz w <a href="https://www.r-project.org/">dokumentacji R</a>.</p>
```

**Styling:** Red color, underline on hover

---

### Images

```html
<img src="path/to/image.png" alt="Opis obrazu">
```

**With caption:**

```html
<figure>
  <img src="path/to/image.png" alt="Wykres rozkładu">
  <figcaption>Rysunek 1: Rozkład normalny</figcaption>
</figure>
```

---

### Keyboard Keys

```html
<p>Naciśnij <kbd>Ctrl</kbd> + <kbd>Enter</kbd> aby wykonać kod.</p>
```

---

### Abbreviations

```html
<p><abbr title="Analysis of Variance">ANOVA</abbr> jest testem statystycznym.</p>
```

---

## Complete Example

Here's a comprehensive example showing multiple elements together:

```html
<h1>Zadanie 3: Analiza opisowa danych</h1>

<p>W tym zadaniu nauczymy się podstawowych metod analizy opisowej w R.</p>

<div class="info-box">
  <h4>Informacja</h4>
  <p>Będziemy pracować z wbudowanym zbiorem danych <code>mtcars</code>.</p>
</div>

<h2>Część A: Podstawowe statystyki</h2>

<p>Podstawowe miary statystyczne to:</p>

<ul>
  <li><strong>Średnia arytmetyczna:</strong> $\bar{x} = \frac{1}{n}\sum_{i=1}^{n} x_i$</li>
  <li><strong>Mediana:</strong> wartość środkowa w uporządkowanym zbiorze</li>
  <li><strong>Odchylenie standardowe:</strong> miara rozproszenia danych</li>
</ul>

<div class="definition-box">
  <h4>Definicja: Średnia arytmetyczna</h4>
  <p>Średnia arytmetyczna to suma wszystkich wartości podzielona przez ich liczbę.</p>
</div>

<h3>Krok 1: Wczytanie danych</h3>

<p>Najpierw załadujmy dane:</p>

code(
# Wczytanie wbudowanego zbioru danych
data(mtcars)
head(mtcars)
)

<h3>Krok 2: Obliczenia</h3>

<p>Teraz obliczymy podstawowe statystyki dla zmiennej <code>mpg</code> (mile per gallon):</p>

execute(
# Średnia
mean_mpg <- mean(mtcars$mpg)
cat("Średnia MPG:", mean_mpg, "\n")

# Mediana
median_mpg <- median(mtcars$mpg)
cat("Mediana MPG:", median_mpg, "\n")

# Odchylenie standardowe
sd_mpg <- sd(mtcars$mpg)
cat("Odchylenie standardowe:", sd_mpg, "\n")
)

<div class="success-box">
  <h4>Oczekiwany wynik</h4>
  <p>Średnia MPG powinna wynosić około 20.09</p>
</div>

<h2>Część B: Wizualizacja</h2>

<p>Stwórzmy histogram przedstawiający rozkład zmiennej MPG:</p>

plot(
hist(mtcars$mpg,
     main = "Rozkład zużycia paliwa",
     xlab = "Mile per gallon",
     ylab = "Częstość",
     col = "steelblue",
     border = "white")
)

<div class="warning-box">
  <h4>Uwaga!</h4>
  <p>Upewnij się, że dane <code>mtcars</code> są załadowane przed wykonaniem wykresu.</p>
</div>

<h2>Podsumowanie</h2>

<p>W tym zadaniu nauczyłeś się:</p>

<ol>
  <li>Obliczać podstawowe statystyki opisowe</li>
  <li>Tworzyć histogramy w R</li>
  <li>Interpretować wyniki analizy</li>
</ol>

<div class="note-box">
  <h4>Do zapamiętania</h4>
  <p>Zawsze wizualizuj dane przed przystąpieniem do zaawansowanych analiz!</p>
</div>
```

---

## Best Practices

### Content Organization

1. **Start with H1** - One main title per task
2. **Use H2 for major sections** - Divide task into logical parts
3. **Use H3 for steps** - Break down complex procedures
4. **Use boxes sparingly** - Only for important information
5. **Balance text and code** - Mix explanations with practical examples

### Accessibility

1. **Use semantic HTML** - `<h1>`, `<h2>`, `<p>`, `<ul>`, etc.
2. **Provide alt text** - Always include `alt` attribute for images
3. **Logical heading hierarchy** - Don't skip heading levels
4. **Descriptive links** - Avoid "click here", use descriptive text

### Consistency

1. **Polish language** - Use consistent Polish terminology
2. **Formatting** - Stick to established patterns
3. **Code style** - Use `code()`, `execute()`, `plot()` appropriately
4. **Box usage** - Use correct box type for the message

---

## Quick Reference Table

| Element | HTML | Purpose |
|---------|------|---------|
| Main title | `<h1>` | Task title |
| Section | `<h2>` | Major sections |
| Subsection | `<h3>` | Steps, subsections |
| Paragraph | `<p>` | Regular text |
| Inline code | `<code>` | Function/variable names |
| Bold | `<strong>` | Emphasis |
| Italic | `<em>` | Subtle emphasis |
| Info | `<div class="info-box">` | Helpful information |
| Warning | `<div class="warning-box">` | Cautions |
| Success | `<div class="success-box">` | Correct results |
| Error | `<div class="error-box">` | Common mistakes |
| Definition | `<div class="definition-box">` | Formal definitions |
| Example | `<div class="example-box">` | Examples |
| Note | `<div class="note-box">` | Side notes |
| Inline math | `$...$` | Math in text |
| Display math | `$$...$$` | Centered equations |
| List | `<ul>` or `<ol>` | Lists |
| Table | `<table>` | Tabular data |

---

## Tips for Mathematical Formulas

### Common Statistics Formulas

```html
<!-- Mean -->
$\bar{x} = \frac{1}{n}\sum_{i=1}^{n} x_i$

<!-- Variance -->
$s^2 = \frac{1}{n-1}\sum_{i=1}^{n}(x_i - \bar{x})^2$

<!-- Standard deviation -->
$s = \sqrt{s^2}$

<!-- Correlation -->
$r = \frac{\sum(x_i - \bar{x})(y_i - \bar{y})}{\sqrt{\sum(x_i - \bar{x})^2 \sum(y_i - \bar{y})^2}}$

<!-- Linear regression -->
$y = \beta_0 + \beta_1 x + \epsilon$

<!-- Normal distribution -->
$X \sim N(\mu, \sigma^2)$

<!-- Probability -->
$P(A|B) = \frac{P(B|A)P(A)}{P(B)}$
```

### Escaping Special Characters

If you need a literal dollar sign, escape it:

```html
<p>This costs \$100</p>
```

---

**Last Updated:** 2025-12-05
**Version:** 1.0
**See Also:** TASK_SYSTEM_V3_GUIDE.md, FILE_BASED_TASKS_GUIDE.md
