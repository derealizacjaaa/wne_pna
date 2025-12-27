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
    tagList(
      # FULL WIDTH HEADER
      div(
        class = "main-content-header full-width-header",
        div(
          class = "header-content-wrapper",
          style = "display: flex; align-items: stretch; width: 100%; height: 100%;",

          # 1. LEFT COLUMN - Matches Left Sidebar Width
          div(
            style = "width: var(--sidebar-left-width); display: flex; justify-content: center; align-items: center; flex-shrink: 0; padding: 0 10px; height: 100%;",
            # Home Button centered here
            tags$a(
              id = "nav_back_to_home",
              class = "breadcrumb-item breadcrumb-link action-button",
              href = "#",
              icon("home"),
              " Strona główna"
            )
          ),

          # 2. MIDDLE COLUMN - Matches Main Content Width
          div(
            style = "flex: 1; display: flex; align-items: stretch; padding: 0 0 0 20px; min-width: 0; height: 100%;",

            # Dynamic Breadcrumbs (Left aligned - Vertically Centered)
            div(
              style = "display: flex; align-items: center; gap: 5px; flex-shrink: 1; overflow: hidden; height: 100%;",
              uiOutput("header_list_crumb", inline = FALSE, container = tags$div, style = "height: 100%; display: flex; align-items: center;"),
              uiOutput("header_task_crumb", inline = FALSE, container = tags$div, style = "height: 100%; display: flex; align-items: center;")
            ),

            # Dynamic Header Controls (Right aligned - Stretched)
            div(
              style = "margin-left: auto; height: 100%; display: flex; align-items: stretch; flex-shrink: 0;",
              uiOutput("header_controls", style = "height: 100%; display: flex; align-items: stretch; width: 100%;", container = tags$div)
            )
          ),

          # 3. RIGHT COLUMN - Matches Right Sidebar Width
          div(
            style = "width: var(--sidebar-right-width); flex-shrink: 0; height: 100%;"
          )
        )
      ),

      # MAIN APP CONTAINER
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
            # Header removed from here

            # Dynamic Body Content
            uiOutput("main_content_body", class = "main-content-body")
          )
        ),

        # RIGHT SIDEBAR
        div(class = "right-sidebar", uiOutput("task_sidebar"))
      )
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
