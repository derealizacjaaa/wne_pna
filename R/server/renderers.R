# ============================================
# SERVER RENDERERS
# ============================================
# Output rendering functions

#' Setup all output renderers
#' @param output Shiny output object
#' @param state Reactive state object
#' @param list_metadata List metadata
#' @param all_lists All tasks structure
#' @param current_list_tasks Reactive expression for current list tasks
setup_renderers <- function(output, state, list_metadata, all_lists, current_list_tasks) {
  # Render dynamic layout
  render_dynamic_layout(output, state)

  # Render left sidebar
  render_list_sidebar(output, state, list_metadata, all_lists)

  # Render right sidebar
  render_task_sidebar(output, state, list_metadata, current_list_tasks, all_lists)

  # Render main content
  render_main_content(output, state, current_list_tasks, list_metadata)
}

#' Render dynamic layout based on sidebar state
render_dynamic_layout <- function(output, state) {
  output$dynamic_layout <- renderUI({
    div(
      class = if (state$sidebar_collapsed()) "app-container sidebar-collapsed" else "app-container",

      # Toggle button for collapsed state
      if (state$sidebar_collapsed()) {
        actionButton(
          "toggle_sidebar",
          label = NULL,
          icon = icon("bars"),
          class = "sidebar-toggle-btn-collapsed"
        )
      },

      # LEFT SIDEBAR (collapsible)
      if (!state$sidebar_collapsed()) {
        div(class = "left-sidebar", uiOutput("list_sidebar"))
      },

      # MAIN CONTENT
      div(class = "main-area", uiOutput("main_content")),

      # RIGHT SIDEBAR
      div(class = "right-sidebar", uiOutput("task_sidebar"))
    )
  })
}

#' Render left sidebar
render_list_sidebar <- function(output, state, list_metadata, all_lists) {
  output$list_sidebar <- renderUI({
    generate_list_sidebar(
      list_metadata,
      state$current_list(),
      all_lists,
      state$sidebar_collapsed(),
      state$list_page()
    )
  })
}

#' Render right sidebar
render_task_sidebar <- function(output, state, list_metadata, current_list_tasks, all_lists) {
  output$task_sidebar <- renderUI({
    # Show placeholder if no list selected
    if (is.null(state$current_list())) {
      return(placeholder_task_sidebar())
    }

    # Get current list name
    current_list_name <- list_metadata[[state$current_list()]]$name

    # Generate task sidebar
    generate_task_sidebar(
      current_list_tasks(),
      state$current_task(),
      current_list_name,
      all_lists
    )
  })
}

#' Render main content area
render_main_content <- function(output, state, current_list_tasks, list_metadata) {
  output$main_content <- renderUI({
    # Show welcome screen if no task selected
    if (is.null(state$current_task())) {
      return(generate_main_content(NULL))
    }

    # Get current task
    tasks <- current_list_tasks()
    task <- tasks[[state$current_task()]]

    # Get current list name if available
    current_list_name <- NULL
    if (!is.null(state$current_list())) {
      current_list_name <- list_metadata[[state$current_list()]]$name
    }

    # Display task
    generate_main_content(task, current_list_name)
  })
}
