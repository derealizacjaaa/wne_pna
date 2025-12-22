# Fix headers in V3 solution files

fix_headers <- function(tasks_dir = "tasks") {
    # Find all list directories
    list_dirs <- list.dirs(tasks_dir, full.names = TRUE, recursive = FALSE)
    list_dirs <- list_dirs[grepl("/list\\d+$", list_dirs)]

    fixed_count <- 0

    for (list_dir in list_dirs) {
        # Find task folders
        task_dirs <- list.dirs(list_dir, full.names = TRUE, recursive = FALSE)

        for (task_dir in task_dirs) {
            sol_file <- file.path(task_dir, "2_rozwiazanie.txt")

            if (file.exists(sol_file)) {
                content <- readLines(sol_file, warn = FALSE)

                # Check if first line is h3
                if (length(content) > 0 && grepl("<h3>Rozwiązanie</h3>", content[1])) {
                    # Replace with h2
                    content[1] <- gsub("<h3>", "<h2>", content[1])
                    content[1] <- gsub("</h3>", "</h2>", content[1])

                    writeLines(content, sol_file, useBytes = TRUE)
                    fixed_count <- fixed_count + 1
                    cat(sprintf("Fixed header in %s\n", basename(task_dir)))
                }
            }
        }
    }

    cat(sprintf("\nTotal files fixed: %d\n", fixed_count))
}

if (sys.nframe() == 0) {
    fix_headers("tasks")
}
