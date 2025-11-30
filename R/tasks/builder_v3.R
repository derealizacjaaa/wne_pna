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
#   code(...) - Display R code with syntax highlighting
#   execute(...) - Execute R code and show output
#   plot(...) - Execute R code and show plot
#   Plain HTML/text - Display as-is
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

  # Group files by tab order
  tabs <- create_tabs_from_files_v3(file_info, task_dir)

  # Build navbar with tabs
  content <- page_navbar(title = "", id = "task_tabs", !!!tabs)

  # Determine completion status (has execute or plot blocks)
  completed <- any(sapply(file_info, function(f) {
    file_content <- paste(readLines(f$path, warn = FALSE), collapse = "\n")
    grepl("execute\\(|plot\\(", file_content)
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
#' @return List of nav_panel objects
create_tabs_from_files_v3 <- function(file_info, task_dir) {
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

    # Build tab content
    tab_content <- build_tab_content_v3(tab_files, task_dir)

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
#' @return Shiny div with tab content
build_tab_content_v3 <- function(tab_files, task_dir) {
  # Build content blocks for each file
  content_blocks <- lapply(tab_files, function(file) {
    build_content_block_v3(file, task_dir)
  })

  # Wrap in div with padding
  div(
    style = "padding: 20px;",
    content_blocks
  )
}

#' Build content block for a single file (V3)
#'
#' Parses content for code(...), execute(...), plot(...) blocks
#'
#' @param file File info object
#' @param task_dir Task directory path
#' @return Shiny HTML element
build_content_block_v3 <- function(file, task_dir) {
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

  # Render each parsed block
  for (block in parsed_blocks) {
    blocks <- c(blocks, list(render_content_block(block)))
  }

  # Return all blocks wrapped in div
  div(blocks)
}

#' Parse content into blocks (HTML, code(), execute(), plot())
#'
#' @param content File content as string
#' @return List of block objects
parse_content_blocks <- function(content) {
  blocks <- list()

  # Pattern to match: code(...), execute(...), plot(...)
  # Using non-greedy matching and proper parenthesis balancing
  pattern <- "(code|execute|plot)\\(([^)]*(?:\\([^)]*\\)[^)]*)*)\\)"

  pos <- 1
  repeat {
    # Find next function block
    match <- regexpr(pattern, substring(content, pos), perl = TRUE)

    if (match == -1) {
      # No more matches, add remaining content as HTML
      remaining <- substring(content, pos)
      if (nchar(trimws(remaining)) > 0) {
        blocks <- c(blocks, list(list(type = "html", content = remaining)))
      }
      break
    }

    # Add HTML content before match
    before <- substring(content, pos, pos + match - 2)
    if (nchar(trimws(before)) > 0) {
      blocks <- c(blocks, list(list(type = "html", content = before)))
    }

    # Extract function name and content
    match_start <- pos + match - 1
    match_text <- substring(content, match_start, match_start + attr(match, "match.length") - 1)

    func_name <- sub("^(code|execute|plot)\\(.*", "\\1", match_text)
    func_content <- sub("^(code|execute|plot)\\((.*)\\)$", "\\2", match_text)

    blocks <- c(blocks, list(list(type = func_name, content = func_content)))

    # Move position forward
    pos <- match_start + attr(match, "match.length")

    if (pos > nchar(content)) break
  }

  blocks
}

#' Render a content block based on its type
#'
#' @param block Block object with type and content
#' @return Shiny HTML element
render_content_block <- function(block) {
  if (block$type == "html") {
    # Raw HTML content
    div(class = "task-tab-content-simple", HTML(block$content))

  } else if (block$type == "code") {
    # Display code with syntax highlighting
    code_block(block$content, language = "r")

  } else if (block$type == "execute") {
    # Execute code and show output
    output <- execute_code(block$content, use_auto_labels = TRUE, use_comments = TRUE)
    code_output(output)

  } else if (block$type == "plot") {
    # Execute code with plot handling
    output <- execute_code(block$content, use_auto_labels = TRUE, use_comments = TRUE)
    code_output(output)

  } else {
    # Unknown type - display as text
    div(
      style = "padding: 15px; background: #f8f9fa; border-left: 4px solid #b1404f;",
      pre(block$content)
    )
  }
}
