# ============================================
# UNIFIED TASK LOADER (with Auto-Generation)
# ============================================
# Supports THREE loading modes:
#
# 1. AUTO-GENERATED (recommended for simple tasks):
#
#   a) Content only (uncompleted task):
#      tasks/list1/task1/
#        content.txt  → Task description (HTML supported)
#      → Creates single tab: Treść
#      → Marks as completed = FALSE
#
#   b) Content + Code (completed task with solution):
#      tasks/list1/task1/
#        content.txt  → Task description
#        code.txt     → R code solution
#      → Creates 3 tabs: Treść, Kod, Wynik
#      → Marks as completed = TRUE
#
# 2. MANUAL (for complex/special tasks):
#   tasks/list1/task2/
#     task.R       → Custom create_task() function
#     content.txt  → (ignored if task.R exists)
#     code.txt     → (ignored if task.R exists)
#
# 3. LEGACY (backward compatibility):
#   tasks/list1/
#     task3.R      → Old-style task file
#
# Metadata inferred from structure:
#   - List number: from folder name (list1 -> 1)
#   - Task number: from folder/file name (task1 -> 1)
#   - Completion status: from task definition or auto-determined
# ============================================

load_all_tasks <- function(tasks_dir = "tasks") {

  # Initialize result structure
  all_lists <- list()

  # Find all list directories (list1, list2, etc.)
  list_dirs <- list.dirs(tasks_dir, full.names = TRUE, recursive = FALSE)
  list_dirs <- list_dirs[grepl("/list\\d+$", list_dirs)]

  # Sort list directories by number
  list_dirs <- list_dirs[order(as.numeric(gsub(".*/list", "", list_dirs)))]

  # Process each list directory
  for (list_dir in list_dirs) {
    # Extract list number from directory name
    list_id <- basename(list_dir)  # e.g., "list1"
    list_num <- as.numeric(gsub("list", "", list_id))

    # Initialize list storage
    all_lists[[list_id]] <- list()

    # Find all task folders and files in this list
    list_contents <- list.files(list_dir, full.names = TRUE)

    # Get task folders (taskN directories)
    task_folders <- list_contents[file.info(list_contents)$isdir]
    task_folders <- task_folders[grepl("/task\\d+$", task_folders)]

    # Get old-style task files (taskN.R files)
    task_files <- list_contents[!file.info(list_contents)$isdir]
    task_files <- task_files[grepl("^task\\d+\\.R$", basename(task_files))]

    # Combine and sort all tasks by number
    all_tasks <- c()

    # Process folder-based tasks
    for (task_folder in task_folders) {
      task_id <- basename(task_folder)
      task_num <- as.numeric(gsub("task", "", task_id))
      all_tasks <- c(all_tasks, task_folder)
    }

    # Process file-based tasks (backward compatibility)
    for (task_file in task_files) {
      task_id <- gsub("\\.R$", "", basename(task_file))
      task_num <- as.numeric(gsub("task", "", task_id))
      # Only add if folder doesn't exist
      task_folder <- file.path(list_dir, task_id)
      if (!dir.exists(task_folder)) {
        all_tasks <- c(all_tasks, task_file)
      }
    }

    # Sort by task number
    all_tasks <- all_tasks[order(as.numeric(gsub(".*task|/.*", "", all_tasks)))]

    # Load each task
    for (task_path in all_tasks) {
      is_folder <- file.info(task_path)$isdir
      task_id <- if (is_folder) basename(task_path) else gsub("\\.R$", "", basename(task_path))
      task_num <- as.numeric(gsub("task", "", task_id))

      task <- NULL
      task_env <- new.env()

      tryCatch({
        if (is_folder) {
          # FOLDER MODE: Check for task.R or auto-generate
          manual_script <- file.path(task_path, "task.R")

          if (file.exists(manual_script)) {
            # Manual mode: source task.R
            source(manual_script, local = task_env)
            if (exists("create_task", envir = task_env)) {
              task <- task_env$create_task()
              cat(sprintf("✓ Loaded %s/%s (manual)\n", list_id, task_id))
            }
          } else {
            # Auto-generate mode: use content.txt + code.txt
            task <- auto_generate_basic_task(task_path)
            if (!is.null(task)) {
              cat(sprintf("✓ Loaded %s/%s (auto-generated)\n", list_id, task_id))
            }
          }
        } else {
          # FILE MODE: Old structure (backward compatibility)
          source(task_path, local = task_env)
          if (exists("create_task", envir = task_env)) {
            task <- task_env$create_task()
            cat(sprintf("✓ Loaded %s/%s (legacy)\n", list_id, task_id))
          }
        }

        # Add task if loaded successfully
        if (!is.null(task)) {
          # Add inferred metadata
          task$list_id <- list_id
          task$list_num <- list_num
          task$task_id <- task_id
          task$task_num <- task_num

          # Default completion status if not specified
          if (is.null(task$completed)) {
            task$completed <- FALSE
          }

          # Store task
          all_lists[[list_id]][[task_id]] <- task
        }

      }, error = function(e) {
        warning(sprintf("Error loading %s/%s: %s", list_id, task_id, e$message))
      })
    }
  }

  return(all_lists)
}

# Get all tasks from a specific list
get_list_tasks <- function(all_lists, list_id) {
  if (!list_id %in% names(all_lists)) {
    warning(sprintf("List '%s' not found", list_id))
    return(list())
  }
  return(all_lists[[list_id]])
}

# Get a specific task
get_task <- function(all_lists, list_id, task_id) {
  list_tasks <- get_list_tasks(all_lists, list_id)
  if (!task_id %in% names(list_tasks)) {
    warning(sprintf("Task '%s' not found in list '%s'", task_id, list_id))
    return(NULL)
  }
  return(list_tasks[[task_id]])
}

# Get task statistics for a list
get_list_stats <- function(all_lists, list_id) {
  tasks <- get_list_tasks(all_lists, list_id)

  total <- length(tasks)
  if (total == 0) {
    return(list(total = 0, completed = 0, percentage = 0))
  }

  completed <- sum(sapply(tasks, function(t) isTRUE(t$completed)))

  list(
    total = total,
    completed = completed,
    remaining = total - completed,
    percentage = round(completed / total * 100)
  )
}

# Get overall statistics for all lists
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

# Print summary of loaded tasks
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
