# ============================================
# TASK BUILDING PATTERNS
# ============================================
# Functions for creating task structures and tabs

#' Create code and output tabs from R code
#'
#' @param code R code string
#' @param code_tab_title Title for code tab
#' @param output_tab_title Title for output tab
#' @param language Programming language
#' @param auto_execute Execute code automatically
#' @param use_auto_labels Use automatic output labels
#' @param use_comments Use comments as labels
#' @return List of nav_panel objects
create_code_output_tabs <- function(code,
                                    code_tab_title = "Kod",
                                    output_tab_title = "Wynik",
                                    language = "r",
                                    auto_execute = TRUE,
                                    use_auto_labels = TRUE,
                                    use_comments = TRUE) {

  # Generate output if requested
  output <- if (auto_execute && language == "r") {
    execute_code(code, use_auto_labels, use_comments)
  } else {
    "Output not generated (set auto_execute = TRUE)"
  }

  list(
    nav_panel(
      title = code_tab_title,
      code_block(code, language)
    ),
    nav_panel(
      title = output_tab_title,
      code_output(output)
    )
  )
}

#' Create tabs for multiple related code exercises
#'
#' Uses shared environment so variables persist between exercises
#'
#' @param exercises List of exercise objects (each with title, code, optional description)
#' @param code_tab_title Title for code tab
#' @param output_tab_title Title for output tab
#' @return List of nav_panel objects
create_multi_code_tabs <- function(exercises,
                                   code_tab_title = "Kod",
                                   output_tab_title = "Wynik") {

  # Create shared environment for all exercises
  shared_env <- new.env()

  # Build code blocks
  all_code_blocks <- lapply(seq_along(exercises), function(i) {
    ex <- exercises[[i]]
    title <- ex$title %||% paste0("Podpunkt ", i)
    language <- ex$language %||% "r"

    div(
      style = "margin-bottom: 30px;",
      h3(title, style = "color: #b1404f; border-bottom: 2px solid #b1404f; padding-bottom: 5px; margin-bottom: 15px;"),
      if (!is.null(ex$description)) {
        p(ex$description, style = "margin-bottom: 15px; color: #606060;")
      },
      code_block(ex$code, language)
    )
  })

  # Build output blocks (execute in shared environment)
  all_output_blocks <- lapply(seq_along(exercises), function(i) {
    ex <- exercises[[i]]
    title <- ex$title %||% paste0("Podpunkt ", i)

    # Execute in shared environment
    output <- execute_code(ex$code, use_auto_labels = TRUE, use_comments = TRUE, envir = shared_env)

    div(
      style = "margin-bottom: 30px;",
      h3(title, style = "color: #28a745; border-bottom: 2px solid #28a745; padding-bottom: 5px; margin-bottom: 15px;"),
      code_output(output)
    )
  })

  list(
    nav_panel(
      title = code_tab_title,
      div(all_code_blocks)
    ),
    nav_panel(
      title = output_tab_title,
      div(all_output_blocks)
    )
  )
}

#' Auto-generate basic task from content.txt and code.txt
#'
#' Two scenarios:
#' 1. content.txt only → Single "Treść" tab, completed = FALSE
#' 2. content.txt + code.txt → Three tabs (Treść/Kod/Wynik), completed = TRUE
#'
#' @param task_dir Path to task directory
#' @return Task structure or NULL if content.txt missing
auto_generate_basic_task <- function(task_dir) {
  content_file <- file.path(task_dir, "content.txt")
  code_file <- file.path(task_dir, "code.txt")

  # content.txt is required
  if (!file.exists(content_file)) {
    return(NULL)
  }

  content_text <- paste(readLines(content_file, warn = FALSE), collapse = "\n")
  has_code <- file.exists(code_file) && file.info(code_file)$size > 0

  if (has_code) {
    # Scenario 2: Content + Code → 3 tabs (completed)
    code_text <- paste(readLines(code_file, warn = FALSE), collapse = "\n")

    code_output_tabs <- create_code_output_tabs(
      code = code_text,
      code_tab_title = "Kod",
      output_tab_title = "Wynik",
      language = "r",
      auto_execute = TRUE
    )

    task_tabs <- list(
      nav_panel(
        title = "Treść",
        div(class = "task-tab-content-simple", HTML(content_text))
      ),
      code_output_tabs[[1]],  # Code tab
      code_output_tabs[[2]]   # Output tab
    )

    content <- page_navbar(title = "", id = "task_tabs", !!!task_tabs)

    list(
      content = content,
      completed = TRUE,
      auto_generated = TRUE
    )

  } else {
    # Scenario 1: Content only → Single tab (uncompleted)
    content <- page_navbar(
      title = "",
      id = "task_tabs",
      nav_panel(
        title = "Treść",
        div(class = "task-tab-content-simple", HTML(content_text))
      )
    )

    list(
      content = content,
      completed = FALSE,
      auto_generated = TRUE
    )
  }
}
