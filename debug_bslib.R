library(bslib)
library(htmltools)

# Mock creation of tabs like in builder_v3.R
tabs <- list(
    nav_panel("Tab 1", "Content 1"),
    nav_panel("Tab 2", "Content 2")
)

# Generate page_navbar
content <- page_navbar(title = "", id = "task_tabs", !!!tabs)

# Print structure
print(content)
