# ============================================
# FILE-BASED TASK BUILDER V3
# ============================================
# Builds tasks from numbered .txt files with inline functions
#
# File naming: {order}{subtask}_{title}.txt
#   order: 1, 2, 3, ... (tab position left-to-right)
#   subtask: a, b, c, ... (optional - groups in same tab)
#   title: Tab title in navbar (e.g., "rozwiazanie" → "Rozwiązanie")
#
# Inside files, use special functions:
#   code(...) - Display R code with syntax highlighting (not executed)
#   execute(...) - Execute R code and show output
#   plot(...) - Execute R code and show plot
#   run(...) - Execute R code silently without output (for setup/initialization)
#   Plain HTML/text - Display as-is
#
# Shared environment:
#   All execute(), plot(), and run() blocks across ALL TABS share the same environment
#   Variables and functions defined in one block are available in all subsequent blocks
#   This enables multi-step analyses spanning multiple tabs
#
# Examples:
#   1_tresc.txt           → Tab: "Treść"
#   2_rozwiazanie.txt     → Tab: "Rozwiązanie"
#   2a_przyklad.txt       → Tab: "Przyklad" (subtask A)
#   2b_przyklad.txt       → Tab: "Przyklad" (subtask B)
#   3_wykres.txt          → Tab: "Wykres"
# ============================================

#' Build task from numbered .txt files (V3)
#'
#' @param task_dir Path to task directory
#' @return Task structure or NULL
build_task_from_files_v3 <- function(task_dir) {
  # Find all .txt files
  files <- list.files(task_dir, pattern = "\\.txt$", full.names = TRUE)

  if (length(files) == 0) {
    return(NULL)
  }

  # Parse filenames
  file_info <- parse_task_files_v3(files)

  # Remove any NULL entries
  file_info <- Filter(Negate(is.null), file_info)

  if (length(file_info) == 0) {
    return(NULL)
  }

  # Check if this is V3 format (has titles instead of types)
  is_v3 <- all(sapply(file_info, function(f) !is.null(f$title)))

  if (!is_v3) {
    # Fall back to V2 builder
    return(NULL)
  }

  # Create a shared environment for the entire task
  # All execute(), plot(), and run() blocks across all tabs will share this environment
  task_env <- new.env(parent = .GlobalEnv)

  # Group files by tab order
  tabs <- create_tabs_from_files_v3(file_info, task_dir, task_env)

  # Build navbar with tabs
  content <- page_navbar(title = "", id = "task_tabs", !!!tabs)

  # Determine completion status (has execute, plot, or run blocks)
  completed <- any(sapply(file_info, function(f) {
    file_content <- paste(readLines(f$path, warn = FALSE), collapse = "\n")
    grepl("execute\\(|plot\\(|run\\(", file_content)
  }))

  list(
    content = content,
    completed = completed,
    auto_generated = TRUE,
    file_based_v3 = TRUE
  )
}

#' Parse task filenames (V3) into structured info
#'
#' @param files Vector of file paths
#' @return List of file info objects
parse_task_files_v3 <- function(files) {
  lapply(files, function(f) {
    basename_file <- basename(f)

    # Pattern V3: {order}{subtask}_{title}.txt
    # Examples: 1_tresc.txt, 2a_rozwiazanie.txt, 3_wykres.txt
    pattern <- "^(\\d+)([a-z]?)_(.+)\\.txt$"

    if (grepl(pattern, basename_file)) {
      order <- as.numeric(gsub(pattern, "\\1", basename_file))
      subtask <- gsub(pattern, "\\2", basename_file)
      title <- gsub(pattern, "\\3", basename_file)

      # If subtask is empty, use "main" as default
      if (nchar(subtask) == 0) {
        subtask <- "main"
      }

      list(
        path = f,
        order = order,
        subtask = subtask,
        title = title,
        basename = basename_file
      )
    } else {
      NULL
    }
  })
}

#' Create tabs from parsed file info (V3)
#'
#' @param file_info List of parsed file objects
#' @param task_dir Task directory path
#' @param task_env Shared environment for the entire task
#' @return List of nav_panel objects
create_tabs_from_files_v3 <- function(file_info, task_dir, task_env) {
  # Sort by order, then by subtask
  file_info <- file_info[order(
    sapply(file_info, function(x) x$order),
    sapply(file_info, function(x) x$subtask)
  )]

  # Group by order
  orders <- unique(sapply(file_info, function(x) x$order))

  tabs <- lapply(orders, function(ord) {
    # Get all files for this tab order
    tab_files <- Filter(function(x) x$order == ord, file_info)

    # Get tab title (capitalize first letter)
    tab_title <- get_tab_title_v3(tab_files[[1]]$title)

    # Build tab content with shared task environment
    tab_content <- build_tab_content_v3(tab_files, task_dir, task_env)

    nav_panel(
      title = tab_title,
      tab_content
    )
  })

  tabs
}

#' Get formatted tab title from filename title
#'
#' @param title Title from filename (e.g., "rozwiazanie")
#' @return Formatted title (e.g., "Rozwiązanie")
get_tab_title_v3 <- function(title) {
  # Capitalize first letter
  paste0(toupper(substring(title, 1, 1)), substring(title, 2))
}

#' Build content for a tab from its files (V3)
#'
#' @param tab_files Files for this tab
#' @param task_dir Task directory path
#' @param task_env Shared environment for the entire task
#' @return Shiny div with tab content
build_tab_content_v3 <- function(tab_files, task_dir, task_env = NULL) {
  # Use provided task environment, or create a new one if not provided
  # (for backward compatibility)
  if (is.null(task_env)) {
    task_env <- new.env(parent = .GlobalEnv)
  }

  # Build content blocks for each file
  content_blocks <- lapply(tab_files, function(file) {
    build_content_block_v3(file, task_dir, task_env)
  })

  # Wrap in div with padding
  div(
    style = "padding: 20px;",
    content_blocks
  )
}

#' Build content block for a single file (V3)
#'
#' Parses content for code(...), execute(...), plot(...), run(...) blocks
#'
#' @param file File info object
#' @param task_dir Task directory path
#' @param task_env Shared environment for execute/plot/run blocks
#' @return Shiny HTML element
build_content_block_v3 <- function(file, task_dir, task_env = NULL) {
  # Read file content
  content <- paste(readLines(file$path, warn = FALSE), collapse = "\n")

  # Add separator if this is a subtask (not "main")
  blocks <- list()

  if (file$subtask != "main") {
    blocks <- c(blocks, list(
      h3(
        paste0(toupper(file$subtask), ")"),
        style = "color: #b1404f; border-bottom: 2px solid #b1404f; padding-bottom: 5px; margin-bottom: 15px; margin-top: 30px;"
      )
    ))
  }

  # Parse content for special functions
  parsed_blocks <- parse_content_blocks(content)

  # Render each parsed block with task environment
  for (block in parsed_blocks) {
    blocks <- c(blocks, list(render_content_block(block, task_env)))
  }

  # Return all blocks wrapped in div
  div(blocks)
}

#' Parse content into blocks (HTML, code(), execute(), plot(), run())
#'
#' @param content File content as string
#' @return List of block objects
parse_content_blocks <- function(content) {
  blocks <- list()
  pos <- 1

  while (pos <= nchar(content)) {
    # Find next function: code(, execute(, plot(, or run(
    pattern <- "(code|execute|plot|run)\\("
    match <- regexpr(pattern, substring(content, pos), perl = TRUE)

    if (match == -1) {
      # No more functions, add remaining content as HTML
      remaining <- substring(content, pos)
      if (nchar(trimws(remaining)) > 0) {
        blocks <- c(blocks, list(list(type = "html", content = remaining)))
      }
      break
    }

    # Add HTML content before match
    match_start <- pos + match - 1
    if (match > 1) {
      before <- substring(content, pos, match_start - 1)
      if (nchar(trimws(before)) > 0) {
        blocks <- c(blocks, list(list(type = "html", content = before)))
      }
    }

    # Extract function name
    func_text <- substring(content, match_start, match_start + attr(match, "match.length") - 1)
    func_name <- sub("\\($", "", func_text)

    # Find matching closing parenthesis by tracking balance
    # Must skip over quoted strings to avoid counting parens inside strings
    paren_start <- match_start + nchar(func_text)
    paren_count <- 1
    i <- paren_start

    while (i <= nchar(content) && paren_count > 0) {
      char <- substring(content, i, i)

      # If we hit a quote, skip the entire string
      if (char == '"' || char == "'") {
        quote_char <- char
        i <- i + 1  # Move past opening quote

        # Scan to find closing quote, handling escapes
        while (i <= nchar(content)) {
          current_char <- substring(content, i, i)

          if (current_char == "\\") {
            # Backslash - skip it and the next character
            i <- i + 2
          } else if (current_char == quote_char) {
            # Found closing quote - move past it and exit string loop
            i <- i + 1
            break
          } else {
            # Regular character in string
            i <- i + 1
          }
        }
        # Now i is positioned past the closing quote
        # Loop back to top to read next char
        next
      }

      # Not in a string - count parentheses
      if (char == "(") {
        paren_count <- paren_count + 1
      } else if (char == ")") {
        paren_count <- paren_count - 1
      }
      # For all other characters (including +, -, *, etc.), just continue

      i <- i + 1
    }

    if (paren_count == 0) {
      # Found matching closing paren
      func_content <- substring(content, paren_start, i - 2)
      blocks <- c(blocks, list(list(type = func_name, content = func_content)))
      pos <- i
    } else {
      # Unmatched parenthesis - treat as HTML
      warning("Unmatched parenthesis in ", func_name, "() at position ", match_start)
      blocks <- c(blocks, list(list(type = "html", content = substring(content, match_start, nchar(content)))))
      break
    }
  }

  blocks
}

#' Render a content block based on its type
#'
#' @param block Block object with type and content
#' @param task_env Shared environment for execute/plot/run blocks
#' @return Shiny HTML element
render_content_block <- function(block, task_env = NULL) {
  if (block$type == "html") {
    # Raw HTML content
    div(class = "task-tab-content-simple", HTML(block$content))

  } else if (block$type == "code") {
    # Display code with syntax highlighting (not executed)
    code_block(block$content, language = "r")

  } else if (block$type == "execute") {
    # Execute code and show output with task environment
    output <- execute_code(block$content, use_auto_labels = TRUE, use_comments = TRUE, envir = task_env)
    code_output(output)

  } else if (block$type == "plot") {
    # Execute code with plot handling with task environment
    output <- execute_code(block$content, use_auto_labels = TRUE, use_comments = TRUE, envir = task_env)
    code_output(output)

  } else if (block$type == "run") {
    # Execute code silently without displaying output (for initialization/setup)
    # This is useful for loading libraries, defining functions, preparing data, etc.
    tryCatch({
      eval(parse(text = block$content), envir = task_env)
    }, error = function(e) {
      # If there's an error, show it
      div(
        style = "padding: 15px; background: #fff3cd; border-left: 4px solid #ffc107; margin: 10px 0;",
        tags$strong("Error in run() block:"),
        tags$pre(style = "margin-top: 10px;", conditionMessage(e))
      )
    })
    # Return empty div (no visible output)
    div()

  } else {
    # Unknown type - display as text
    div(
      style = "padding: 15px; background: #f8f9fa; border-left: 4px solid #b1404f;",
      pre(block$content)
    )
  }
}
