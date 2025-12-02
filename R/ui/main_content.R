# ============================================
# MAIN CONTENT AREA
# ============================================
# Generates the main content area showing task details

#' Generate main content area
#'
#' @param current_task Task object or NULL
#' @return Shiny div with main content
generate_main_content <- function(current_task = NULL) {
  if (is.null(current_task)) {
    return(welcome_screen())
  }

  task_display(current_task)
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
  icon("graduation-cap", class = "fa-3x",
       style = "color: #b1404f; opacity: 0.7; margin-bottom: 20px;")
}

#' Welcome screen title
welcome_title <- function() {
  h2("Witaj w Hub'ie Zadań!",
     style = "color: #4A4A4A; margin-bottom: 15px;")
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
      tags$li("Wybierz listę zadań z ", tags$strong("lewego panelu"),
              " (np. Lista I - Podstawy R)"),
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
#' @return Shiny div
task_display <- function(task) {
  task_name <- task$name %||% sprintf("Zadanie %d", task$task_num)

  div(
    class = "main-content",
    div(
      class = "main-content-header",
      h3(icon("file-alt"), " ", task_name)
    ),
    div(
      class = "main-content-body",
      task$content
    )
  )
}
