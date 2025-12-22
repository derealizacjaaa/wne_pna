# ============================================
# MAIN CONTENT AREA
# ============================================
# Generates the main content area showing task details

#' Generate main content area
#'
#' @param current_task Task object or NULL
#' @param list_name Name of the current list (optional)
#' @return Shiny div with main content
generate_main_content <- function(current_task = NULL, list_name = NULL) {
  # Create a hidden span with list name for JS breadcrumb to find
  # This works even if the list item in sidebar is hidden due to pagination
  data_span <- if (!is.null(list_name)) {
    tags$span(id = "current-list-data", `data-name` = list_name, style = "display: none;")
  } else {
    tags$span(id = "current-list-data", style = "display: none;")
  }

  content <- if (is.null(current_task)) {
    welcome_screen()
  } else {
    task_display(current_task, list_name)
  }

  tagList(data_span, content)
}

#' Create welcome screen (shown when no task selected)
#' @return Shiny div
welcome_screen <- function() {
  div(
    class = "main-content",
    div(
      class = "main-content-header",
      h3(icon("home"), " Strona główna")
    ),
    div(
      class = "main-content-body",
      div(
        class = "main-content-empty",
        style = "padding: 60px 40px;",
        welcome_icon(),
        welcome_title(),
        welcome_description(),
        welcome_instructions(),
        welcome_cta()
      )
    )
  )
}

#' Welcome screen icon
welcome_icon <- function() {
  icon("graduation-cap",
    class = "fa-3x",
    style = "color: #b1404f; opacity: 0.7; margin-bottom: 20px;"
  )
}

#' Welcome screen title
welcome_title <- function() {
  h2("Witaj w Hub'ie Zadań!",
    style = "color: #4A4A4A; margin-bottom: 15px;"
  )
}

#' Welcome screen description
welcome_description <- function() {
  p(
    style = "color: #606060; font-size: 1.1em; max-width: 600px; margin: 0 auto 30px;",
    "System zarządzania zadaniami z kursu Programowanie Narzędzi Analitycznych"
  )
}

#' Welcome screen instructions
welcome_instructions <- function() {
  div(
    style = "background: #F4F6F9; padding: 30px; border-radius: 8px;
             border-left: 4px solid #b1404f; max-width: 700px; margin: 0 auto;",
    h3(
      style = "color: #4A4A4A; margin-top: 0;",
      icon("lightbulb"), " Jak zacząć?"
    ),
    tags$ol(
      style = "text-align: left; color: #606060; line-height: 1.8;",
      tags$li(
        "Wybierz listę zadań z ", tags$strong("lewego panelu"),
        " (np. Lista I - Podstawy R)"
      ),
      tags$li("Następnie wybierz konkretne zadanie z ", tags$strong("prawego panelu")),
      tags$li("Zadanie wyświetli się tutaj wraz z kodem i rozwiązaniami")
    )
  )
}

#' Welcome screen call-to-action
welcome_cta <- function() {
  div(
    style = "margin-top: 40px; padding: 20px; background: white;
             border-radius: 8px; border: 2px dashed #b1404f;
             max-width: 500px; margin-left: auto; margin-right: auto;",
    p(
      style = "color: #b1404f; font-weight: 600; margin: 0;",
      icon("arrow-left"), " Zacznij od wyboru listy po lewej stronie"
    )
  )
}

#' Display task content
#' @param task Task object with content
#' @param list_name Name of the current list (optional)
#' @return Shiny div
task_display <- function(task, list_name = NULL) {
  task_name <- task$name %||% sprintf("Zadanie %d", task$task_num)

  # Generate breadcrumb header (prevents flashing content)
  header_title <- create_breadcrumb_header(list_name, task_name, task$task_num)

  # Check if this is a V3 task (separated header and content)
  if (isTRUE(task$file_based_v3)) {
    div(
      class = "main-content",
      div(
        class = "main-content-header",
        div(
          style = "display: flex; align-items: center;",
          header_title
        ),
        # Render custom header UI (tabs)
        if (!is.null(task$header_ui)) task$header_ui
      ),
      div(
        class = "main-content-body",
        task$content
      )
    )
  } else {
    # Fallback for old tasks (single content block)
    div(
      class = "main-content",
      div(
        class = "main-content-header",
        header_title
      ),
      div(
        class = "main-content-body",
        task$content
      )
    )
  }
}

#' Create breadcrumb header HTML structure
#' @param list_name Name of the list
#' @param task_name Name of the task
#' @param task_num Task number
#' @return Shiny h3 tag with breadcrumb structure
create_breadcrumb_header <- function(list_name, task_name, task_num) {
  # Helper to create separator
  sep <- tags$span(class = "breadcrumb-separator", "/")

  # Base crumbs
  crumbs <- list(
    tags$span(class = "breadcrumb-item", "-wne"),
    sep,
    tags$span(class = "breadcrumb-item", "pna")
  )

  # List crumb
  if (!is.null(list_name)) {
    # Try to format Roman numerals if it matches "Lista N" pattern
    formatted_list <- list_name
    if (grepl("Lista \\d+", list_name, ignore.case = TRUE)) {
      num <- as.numeric(sub("Lista ", "", list_name, ignore.case = TRUE))
      if (!is.na(num) && num >= 1 && num <= 10) {
        romans <- c("I", "II", "III", "IV", "V", "VI", "VII", "VIII", "IX", "X")
        formatted_list <- paste("Lista", romans[num])
      }
    }

    crumbs <- c(crumbs, list(
      sep,
      tags$span(class = "breadcrumb-item", formatted_list)
    ))
  }

  # Task crumb
  # Determine display name for task
  task_display <- if (!is.null(task_num)) paste("Zadanie", task_num) else task_name

  crumbs <- c(crumbs, list(
    sep,
    tags$span(class = "breadcrumb-item", task_display)
  ))

  # Return as h3
  h3(crumbs)
}
