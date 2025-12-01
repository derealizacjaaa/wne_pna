# ============================================
# SERVER STATE MANAGEMENT
# ============================================
# Initializes and manages reactive values

#' Initialize reactive state for the application
#' @return List of reactive values
init_reactive_state <- function() {
  list(
    current_list = reactiveVal(NULL),     # Selected list ID
    current_task = reactiveVal(NULL),     # Selected task ID
    sidebar_collapsed = reactiveVal(FALSE), # Sidebar collapse state
    list_page = reactiveVal(1),           # Current page for list navigation
    loaded_lists = reactiveVal(list())    # Cache of loaded lists
  )
}

#' Create reactive expression for current list tasks
#' @param state Reactive state object
#' @param all_lists All tasks structure (reactiveVal)
#' @return Reactive expression
create_current_list_tasks <- function(state, all_lists) {
  reactive({
    req(state$current_list())
    list_id <- state$current_list()

    # Get from loaded lists
    loaded <- all_lists()
    if (list_id %in% names(loaded)) {
      return(loaded[[list_id]])
    }

    NULL
  })
}
