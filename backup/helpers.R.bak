# ============================================
# HELPER FUNCTIONS FOR CODE BLOCKS
# University Tasks Hub - Code Display System
# ============================================

# 1. Function to create code block
code_block <- function(code, language = "r", padding = "15px") {
  # Remove leading and trailing empty lines
  lines <- strsplit(code, "\n")[[1]]
  
  # Remove empty lines from start
  while(length(lines) > 0 && grepl("^\\s*$", lines[1])) {
    lines <- lines[-1]
  }
  
  # Remove empty lines from end
  while(length(lines) > 0 && grepl("^\\s*$", lines[length(lines)])) {
    lines <- lines[-length(lines)]
  }
  
  # Join back
  code <- paste(lines, collapse = "\n")
  
  tags$pre(
    class = "code-block",
    style = sprintf(
      "background: #f8f9fa; padding: %s; border-left: 4px solid #b1404f; border-radius: 4px; overflow-x: auto; font-family: 'Courier New', monospace; font-size: 0.9em; margin: 15px 0; white-space: pre;",
      padding
    ),
    tags$code(
      class = paste0("language-", language),
      style = "display: block; margin: 0; padding: 0;",
      code
    )
  )
}

# 2. Function to create output block (with plot support)
code_output <- function(output) {
  # Check if output is a list (with plots)
  if (is.list(output) && !is.null(names(output)) && "plots" %in% names(output)) {
    
    content <- list()
    
    # Add text output if exists
    if (!is.null(output$text) && nzchar(output$text)) {
      content <- c(content, list(
        tags$pre(
          class = "code-output",
          style = "background: #ffffff; padding: 15px; border: 1px solid #dee2e6; border-left: 4px solid #28a745; border-radius: 4px; overflow-x: auto; font-family: 'Courier New', monospace; font-size: 0.9em; margin: 15px 0; color: #333; white-space: pre;",
          output$text
        )
      ))
    }
    
    # Add plots
    if (length(output$plots) > 0) {
      for (plot_file in output$plots) {
        if (file.exists(plot_file)) {
          # Read plot and convert to base64
          plot_data <- readBin(plot_file, "raw", file.info(plot_file)$size)
          plot_base64 <- base64enc::base64encode(plot_data)
          
          content <- c(content, list(
            tags$div(
              style = "margin: 15px 0; text-align: center;",
              tags$img(
                src = paste0("data:image/png;base64,", plot_base64),
                style = "max-width: 100%; height: auto; border: 1px solid #dee2e6; border-radius: 4px; box-shadow: 0 2px 4px rgba(0,0,0,0.1);"
              )
            )
          ))
        }
      }
    }
    
    return(div(content))
    
  } else {
    # Simple text output (backward compatibility)
    tags$pre(
      class = "code-output",
      style = "background: #ffffff; padding: 15px; border: 1px solid #dee2e6; border-left: 4px solid #28a745; border-radius: 4px; overflow-x: auto; font-family: 'Courier New', monospace; font-size: 0.9em; margin: 15px 0; color: #333; white-space: pre;",
      output
    )
  }
}

# 3. Execute R code with smart output formatting including plots
# Supports three methods:
# - OPTION 1: cat() in code (highest priority - full user control)
# - OPTION 2: Comments as labels (medium priority - user hints)
# - OPTION 3: Automatic labels (lowest priority - smart defaults)
execute_code <- function(code, use_auto_labels = TRUE, use_comments = TRUE, envir = NULL) {
  # Use provided environment or create new one
  if (is.null(envir)) {
    envir <- new.env(parent = parent.frame())
  }

  tryCatch({
    output_text <- c()
    plot_files <- c()

    # Create temporary directory for plots
    temp_dir <- tempdir()

    lines <- strsplit(code, "\n")[[1]]

    for (line_idx in seq_along(lines)) {
      line <- lines[line_idx]

      # Skip empty lines
      if (nzchar(trimws(line)) == FALSE) next

      # Extract comment if present (OPTION 2)
      comment_match <- regmatches(line, regexpr("#.*$", line))
      line_code <- trimws(sub("#.*$", "", line))

      # Skip if only comment
      if (nzchar(line_code) == FALSE) next

      # Check if this line might create a plot
      creates_plot <- grepl("plot\\(|curve\\(|ggplot\\(|hist\\(|barplot\\(|boxplot\\(|pie\\(|pairs\\(|matplot\\(",
                            line_code, ignore.case = TRUE)

      if (creates_plot) {
        # Capture plot
        plot_file <- file.path(temp_dir, paste0("plot_", line_idx, "_", Sys.time() %>% as.numeric(), ".png"))
        png(plot_file, width = 450, height = 300, res = 90)

        # Execute the plotting code in the provided environment
        result <- eval(parse(text = line_code), envir = envir)

        dev.off()

        # Check if plot was actually created
        if (file.exists(plot_file) && file.size(plot_file) > 0) {
          plot_files <- c(plot_files, plot_file)
        }
      } else {
        # Regular code execution (non-plot)
        text_output <- capture.output({
          result <- eval(parse(text = line_code), envir = envir)

          is_assignment <- grepl("<-|=|->", line_code)

          if (!is.null(result) && !is_assignment) {
            # OPTION 1: If code contains cat() or print(), it's already handled
            if (!grepl("cat\\(|print\\(", line_code)) {

              # OPTION 2: Use comment as label (if available and enabled)
              if (use_comments && length(comment_match) > 0) {
                label <- sub("^#\\s*", "", comment_match)
                cat(label, result, "\n")
              }
              # OPTION 3: Automatic smart labels (if enabled)
              else if (use_auto_labels) {
                # Try to extract function name
                func_match <- regexpr("^[a-zA-Z_][a-zA-Z0-9_]*\\(", line_code)

                if (func_match > 0) {
                  func_name <- substr(line_code, 1, attr(func_match, "match.length") - 1)

                  # Create readable labels based on function
                  label <- switch(func_name,
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
                                  "names" = "Nazwy:",
                                  paste0(func_name, ":")
                  )
                  cat(label, result, "\n")
                } else {
                  # No function detected, just print
                  print(result)
                }
              } else {
                # No labeling, just print
                print(result)
              }
            }
          }
        })

        if (length(text_output) > 0) {
          output_text <- c(output_text, text_output)
        }
      }
    }

    # Return list with both text and plot files
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

# 4. Create tabs with automatic output generation
# Main function - executes code and creates two nav_panel tabs
create_code_output_tabs <- function(code, 
                                    code_tab_title = "Kod",
                                    output_tab_title = "Wynik",
                                    language = "r",
                                    auto_execute = TRUE,
                                    use_auto_labels = TRUE,
                                    use_comments = TRUE) {
  
  # Generate output automatically if requested
  if (auto_execute && language == "r") {
    output <- execute_code(code, use_auto_labels, use_comments)
  } else {
    output <- "Output not generated (set auto_execute = TRUE)"
  }
  
  list(
    nav_panel(
      title = code_tab_title,
      div(
        style = "padding: 20px;",
        code_block(code, language)
      )
    ),
    nav_panel(
      title = output_tab_title,
      div(
        style = "padding: 20px;",
        code_output(output)
      )
    )
  )
}

# 5. Create tabs with multiple code blocks (for exercises with sub-tasks)
# One "Kod" tab with all code blocks, one "Wynik" tab with all outputs
# Uses shared environment between code blocks so variables persist
create_multi_code_tabs <- function(exercises,
                                   code_tab_title = "Kod",
                                   output_tab_title = "Wynik") {

  # Create shared environment for all exercises
  shared_env <- new.env()

  # Collect all code blocks
  all_code_blocks <- lapply(seq_along(exercises), function(i) {
    ex <- exercises[[i]]

    # Title for this subtask
    title <- if (!is.null(ex$title)) ex$title else paste0("Podpunkt ", i)

    div(
      style = "margin-bottom: 30px;",
      h3(title, style = "color: #b1404f; border-bottom: 2px solid #b1404f; padding-bottom: 5px; margin-bottom: 15px;"),
      if (!is.null(ex$description)) p(ex$description, style = "margin-bottom: 15px; color: #606060;"),
      code_block(ex$code, language = if (!is.null(ex$language)) ex$language else "r")
    )
  })

  # Collect all output blocks - executing code in SHARED environment
  all_output_blocks <- lapply(seq_along(exercises), function(i) {
    ex <- exercises[[i]]

    # Execute code in shared environment using the main execute_code function
    output <- execute_code(ex$code, use_auto_labels = TRUE, use_comments = TRUE, envir = shared_env)

    # Title for this subtask
    title <- if (!is.null(ex$title)) ex$title else paste0("Podpunkt ", i)

    div(
      style = "margin-bottom: 30px;",
      h3(title, style = "color: #28a745; border-bottom: 2px solid #28a745; padding-bottom: 5px; margin-bottom: 15px;"),
      code_output(output)
    )
  })

  # Return two tabs
  list(
    nav_panel(
      title = code_tab_title,
      div(style = "padding: 20px;", all_code_blocks)
    ),
    nav_panel(
      title = output_tab_title,
      div(style = "padding: 20px;", all_output_blocks)
    )
  )
}

# ============================================
# AUTO-GENERATION FUNCTION
# Creates basic task from content.txt and code.txt
# ============================================

auto_generate_basic_task <- function(task_dir) {
  # Check if required files exist
  content_file <- file.path(task_dir, "content.txt")
  code_file <- file.path(task_dir, "code.txt")

  # Content.txt is required
  if (!file.exists(content_file)) {
    return(NULL)
  }

  # Read content
  content_text <- paste(readLines(content_file, warn = FALSE), collapse = "\n")

  # Check if code.txt exists
  has_code <- file.exists(code_file) && file.info(code_file)$size > 0

  if (has_code) {
    # SCENARIO 2: Content + Code → 3 tabs (Treść/Kod/Wynik), completed = TRUE
    code_text <- paste(readLines(code_file, warn = FALSE), collapse = "\n")

    # Create code/output tabs using existing helper
    code_output_tabs <- create_code_output_tabs(
      code = code_text,
      code_tab_title = "Kod",
      output_tab_title = "Wynik",
      language = "r",
      auto_execute = TRUE
    )

    # Create task tabs: Treść, Kod, Wynik
    task_tabs <- list(
      nav_panel(
        title = "Treść",
        div(
          class = "task-tab-content-simple",
          HTML(content_text)
        )
      ),
      code_output_tabs[[1]],  # Code tab
      code_output_tabs[[2]]   # Output tab
    )

    # Create navbar content
    content <- page_navbar(
      title = "",
      id = "task_tabs",
      !!!task_tabs
    )

    # Return task structure (completed = TRUE since code is provided)
    list(
      content = content,
      completed = TRUE,
      auto_generated = TRUE
    )

  } else {
    # SCENARIO 1: Content only → Single tab (Treść), completed = FALSE
    content <- page_navbar(
      title = "",
      id = "task_tabs",
      nav_panel(
        title = "Treść",
        div(
          class = "task-tab-content-simple",
          HTML(content_text)
        )
      )
    )

    # Return task structure (uncompleted - awaiting solution)
    list(
      content = content,
      completed = FALSE,
      auto_generated = TRUE
    )
  }
}

# End of helpers.R