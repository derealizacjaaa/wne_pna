# ============================================
# SERVER OBSERVERS
# ============================================
# Event handlers for user interactions

#' Setup all observers for the application
#' @param input Shiny input object
#' @param state Reactive state object
#' @param list_metadata List metadata
#' @param all_lists All tasks structure
#' @param current_list_tasks Reactive expression for current list tasks
setup_observers <- function(input, state, list_metadata, all_lists, current_list_tasks) {
  # Sidebar toggle observer
  observe_sidebar_toggle(input, state)

  # Home button observer
  observe_home_button(input, state)

  # List pagination observers
  observe_list_pagination(input, state, list_metadata)

  # List selection observers
  observe_list_selection(input, state, list_metadata, all_lists)

  # Task selection observers
  observe_task_selection(input, state, current_list_tasks)
}

#' Observer for sidebar toggle button
observe_sidebar_toggle <- function(input, state) {
  observeEvent(input$toggle_sidebar, {
    state$sidebar_collapsed(!state$sidebar_collapsed())
  }, priority = 100)
}

#' Observer for home button
observe_home_button <- function(input, state) {
  observeEvent(input$home_btn, {
    state$current_list(NULL)
    state$current_task(NULL)
  }, priority = 100)
}

#' Observers for list pagination
observe_list_pagination <- function(input, state, list_metadata) {
  items_per_page <- 5
  total_pages <- ceiling(length(list_metadata) / items_per_page)

  # Previous page
  observeEvent(input$list_page_prev, {
    current_page <- state$list_page()
    if (current_page > 1) {
      state$list_page(current_page - 1)
    }
  }, ignoreInit = TRUE, priority = 100)

  # Next page
  observeEvent(input$list_page_next, {
    current_page <- state$list_page()
    if (current_page < total_pages) {
      state$list_page(current_page + 1)
    }
  }, ignoreInit = TRUE, priority = 100)
}

#' Observers for list selection
observe_list_selection <- function(input, state, list_metadata, all_lists) {
  observe({
    lapply(names(list_metadata), function(list_id) {
      observeEvent(input[[paste0("select_", list_id)]], {
        state$current_list(list_id)

        # Reset to first task of new list
        tasks <- all_lists[[list_id]]
        if (!is.null(tasks) && length(tasks) > 0) {
          state$current_task(names(tasks)[1])
        } else {
          state$current_task(NULL)
        }
      }, ignoreInit = TRUE, priority = 100)
    })
  })
}

#' Observers for task selection
observe_task_selection <- function(input, state, current_list_tasks) {
  observe({
    tasks <- current_list_tasks()
    if (!is.null(tasks)) {
      lapply(names(tasks), function(task_id) {
        observeEvent(input[[paste0("select_task_", task_id)]], {
          state$current_task(task_id)
        }, ignoreInit = TRUE, priority = 100)
      })
    }
  })
}
