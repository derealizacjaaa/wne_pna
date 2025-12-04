# ============================================
# FILE-BASED TASK BUILDER
# ============================================
# Builds tasks from numbered .txt files in task directory
#
# File naming convention: {order}{subtask}_{type}.txt
#   order: 1, 2, 3, ... (determines tab position left-to-right)
#   subtask: a, b, c, ... (optional - groups multiple files in same tab)
#   type: content, code, execute, plot
#
# Examples:
#   1_content.txt     → Tab 1: Content (HTML)
#   2_code.txt        → Tab 2: Display code
#   2a_code.txt       → Tab 2: Exercise A
#   2b_code.txt       → Tab 2: Exercise B (auto-separated)
#   3_execute.txt     → Tab 3: Execute code
#   4_plot.txt        → Tab 4: Execute code with plot
# ============================================

#' Build task from numbered .txt files
#'
#' @param task_dir Path to task directory
#' @return Task structure or NULL
build_task_from_files <- function(task_dir) {
  # Find all .txt files
  files <- list.files(task_dir, pattern = "\\.txt$", full.names = TRUE)

  if (length(files) == 0) {
    return(NULL)
  }

  # Parse filenames
  file_info <- parse_task_files(files)

  # Remove any NULL entries (unparseable files)
  file_info <- Filter(Negate(is.null), file_info)

  if (length(file_info) == 0) {
    return(NULL)
  }

  # Group files by tab order
  tabs <- create_tabs_from_files(file_info)

  # Build navbar with tabs
  content <- page_navbar(title = "", id = "task_tabs", !!!tabs)

  # Determine completion status (has execute or plot files)
  completed <- any(sapply(file_info, function(f) f$type %in% c("execute", "plot")))

  list(
    content = content,
    completed = completed,
    auto_generated = TRUE,
    file_based = TRUE
  )
}

#' Parse task filenames into structured info
#'
#' @param files Vector of file paths
#' @return List of file info objects
parse_task_files <- function(files) {
  lapply(files, function(f) {
    basename_file <- basename(f)

    # Pattern: {order}{subtask}_{type}.txt
    # Examples: 1_content.txt, 2a_code.txt, 3_execute.txt
    pattern <- "^(\\d+)([a-z]?)_(.+)\\.txt$"

    if (grepl(pattern, basename_file)) {
      order <- as.numeric(gsub(pattern, "\\1", basename_file))
      subtask <- gsub(pattern, "\\2", basename_file)
      type <- gsub(pattern, "\\3", basename_file)

      # If subtask is empty, use "main" as default
      if (nchar(subtask) == 0) {
        subtask <- "main"
      }

      list(
        path = f,
        order = order,
        subtask = subtask,
        type = type,
        basename = basename_file
      )
    } else {
      # Skip files that don't match pattern
      NULL
    }
  })
}

#' Create tabs from parsed file info
#'
#' @param file_info List of parsed file objects
#' @return List of nav_panel objects
create_tabs_from_files <- function(file_info) {
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

    # Determine tab title
    tab_title <- get_tab_title(ord, tab_files)

    # Build tab content
    tab_content <- build_tab_content(tab_files)

    nav_panel(
      title = tab_title,
      tab_content
    )
  })

  tabs
}

#' Get title for tab based on order and file types
#'
#' @param order Tab order number
#' @param tab_files Files for this tab
#' @return Character tab title
get_tab_title <- function(order, tab_files) {
  # Get primary file type
  types <- sapply(tab_files, function(x) x$type)
  primary_type <- types[1]

  # Standard titles based on type
  if (order == 1 || primary_type == "content") {
    return("Treść")
  } else if (primary_type == "code") {
    return("Kod")
  } else if (primary_type == "execute") {
    return("Wynik")
  } else if (primary_type == "plot") {
    return("Wykres")
  } else {
    return(paste("Tab", order))
  }
}

#' Build content for a tab from its files
#'
#' @param tab_files Files for this tab
#' @return Shiny div with tab content
build_tab_content <- function(tab_files) {
  # Build content blocks for each file
  content_blocks <- lapply(tab_files, function(file) {
    build_content_block(file)
  })

  # Wrap in div with padding (20px top/bottom, 30px left/right)
  div(
    style = "padding: 20px 30px;",
    content_blocks
  )
}

#' Build content block for a single file
#'
#' @param file File info object
#' @return Shiny HTML element
build_content_block <- function(file) {
  # Read file content
  content <- paste(readLines(file$path, warn = FALSE), collapse = "\n")

  # Add separator if this is a subtask (not "main")
  blocks <- list()

  if (file$subtask != "main") {
    # Add subtask header
    blocks <- c(blocks, list(
      h3(
        paste0(toupper(file$subtask), ")"),
        style = "color: #b1404f; border-bottom: 2px solid #b1404f; padding-bottom: 5px; margin-bottom: 15px; margin-top: 30px;"
      )
    ))
  }

  # Build content based on type
  if (file$type == "content") {
    # HTML content
    blocks <- c(blocks, list(
      div(class = "task-tab-content-simple", HTML(content))
    ))

  } else if (file$type == "code") {
    # Display code with syntax highlighting
    blocks <- c(blocks, list(
      code_block(content, language = "r")
    ))

  } else if (file$type == "execute") {
    # Execute code and show output
    output <- execute_code(content, use_auto_labels = TRUE, use_comments = TRUE)
    blocks <- c(blocks, list(
      code_output(output)
    ))

  } else if (file$type == "plot") {
    # Execute code with plot handling
    output <- execute_code(content, use_auto_labels = TRUE, use_comments = TRUE)
    blocks <- c(blocks, list(
      code_output(output)
    ))

  } else {
    # Unknown type - display as text
    blocks <- c(blocks, list(
      div(
        style = "padding: 20px 30px; background: #f8f9fa; border-left: 4px solid #b1404f;",
        pre(content)
      )
    ))
  }

  # Return all blocks wrapped in div
  div(blocks)
}

#' Check if task uses old system (content.txt + code.txt)
#'
#' @param task_dir Path to task directory
#' @return Logical
is_old_format_task <- function(task_dir) {
  has_content <- file.exists(file.path(task_dir, "content.txt"))
  has_code <- file.exists(file.path(task_dir, "code.txt"))
  has_numbered <- length(list.files(task_dir, pattern = "^\\d+[a-z]?_.+\\.txt$")) > 0

  # Old format if has content.txt/code.txt but no numbered files
  (has_content || has_code) && !has_numbered
}
