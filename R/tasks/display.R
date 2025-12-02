# ============================================
# TASK DISPLAY HELPERS
# ============================================
# Functions for displaying code and output blocks

#' Create a formatted code block
#' @param code Character string of code
#' @param language Programming language (default: "r")
#' @param padding CSS padding value
#' @return Shiny HTML tag for code block
code_block <- function(code, language = "r", padding = "15px") {
  # Clean up code: remove leading/trailing empty lines
  lines <- strsplit(code, "\n")[[1]]

  # Remove empty lines from start
  while(length(lines) > 0 && grepl("^\\s*$", lines[1])) {
    lines <- lines[-1]
  }

  # Remove empty lines from end
  while(length(lines) > 0 && grepl("^\\s*$", lines[length(lines)])) {
    lines <- lines[-length(lines)]
  }

  code <- paste(lines, collapse = "\n")

  tags$pre(
    class = "code-block",
    style = sprintf(
      "background: #f8f9fa; padding: %s; border-left: 4px solid #b1404f; border-radius: 4px; overflow-x: auto; font-family: 'Courier New', monospace; font-size: 0.9em; margin: 15px 0; white-space: pre;",
      padding
    ),
    tags$code(
      class = paste0("language-", language),
      style = "display: block; margin: 0; padding: 0;",
      code
    )
  )
}

#' Create a formatted output block
#' @param output Output object (can be text string or list with plots)
#' @return Shiny HTML tag for output display
code_output <- function(output) {
  # Handle complex output (text + plots)
  if (is.list(output) && !is.null(names(output)) && "plots" %in% names(output)) {
    content <- list()

    # Add text output if exists
    if (!is.null(output$text) && nzchar(output$text)) {
      content <- c(content, list(
        tags$pre(
          class = "code-output",
          style = "background: #ffffff; padding: 15px; border: 1px solid #dee2e6; border-left: 4px solid #28a745; border-radius: 4px; overflow-x: auto; font-family: 'Courier New', monospace; font-size: 0.9em; margin: 15px 0; color: #333; white-space: pre;",
          output$text
        )
      ))
    }

    # Add plots
    if (length(output$plots) > 0) {
      for (plot_file in output$plots) {
        if (file.exists(plot_file)) {
          plot_data <- readBin(plot_file, "raw", file.info(plot_file)$size)
          plot_base64 <- base64enc::base64encode(plot_data)

          content <- c(content, list(
            tags$div(
              style = "margin: 15px 0; text-align: center;",
              tags$img(
                src = paste0("data:image/png;base64,", plot_base64),
                style = "max-width: 100%; height: auto; border: 1px solid #dee2e6; border-radius: 4px; box-shadow: 0 2px 4px rgba(0,0,0,0.1);"
              )
            )
          ))
        }
      }
    }

    return(div(content))
  }

  # Simple text output
  tags$pre(
    class = "code-output",
    style = "background: #ffffff; padding: 15px; border: 1px solid #dee2e6; border-left: 4px solid #28a745; border-radius: 4px; overflow-x: auto; font-family: 'Courier New', monospace; font-size: 0.9em; margin: 15px 0; color: #333; white-space: pre;",
    output
  )
}
