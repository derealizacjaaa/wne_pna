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
      div(
        class = "main-area",
        div(
          class = "main-content",
          div(
            class = "main-content-header",
            class = "main-content-header",
            h3(
              style = "flex: 1; height: 100%;", # Ensure h3 grows to fill space and height
              # Link to Home
              tags$a(
                id = "nav_back_to_home",
                class = "breadcrumb-item breadcrumb-link action-button",
                href = "#",
                icon("home"),
                " Strona główna"
              ),
              # Dynamic Breadcrumbs
              uiOutput("header_list_crumb", inline = TRUE),
              uiOutput("header_task_crumb", inline = TRUE),
              # Dynamic Header Controls (Tabs etc.) - Inside h3 for correct sizing/layout
              uiOutput("header_controls", style = "margin-left: auto; height: 100%; display: flex; align-items: stretch;")
            )
          ),
          # Dynamic Body Content
          uiOutput("main_content_body", class = "main-content-body")
        )
      ),

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

#' Render main content area (Breadcrumbs & Body)
render_main_content <- function(output, state, current_list_tasks, list_metadata) {
  # 1. Render List Breadcrumb
  output$header_list_crumb <- renderUI({
    # Get current list name if available
    current_list_name <- NULL
    if (!is.null(state$current_list())) {
      current_list_name <- list_metadata[[state$current_list()]]$name
    }

    # Always generate unified crumb (always a link)
    generate_list_crumb(
      list_name = current_list_name
    )
  })

  # 2. Render Task Breadcrumb
  output$header_task_crumb <- renderUI({
    task <- if (!is.null(state$current_task())) current_list_tasks()[[state$current_task()]] else NULL
    generate_task_crumb(task)
  })

  # 3. Render Header Controls
  # Inside h3, so we just need a spacer to push right. Font size inherited from h3.
  output$header_controls <- renderUI({
    if (!is.null(state$current_task())) {
      task <- current_list_tasks()[[state$current_task()]]
      if (isTRUE(task$file_based_v3) && !is.null(task$header_ui)) {
        return(task$header_ui)
      }
    }
    return(NULL)
  })

  # 3. Render Body Content
  output$main_content_body <- renderUI({
    # Get current list name if available
    current_list_name <- NULL
    if (!is.null(state$current_list())) {
      current_list_name <- list_metadata[[state$current_list()]]$name
    }

    content <- if (is.null(state$current_task())) {
      if (!is.null(current_list_name)) {
        list_welcome_body(current_list_name)
      } else {
        welcome_body()
      }
    } else {
      # Get current task
      tasks <- current_list_tasks()
      task <- tasks[[state$current_task()]]
      task_display_body(task)
    }

    # Create a hidden span with list name for JS breadcrumb to find (legacy support/JS logic)
    data_span <- if (!is.null(current_list_name)) {
      tags$span(id = "current-list-data", `data-name` = current_list_name, style = "display: none;")
    } else {
      tags$span(id = "current-list-data", style = "display: none;")
    }

    tagList(data_span, content)
  })
}
