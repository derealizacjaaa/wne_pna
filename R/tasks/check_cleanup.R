# Check tasks after cleanup

check_tasks <- function(tasks_dir = "tasks") {
    library(shiny)
    library(bslib)

    # Source task system (no builder_v2 anymore)
    source("R/tasks/loader.R")
    source("R/tasks/builder.R")
    source("R/tasks/builder_v3.R")

    # Source server dependencies
    source("R/tasks/display.R")
    source("R/tasks/executor.R")
    source("R/server/renderers.R")
    source("R/server/state.R")

    # Load all tasks
    cat("Loading all tasks...\n")
    all_lists <- load_all_tasks(tasks_dir)

    # Check count
    total <- 0
    for (list_id in names(all_lists)) {
        total <- total + length(all_lists[[list_id]])
    }

    cat(sprintf("\nTotal tasks loaded: %d\n", total))

    if (total > 0) {
        cat("Cleanup successful. Legacy migration preserved V3 loading.\n")
    } else {
        cat("ERROR: No tasks loaded after cleanup.\n")
    }
}

if (sys.nframe() == 0) {
    check_tasks("tasks")
}
