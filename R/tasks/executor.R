# ============================================
# CODE EXECUTION ENGINE
# ============================================
# Functions for executing R code and capturing output

#' Generate smart label for output based on function name
#' @param line_code The code line to analyze
#' @return Character label or NULL
generate_auto_label <- function(line_code) {
  func_match <- regexpr("^[a-zA-Z_][a-zA-Z0-9_]*\\(", line_code)

  if (func_match <= 0) return(NULL)

  func_name <- substr(line_code, 1, attr(func_match, "match.length") - 1)

  label_map <- c(
    "mean" = "Średnia:",
    "sd" = "Odchylenie standardowe:",
    "var" = "Wariancja:",
    "median" = "Mediana:",
    "sum" = "Suma:",
    "min" = "Minimum:",
    "max" = "Maksimum:",
    "length" = "Długość:",
    "nrow" = "Liczba wierszy:",
    "ncol" = "Liczba kolumn:",
    "dim" = "Wymiary:",
    "head" = "Pierwsze wiersze:",
    "tail" = "Ostatnie wiersze:",
    "summary" = "Podsumowanie:",
    "cor" = "Korelacja:",
    "cov" = "Kowariancja:",
    "quantile" = "Kwantyle:",
    "range" = "Zakres:",
    "IQR" = "Rozstęp międzykwartylowy:",
    "table" = "Tabela częstości:",
    "unique" = "Unikalne wartości:",
    "class" = "Klasa:",
    "str" = "Struktura:",
    "names" = "Nazwy:"
  )

  if (func_name %in% names(label_map)) {
    return(label_map[[func_name]])
  }

  paste0(func_name, ":")
}

#' Check if code line creates a plot
#' @param line_code The code line to analyze
#' @return Logical
is_plotting_code <- function(line_code) {
  grepl("plot\\(|curve\\(|ggplot\\(|hist\\(|barplot\\(|boxplot\\(|pie\\(|pairs\\(|matplot\\(",
        line_code, ignore.case = TRUE)
}

#' Capture plot output from code execution
#' @param line_code Code to execute
#' @param line_idx Line index for unique filename
#' @param envir Environment to execute in
#' @return Plot file path or NULL
capture_plot <- function(line_code, line_idx, envir) {
  temp_dir <- tempdir()
  plot_file <- file.path(temp_dir, paste0("plot_", line_idx, "_", as.numeric(Sys.time()), ".png"))

  png(plot_file, width = 450, height = 300, res = 90)

  # Execute code and capture result
  result <- eval(parse(text = line_code), envir = envir)

  # ggplot objects need to be explicitly printed to render
  if (inherits(result, "ggplot")) {
    print(result)
  }

  dev.off()

  if (file.exists(plot_file) && file.size(plot_file) > 0) {
    return(plot_file)
  }

  NULL
}

#' Capture text output from code execution with smart labeling
#' @param line_code Code to execute
#' @param comment Comment from the code line (if any)
#' @param use_auto_labels Use automatic labels
#' @param use_comments Use comment as label
#' @param envir Environment to execute in
#' @return Character vector of output lines
capture_text_output <- function(line_code, comment, use_auto_labels, use_comments, envir) {
  capture.output({
    result <- eval(parse(text = line_code), envir = envir)
    is_assignment <- grepl("<-|=|->", line_code)

    if (!is.null(result) && !is_assignment) {
      # OPTION 1: cat() or print() in code - already handled
      if (grepl("cat\\(|print\\(", line_code)) {
        return()
      }

      # OPTION 2: Use comment as label
      if (use_comments && !is.null(comment) && nzchar(comment)) {
        label <- sub("^#\\s*", "", comment)
        cat(label, result, "\n")
        return()
      }

      # OPTION 3: Automatic smart labels
      if (use_auto_labels) {
        label <- generate_auto_label(line_code)
        if (!is.null(label)) {
          cat(label, result, "\n")
        } else {
          print(result)
        }
      } else {
        print(result)
      }
    }
  })
}

#' Execute R code with smart output formatting and plot support
#'
#' Supports three labeling methods (in priority order):
#' 1. cat() in code (highest priority - full user control)
#' 2. Comments as labels (medium priority - user hints)
#' 3. Automatic labels (lowest priority - smart defaults)
#'
#' @param code R code to execute
#' @param use_auto_labels Enable automatic labeling
#' @param use_comments Use comments as labels
#' @param envir Environment to execute in (NULL creates new)
#' @return List with text and plots elements
execute_code <- function(code, use_auto_labels = TRUE, use_comments = TRUE, envir = NULL) {
  # Use provided environment or create new one
  if (is.null(envir)) {
    envir <- new.env(parent = parent.frame())
  }

  tryCatch({
    output_text <- c()
    plot_files <- c()

    # Parse code into complete R expressions instead of splitting by lines
    # This handles multi-line expressions like ggplot2 with + operators
    exprs <- tryCatch({
      parse(text = code)
    }, error = function(e) {
      # If parsing fails, fall back to line-by-line
      return(NULL)
    })

    if (!is.null(exprs) && length(exprs) > 0) {
      # Execute each complete expression
      for (expr_idx in seq_along(exprs)) {
        expr_code <- deparse(exprs[[expr_idx]])
        expr_text <- paste(expr_code, collapse = "\n")

        # Check if this is plotting code
        if (is_plotting_code(expr_text)) {
          plot_file <- capture_plot(expr_text, expr_idx, envir)
          if (!is.null(plot_file)) {
            plot_files <- c(plot_files, plot_file)
          }
        } else {
          # Execute and capture output
          result <- capture.output({
            eval_result <- eval(exprs[[expr_idx]], envir = envir)
            if (!is.null(eval_result) && !inherits(eval_result, "ggplot")) {
              print(eval_result)
            }
          })
          if (length(result) > 0) {
            output_text <- c(output_text, result)
          }
        }
      }
    } else {
      # Fallback: process line by line (old behavior)
      lines <- strsplit(code, "\n")[[1]]

      for (line_idx in seq_along(lines)) {
        line <- lines[line_idx]

        # Skip empty lines
        if (!nzchar(trimws(line))) next

        # Extract comment and code
        comment <- regmatches(line, regexpr("#.*$", line))
        if (length(comment) == 0) comment <- NULL
        line_code <- trimws(sub("#.*$", "", line))

        # Skip comment-only lines
        if (!nzchar(line_code)) next

        # Handle plotting vs text output
        if (is_plotting_code(line_code)) {
          plot_file <- capture_plot(line_code, line_idx, envir)
          if (!is.null(plot_file)) {
            plot_files <- c(plot_files, plot_file)
          }
        } else {
          text_output <- capture_text_output(
            line_code, comment, use_auto_labels, use_comments, envir
          )
          if (length(text_output) > 0) {
            output_text <- c(output_text, text_output)
          }
        }
      }
    }

    list(
      text = paste(output_text, collapse = "\n"),
      plots = plot_files
    )

  }, error = function(e) {
    list(
      text = paste("Błąd:", e$message),
      plots = character(0)
    )
  })
}
