# ============================================
# TASK LOADER
# ============================================
# Loads tasks from directory structure
#
# Supports THREE loading modes:
#
# 1. AUTO-GENERATED (recommended for simple tasks):
#    a) Content only: tasks/list1/task1/content.txt
#       → Single "Treść" tab, completed = FALSE
#    b) Content + Code: tasks/list1/task1/content.txt + code.txt
#       → Three tabs (Treść/Kod/Wynik), completed = TRUE
#
# 2. MANUAL (for complex tasks):
#    tasks/list1/task2/task.R with create_task() function
#
# 3. LEGACY (backward compatibility):
#    tasks/list1/task3.R with create_task() function
# ============================================

#' Load all tasks from tasks directory
#' @param tasks_dir Root directory containing task lists
#' @return Nested list structure: all_lists[[list_id]][[task_id]]
load_all_tasks <- function(tasks_dir = "tasks") {
  all_lists <- list()

  # Find and sort list directories
  list_dirs <- find_list_directories(tasks_dir)

  # Process each list directory
  for (list_dir in list_dirs) {
    list_id <- basename(list_dir)
    list_num <- extract_number(list_id)

    all_lists[[list_id]] <- list()

    # Find all tasks in this list
    tasks <- find_all_tasks(list_dir)

    # Load each task
    for (task_path in tasks) {
      task <- load_single_task(task_path, list_id, list_num)
      if (!is.null(task)) {
        task_id <- task$task_id
        all_lists[[list_id]][[task_id]] <- task
      }
    }
  }

  all_lists
}

#' Find all list directories in tasks folder
#' @param tasks_dir Root tasks directory
#' @return Sorted vector of list directory paths
find_list_directories <- function(tasks_dir) {
  list_dirs <- list.dirs(tasks_dir, full.names = TRUE, recursive = FALSE)
  list_dirs <- list_dirs[grepl("/list\\d+$", list_dirs)]
  list_dirs[order(extract_number(basename(list_dirs)))]
}

#' Find all task paths in a list directory
#' @param list_dir Path to list directory
#' @return Sorted vector of task paths (folders and files)
find_all_tasks <- function(list_dir) {
  list_contents <- list.files(list_dir, full.names = TRUE)

  # Task folders (taskN directories)
  task_folders <- list_contents[file.info(list_contents)$isdir]
  task_folders <- task_folders[grepl("/task\\d+$", task_folders)]

  # Legacy task files (taskN.R files)
  task_files <- list_contents[!file.info(list_contents)$isdir]
  task_files <- task_files[grepl("^task\\d+\\.R$", basename(task_files))]

  # Only include legacy files if no folder exists
  task_files <- Filter(function(f) {
    task_id <- gsub("\\.R$", "", basename(f))
    !dir.exists(file.path(list_dir, task_id))
  }, task_files)

  # Combine and sort by task number
  all_tasks <- c(task_folders, task_files)
  all_tasks[order(extract_number(all_tasks))]
}

#' Load a single task from path
#' @param task_path Path to task (folder or file)
#' @param list_id List identifier
#' @param list_num List number
#' @return Task object or NULL
load_single_task <- function(task_path, list_id, list_num) {
  is_folder <- file.info(task_path)$isdir
  task_id <- if (is_folder) basename(task_path) else gsub("\\.R$", "", basename(task_path))
  task_num <- extract_number(task_id)

  task <- NULL

  tryCatch({
    if (is_folder) {
      task <- load_folder_task(task_path, list_id, task_id)
    } else {
      task <- load_legacy_task(task_path, list_id, task_id)
    }

    # Add metadata to task
    if (!is.null(task)) {
      task$list_id <- list_id
      task$list_num <- list_num
      task$task_id <- task_id
      task$task_num <- task_num
      task$completed <- task$completed %||% FALSE
    }

    task

  }, error = function(e) {
    warning(sprintf("Error loading %s/%s: %s", list_id, task_id, e$message))
    NULL
  })
}

#' Load task from folder (manual, file-based, or auto-generated)
#' @param task_path Path to task folder
#' @param list_id List identifier
#' @param task_id Task identifier
#' @return Task object or NULL
load_folder_task <- function(task_path, list_id, task_id) {
  manual_script <- file.path(task_path, "task.R")

  # Priority 1: Manual mode (task.R)
  if (file.exists(manual_script)) {
    task_env <- new.env()
    source(manual_script, local = task_env)

    if (exists("create_task", envir = task_env)) {
      cat(sprintf("✓ Loaded %s/%s (manual)\n", list_id, task_id))
      return(task_env$create_task())
    }
  }

  # Priority 2: File-based mode (numbered .txt files)
  task <- build_task_from_files(task_path)
  if (!is.null(task)) {
    cat(sprintf("✓ Loaded %s/%s (file-based)\n", list_id, task_id))
    return(task)
  }

  # Priority 3: Old auto-generation mode (content.txt + code.txt)
  task <- auto_generate_basic_task(task_path)
  if (!is.null(task)) {
    cat(sprintf("✓ Loaded %s/%s (auto-generated-old)\n", list_id, task_id))
    return(task)
  }

  NULL
}

#' Load legacy task from .R file
#' @param task_path Path to task file
#' @param list_id List identifier
#' @param task_id Task identifier
#' @return Task object or NULL
load_legacy_task <- function(task_path, list_id, task_id) {
  task_env <- new.env()
  source(task_path, local = task_env)

  if (exists("create_task", envir = task_env)) {
    cat(sprintf("✓ Loaded %s/%s (legacy)\n", list_id, task_id))
    return(task_env$create_task())
  }

  NULL
}

#' Extract numeric part from string
#' @param x Character vector
#' @return Numeric vector
extract_number <- function(x) {
  as.numeric(gsub("\\D", "", x))
}

# ============================================
# TASK QUERY FUNCTIONS
# ============================================

#' Get all tasks from a specific list
#' @param all_lists Full task structure
#' @param list_id List identifier
#' @return List of tasks
get_list_tasks <- function(all_lists, list_id) {
  if (!list_id %in% names(all_lists)) {
    warning(sprintf("List '%s' not found", list_id))
    return(list())
  }
  all_lists[[list_id]]
}

#' Get a specific task
#' @param all_lists Full task structure
#' @param list_id List identifier
#' @param task_id Task identifier
#' @return Task object or NULL
get_task <- function(all_lists, list_id, task_id) {
  list_tasks <- get_list_tasks(all_lists, list_id)
  if (!task_id %in% names(list_tasks)) {
    warning(sprintf("Task '%s' not found in list '%s'", task_id, list_id))
    return(NULL)
  }
  list_tasks[[task_id]]
}

# ============================================
# STATISTICS FUNCTIONS
# ============================================

#' Get task completion statistics for a list
#' @param all_lists Full task structure
#' @param list_id List identifier
#' @return List with total, completed, remaining, percentage
get_list_stats <- function(all_lists, list_id) {
  tasks <- get_list_tasks(all_lists, list_id)
  total <- length(tasks)

  if (total == 0) {
    return(list(total = 0, completed = 0, remaining = 0, percentage = 0))
  }

  completed <- sum(sapply(tasks, function(t) isTRUE(t$completed)))

  list(
    total = total,
    completed = completed,
    remaining = total - completed,
    percentage = round(completed / total * 100)
  )
}

#' Get overall statistics across all lists
#' @param all_lists Full task structure
#' @return List with totals and percentage
get_overall_stats <- function(all_lists) {
  total_tasks <- 0
  completed_tasks <- 0

  for (list_id in names(all_lists)) {
    stats <- get_list_stats(all_lists, list_id)
    total_tasks <- total_tasks + stats$total
    completed_tasks <- completed_tasks + stats$completed
  }

  list(
    total_lists = length(all_lists),
    total_tasks = total_tasks,
    completed_tasks = completed_tasks,
    remaining_tasks = total_tasks - completed_tasks,
    percentage = if (total_tasks > 0) round(completed_tasks / total_tasks * 100) else 0
  )
}

#' Print summary of loaded tasks
#' @param all_lists Full task structure
print_task_summary <- function(all_lists) {
  cat("===========================================\n")
  cat("TASK SUMMARY\n")
  cat("===========================================\n\n")

  for (list_id in names(all_lists)) {
    stats <- get_list_stats(all_lists, list_id)
    cat(sprintf("📁 %s: %d tasks (%d completed, %d%%)\n",
                list_id, stats$total, stats$completed, stats$percentage))
  }

  cat("\n")
  overall <- get_overall_stats(all_lists)
  cat(sprintf("📊 Overall: %d tasks across %d lists (%d completed, %d%%)\n",
              overall$total_tasks, overall$total_lists,
              overall$completed_tasks, overall$percentage))
  cat("===========================================\n")
}
