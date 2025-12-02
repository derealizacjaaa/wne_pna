# ============================================
# DYNAMIC LIST METADATA
# ============================================
# Auto-discovers lists from tasks directory

#' Discover all list folders in tasks directory
#' @param tasks_dir Path to tasks directory
#' @return Vector of list IDs (e.g., "list1", "list2")
discover_lists <- function(tasks_dir = "tasks") {
  # Find all list directories
  list_dirs <- list.dirs(tasks_dir, full.names = FALSE, recursive = FALSE)
  list_dirs <- list_dirs[grepl("^list\\d+$", list_dirs)]

  # Sort by list number
  list_dirs[order(as.numeric(gsub("list", "", list_dirs)))]
}

#' Generate metadata for a single list
#' @param list_id List identifier (e.g., "list1")
#' @return List with id, name, subtitle, num
generate_list_metadata <- function(list_id) {
  list_num <- as.numeric(gsub("list", "", list_id))

  # Convert number to Roman numerals
  roman_numeral <- as.character(as.roman(list_num))

  list(
    id = list_id,
    num = list_num,
    name = sprintf("Lista %s", roman_numeral),
    subtitle = sprintf("Lista %d", list_num)  # Simple subtitle, can be customized
  )
}

#' Get all list metadata (dynamically generated)
#' @param tasks_dir Path to tasks directory
#' @return Named list of metadata objects
get_list_metadata <- function(tasks_dir = "tasks") {
  discovered_lists <- discover_lists(tasks_dir)

  # Generate metadata for each discovered list
  metadata <- lapply(discovered_lists, generate_list_metadata)
  names(metadata) <- discovered_lists

  metadata
}

#' Get total number of discovered lists
#' @param tasks_dir Path to tasks directory
#' @return Integer count
get_total_lists <- function(tasks_dir = "tasks") {
  length(discover_lists(tasks_dir))
}
