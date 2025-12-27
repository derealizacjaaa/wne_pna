# ============================================
# RIGHT SIDEBAR - TASK SELECTION
# ============================================
# Generates the right sidebar for selecting tasks within a list

library(shiny)

#' Generate right sidebar with task selection
#'
#' @param tasks List of tasks in current list
#' @param current_task_id Currently selected task ID (or NULL)
#' @param current_list_name Name of current list
#' @param all_lists Full task structure (unused but kept for compatibility)
#' @return Shiny div with sidebar content
generate_task_sidebar <- function(tasks, current_task_id, current_list_name,
                                  all_lists = NULL) {
  # Handle empty state
  if (is.null(tasks) || length(tasks) == 0) {
    return(empty_task_sidebar())
  }

  # Build task items
  task_items <- lapply(seq_along(tasks), function(i) {
    task_id <- names(tasks)[i]
    task_info <- tasks[[i]]
    is_active <- !is.null(current_task_id) && task_id == current_task_id
    # Seed with both list name and task ID to ensure variety per task AND
    # per list
    create_task_item(
      task_id,
      task_info,
      is_active,
      list_seed = paste0(current_list_name, "_", task_id)
    )
  })

  # Build sidebar structure
  div(
    class = "tasks-sidebar-content",
    div(
      class = "tasks-sidebar-body",
      div(class = "sidebar-pattern"),
      div(class = "sidebar-gradient"),
      div(
        class = "sidebar-tasks-list",
        tags$ul(class = "tasks-menu", task_items)
      )
    )
  )
}

#' Create empty task sidebar (when no list selected or no tasks)
#' @param message Optional custom message
#' @return Shiny div
empty_task_sidebar <- function(message = "Brak zadań w tej liście") {
  div(
    class = "tasks-sidebar-content",
    div(
      class = "tasks-sidebar-body",
      div(class = "sidebar-pattern"),
      div(class = "sidebar-gradient"),
      div(
        class = "sidebar-tasks-list",
        p(message)
      )
    )
  )
}

#' Create placeholder sidebar for when no list is selected
#' @return Shiny div
placeholder_task_sidebar <- function() {
  div(
    class = "tasks-sidebar-content",
    div(
      class = "tasks-sidebar-body",
      div(class = "sidebar-pattern"),
      div(class = "sidebar-gradient"),
      div(
        class = "sidebar-tasks-list",
        p(
          style = "color: #606060; padding: 20px; text-align: center;",
          "Wybierz listę z lewego panelu"
        )
      )
    )
  )
}
