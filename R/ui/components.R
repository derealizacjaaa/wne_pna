# ============================================
# REUSABLE UI COMPONENTS
# ============================================
# Small, focused UI building blocks

#' Create a vertical progress bar
#' @param percentage Progress percentage (0-100)
#' @param is_partial Whether progress is partial (for styling)
#' @return Shiny div with progress bar
progress_bar_vertical <- function(percentage, is_partial = FALSE) {
  div(
    class = "progress-bar-container-vertical",
    div(
      class = if (is_partial) "progress-bar-fill-vertical partial" else "progress-bar-fill-vertical",
      style = sprintf("height: %s%%;", percentage)
    )
  )
}

#' Create a progress counter badge
#' @param completed Number of completed items
#' @param total Total number of items
#' @return Shiny span with styled counter
progress_counter <- function(completed, total) {
  is_complete <- total > 0 && completed == total
  is_partial <- completed > 0 && completed < total

  counter_class <- if (is_complete) {
    "progress-text complete"
  } else if (is_partial) {
    "progress-text partial"
  } else {
    "progress-text empty"
  }

  tags$span(
    class = counter_class,
    sprintf("%d/%d", completed, total)
  )
}

#' Create a list item for list selection sidebar
#' @param list_info List metadata object
#' @param is_active Whether this list is currently selected
#' @param stats List statistics (from get_list_stats)
#' @return Shiny li tag
create_list_item <- function(list_info, is_active, stats) {
  progress_pct <- if (stats$total > 0) (stats$completed / stats$total) * 100 else 0
  is_partial <- progress_pct > 0 && progress_pct < 100

  tags$li(
    class = if (is_active) "list-item active" else "list-item",
    actionLink(
      paste0("select_", list_info$id),
      div(
        class = "list-item-content",
        progress_bar_vertical(progress_pct, is_partial),
        div(
          class = "list-text",
          h4(HTML(gsub("(Lista\\s+)([IVX]+)", "\\1<span class='roman-numeral'>\\2</span>", list_info$name)))
        ),
        div(
          class = "list-progress",
          progress_counter(stats$completed, stats$total)
        )
      )
    )
  )
}

#' Create a task item for task selection sidebar
#' @param task_id Task identifier
#' @param task_info Task object
#' @param is_active Whether this task is currently selected
#' @return Shiny li tag
create_task_item <- function(task_id, task_info, is_active) {
  is_completed <- isTRUE(task_info$completed)

  # Format task number: 1-9 without leading zero, 10+ with colored first digit
  task_num <- task_info$task_num
  if (task_num < 10) {
    number_display <- as.character(task_num)
  } else {
    first_digit <- substr(as.character(task_num), 1, 1)
    second_digit <- substr(as.character(task_num), 2, 2)
    number_display <- tags$span(
      tags$span(class = "first-digit", first_digit),
      second_digit
    )
  }

  tags$li(
    class = if (is_active) "task-item active" else "task-item",
    # Status icon overlay (outside the link)
    if (is_completed) {
      div(class = "task-status status-completed", icon("circle-check"))
    },
    # Main clickable content
    actionLink(
      paste0("select_task_", task_id),
      div(class = "task-number", number_display),
      div(class = "task-name", "Zadanie")
    )
  )
}

#' Create overall progress summary card
#' @param overall_stats Overall statistics from get_overall_stats
#' @return Shiny div with progress card
progress_summary_card <- function(overall_stats) {
  div(
    class = "progress-summary-card",
    div(
      class = "summary-header",
      icon("chart-pie"),
      tags$span("Postęp ", class = "summary-header-text"),
      tags$span(overall_stats$total_lists, class = "summary-header-count"),
      tags$span(" list", class = "summary-header-text")
    ),
    div(
      class = "summary-stats",
      div(
        class = "summary-stat",
        tags$span(class = "stat-value stat-value-completed", overall_stats$completed_tasks),
        tags$span(class = "stat-label", "Ukończone")
      ),
      div(
        class = "summary-stat",
        tags$span(class = "stat-value stat-value-total", overall_stats$total_tasks),
        tags$span(class = "stat-label", "Zadania")
      )
    ),
    div(
      class = "summary-progress-bar",
      div(
        class = "summary-progress-fill",
        style = sprintf("width: %s%%;", overall_stats$percentage)
      )
    ),
    div(class = "summary-percentage", sprintf("%d%%", overall_stats$percentage))
  )
}

#' Create navigation buttons for pagination
#'
#' Buttons are always rendered to maintain consistent spacing,
#' but hidden when not needed (visibility: hidden)
#'
#' @param has_prev Whether previous page exists
#' @param has_next Whether next page exists
#' @return List with prev and next_btn button elements
pagination_buttons <- function(has_prev, has_next) {
  list(
    prev = actionButton(
      "list_page_prev",
      label = NULL,
      icon = icon("chevron-up"),
      class = paste("list-nav-btn list-nav-prev", if (!has_prev) "btn-hidden" else "")
    ),
    next_btn = actionButton(
      "list_page_next",
      label = NULL,
      icon = icon("chevron-down"),
      class = paste("list-nav-btn list-nav-next", if (!has_next) "btn-hidden" else "")
    )
  )
}
