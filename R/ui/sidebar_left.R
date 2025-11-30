# ============================================
# LEFT SIDEBAR - LIST SELECTION
# ============================================
# Generates the left sidebar for selecting task lists
# Dynamic list discovery with pagination

#' Generate left sidebar with list selection and pagination
#'
#' Shows only actual lists (no placeholders), with fixed navigation button positions
#'
#' @param list_metadata List metadata from get_list_metadata()
#' @param current_list_id Currently selected list ID (or NULL)
#' @param all_lists Full task structure
#' @param sidebar_collapsed Whether sidebar is collapsed
#' @param page Current page number for pagination
#' @return Shiny tagList with sidebar content
generate_list_sidebar <- function(list_metadata, current_list_id, all_lists,
                                  sidebar_collapsed, page = 1) {

  # Pagination configuration - 5 lists per page
  lists_per_page <- 5
  total_lists <- length(list_metadata)

  # Calculate page range
  page_range <- get_page_range(page, lists_per_page, total_lists)

  # Get lists for current page (only actual lists, no placeholders)
  if (total_lists > 0) {
    page_lists <- list_metadata[page_range$start:page_range$end]
  } else {
    page_lists <- list()
  }

  # Build list items (only for actual lists)
  list_items <- lapply(page_lists, function(list_info) {
    is_active <- !is.null(current_list_id) && list_info$id == current_list_id
    stats <- get_list_stats(all_lists, list_info$id)
    create_list_item(list_info, is_active, stats)
  })

  # Calculate total pages
  total_pages <- if (total_lists > 0) ceiling(total_lists / lists_per_page) else 1

  # Get navigation buttons (always present, just hidden when not needed)
  nav_buttons <- pagination_buttons(
    has_prev = page > 1,
    has_next = page < total_pages
  )

  # Get overall statistics
  overall_stats <- get_overall_stats(all_lists)

  # Build sidebar structure
  tagList(
    sidebar_header(),
    sidebar_menu(list_items, nav_buttons),
    sidebar_summary(overall_stats)
  )
}

#' Calculate page range for pagination
#' @param page Current page number
#' @param lists_per_page Number of lists per page
#' @param total_lists Total number of discovered lists
#' @return List with start and end indices
get_page_range <- function(page, lists_per_page, total_lists) {
  start_idx <- (page - 1) * lists_per_page + 1
  end_idx <- min(page * lists_per_page, total_lists)
  list(start = start_idx, end = end_idx)
}

#' Create sidebar header section
#' @return Shiny div with header
sidebar_header <- function() {
  div(
    class = "lists-sidebar-header",
    div(
      class = "sidebar-home-btn-container",
      actionButton("home_btn", label = NULL, icon = icon("home"),
                   class = "sidebar-home-btn")
    ),
    div(
      class = "lists-sidebar-header-inner",
      h3("Listy Zadań"),
      actionButton("toggle_sidebar", label = NULL, icon = icon("times"),
                   class = "sidebar-toggle-btn")
    )
  )
}

#' Create sidebar menu section with list items
#' @param list_items List of list item elements
#' @param nav_buttons Pagination button elements
#' @return Shiny div with menu
sidebar_menu <- function(list_items, nav_buttons) {
  div(
    class = "lists-sidebar-menu",
    nav_buttons$prev,
    tagAppendChildren(tags$ul(class = "lists-menu"), list_items),
    nav_buttons$next_btn
  )
}

#' Create sidebar summary section
#' @param overall_stats Overall statistics
#' @return Shiny div with summary
sidebar_summary <- function(overall_stats) {
  div(
    class = "lists-sidebar-summary",
    progress_summary_card(overall_stats)
  )
}
