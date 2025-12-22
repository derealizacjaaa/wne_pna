# Load required scripts
source("R/tasks/builder_v3.R")

# Mock task directory structure if needed, or point to existing one
# For testing, we will check if build_task_from_files_v3 returns the expected structure
# We need to simulate a task directory

dir.create("temp_test_task/task1", recursive = TRUE)
writeLines("code(x<-1)", "temp_test_task/task1/1_content.txt")

task <- build_task_from_files_v3("temp_test_task/task1")

print(names(task))
print(isTRUE(task$file_based_v3))
print(!is.null(task$header_ui))

# Clean up
unlink("temp_test_task", recursive = TRUE)
