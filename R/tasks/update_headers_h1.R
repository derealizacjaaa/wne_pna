# Update 1_tresc.txt files to use H1 for the main title

update_tresc_headers <- function(tasks_dir = "tasks") {
    # Find all list directories
    list_dirs <- list.dirs(tasks_dir, full.names = TRUE, recursive = FALSE)
    list_dirs <- list_dirs[grepl("/list\\d+$", list_dirs)]

    updated_count <- 0

    for (list_dir in list_dirs) {
        # Find task folders
        task_dirs <- list.dirs(list_dir, full.names = TRUE, recursive = FALSE)

        for (task_dir in task_dirs) {
            tresc_file <- file.path(task_dir, "1_tresc.txt")

            if (file.exists(tresc_file)) {
                content <- readLines(tresc_file, warn = FALSE)

                if (length(content) > 0) {
                    # Check if the first non-empty line contains an h2
                    first_header_idx <- grep("<h[1-6]", content)[1]

                    if (!is.na(first_header_idx)) {
                        line <- content[first_header_idx]

                        # If it is an h2, convert to h1
                        if (grepl("<h2>", line)) {
                            # Replace only the first occurrence of h2/h2 tags in this line
                            # Assuming the title is on one line or the tag is simple
                            new_line <- gsub("<h2>", "<h1>", line)
                            new_line <- gsub("</h2>", "</h1>", new_line)

                            if (line != new_line) {
                                content[first_header_idx] <- new_line
                                writeLines(content, tresc_file, useBytes = TRUE)
                                updated_count <- updated_count + 1
                                cat(sprintf("Updated H2 -> H1 in %s\n", basename(task_dir)))
                            }
                        } else if (grepl("<h1>", line)) {
                            # Already H1, skipped
                        }
                    }
                }
            }
        }
    }

    cat(sprintf("\nTotal files updated: %d\n", updated_count))
}

if (sys.nframe() == 0) {
    update_tresc_headers("tasks")
}
