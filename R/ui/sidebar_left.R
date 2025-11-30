# ============================================
# LEFT SIDEBAR - LIST SELECTION
# ============================================
# Generates the left sidebar for selecting task lists
# Fixed 5-slot layout with invisible empty slots

#' Generate left sidebar with list selection and pagination
#'
#' Always shows 5 slots (for consistent spacing), empty slots are invisible
#'
#' @param list_metadata List metadata from get_list_metadata()
#' @param current_list_id Currently selected list ID (or NULL)
#' @param all_lists Full task structure
#' @param sidebar_collapsed Whether sidebar is collapsed
#' @param page Current page number for pagination
#' @return Shiny tagList with sidebar content
generate_list_sidebar <- function(list_metadata, current_list_id, all_lists,
                                  sidebar_collapsed, page = 1) {

  # Fixed configuration - always 5 slots
  slots_per_page <- 5
  total_lists <- length(list_metadata)

  # Calculate which list indices to show on this page
  list_indices <- get_page_list_indices(page, slots_per_page, total_lists)

  # Build exactly 5 slots (some may be invisible)
  list_items <- lapply(1:slots_per_page, function(slot_idx) {
    list_idx <- list_indices[slot_idx]

    if (is.na(list_idx) || list_idx > total_lists) {
      # Invisible empty slot (takes up space but not visible)
      create_invisible_slot()
    } else {
      # Real list item
      list_info <- list_metadata[[list_idx]]
      is_active <- !is.null(current_list_id) && list_info$id == current_list_id
      stats <- get_list_stats(all_lists, list_info$id)
      create_list_item(list_info, is_active, stats)
    }
  })

  # Calculate total pages
  total_pages <- if (total_lists > 0) ceiling(total_lists / slots_per_page) else 1

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

#' Get list indices for current page
#'
#' Returns indices for all 5 slots, with NA for empty slots
#'
#' @param page Current page number
#' @param slots_per_page Number of slots per page (always 5)
#' @param total_lists Total number of discovered lists
#' @return Vector of 5 list indices (may contain NAs)
get_page_list_indices <- function(page, slots_per_page, total_lists) {
  # Calculate starting index for this page
  start_idx <- (page - 1) * slots_per_page + 1

  # Create vector of 5 indices
  indices <- start_idx:(start_idx + slots_per_page - 1)

  # Mark indices beyond total_lists as NA
  indices[indices > total_lists] <- NA

  indices
}

#' Create invisible empty slot
#'
#' Takes up space but is completely invisible
#'
#' @return Shiny li tag
create_invisible_slot <- function() {
  tags$li(
    class = "list-item list-item-invisible",
    style = "visibility: hidden;",
    div(
      class = "list-item-content",
      div(class = "progress-bar-container-vertical",
          div(class = "progress-bar-fill-vertical", style = "height: 0%;")),
      div(class = "list-text", h4("")),
      div(class = "list-progress", tags$span(class = "progress-text", ""))
    )
  )
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
#' @param list_items List of list item elements (always 5)
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
