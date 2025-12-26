# ============================================
# MAIN CONTENT AREA
# ============================================
# Generates the main content area showing task details

#' Generate list breadcrumb (dynamic link or static text)
#' @param list_name Name of the current list (optional)
#' @param has_task Boolean, true if a task is currently selected
#' @return List of Shiny tags
#' Generate list breadcrumb (dynamic link)
#' @param list_name Name of the current list (optional)
#' @return List of Shiny tags
generate_list_crumb <- function(list_name = NULL) {
  if (is.null(list_name)) {
    return(list())
  }

  crumbs <- list()
  sep <- tags$span(class = "breadcrumb-separator", "/")

  display_name <- gsub("Lista\\s+([IVX]+)", "Lista <span class='roman-numeral'>\\1</span>", list_name)

  # Check if roman numeral substitution happened, if not use original logic
  if (display_name == list_name && grepl("Lista \\d+", list_name)) {
    num <- as.numeric(sub("Lista ", "", list_name, ignore.case = TRUE))
    if (!is.na(num) && num >= 1 && num <= 10) {
      romans <- c("I", "II", "III", "IV", "V", "VI", "VII", "VIII", "IX", "X")
      display_name <- paste("Lista", romans[num])
      display_name <- gsub("Lista\\s+([IVX]+)", "Lista <span class='roman-numeral'>\\1</span>", display_name)
    }
  }

  # Always clickable to allow navigation back to welcome screen (even if already there, it's consistent)
  crumbs <- c(crumbs, list(
    sep,
    tags$a(
      id = "nav_back_to_list_welcome",
      class = "breadcrumb-item breadcrumb-link action-button",
      href = "#",
      icon("folder-open"),
      HTML(paste0("&nbsp; ", display_name))
    )
  ))

  return(tagList(crumbs))
}

#' Generate task breadcrumb
#' @param task Task object or NULL
#' @return List of Shiny tags
generate_task_crumb <- function(task = NULL) {
  if (is.null(task)) {
    return(list())
  }

  crumbs <- list()
  sep <- tags$span(class = "breadcrumb-separator", "/")

  task_name <- task$name %||% sprintf("Zadanie %d", task$task_num)
  task_display <- if (!is.null(task$task_num)) paste("Zadanie", task$task_num) else task_name

  crumbs <- c(crumbs, list(
    sep,
    tags$span(class = "breadcrumb-item", task_display)
  ))

  return(tagList(crumbs))
}

#' Create welcome screen body
#' @return Shiny div
welcome_body <- function() {
  div(
    class = "main-content-empty",
    style = "padding: 60px 40px;",
    welcome_icon(),
    welcome_title(),
    welcome_description(),
    welcome_instructions(),
    welcome_cta()
  )
}

#' Create list welcome screen body
#' @param list_name Name of the selected list
#' @return Shiny div
list_welcome_body <- function(list_name) {
  # Format list name for display (e.g., "Lista I")
  display_name <- gsub("Lista\\s+([IVX]+)", "Lista <span class='roman-numeral'>\\1</span>", list_name)

  # Check if roman numeral substitution happened, if not use original
  if (display_name == list_name && grepl("Lista \\d+", list_name)) {
    num <- as.numeric(sub("Lista ", "", list_name, ignore.case = TRUE))
    if (!is.na(num) && num >= 1 && num <= 10) {
      romans <- c("I", "II", "III", "IV", "V", "VI", "VII", "VIII", "IX", "X")
      display_name <- paste("Lista", romans[num])
      display_name <- gsub("Lista\\s+([IVX]+)", "Lista <span class='roman-numeral'>\\1</span>", display_name)
    }
  }

  div(
    class = "main-content-empty",
    style = "padding: 60px 40px; text-align: center;",

    # Icon
    div(
      icon("layer-group", class = "fa-4x"),
      style = "color: #b1404f; opacity: 0.8; margin-bottom: 25px;"
    ),

    # Title
    h2(
      HTML(paste("Witaj w module: ", display_name)),
      style = "color: #4A4A4A; margin-bottom: 20px; font-weight: 600;"
    ),

    # Description
    p(
      style = "color: #606060; font-size: 1.2em; max-width: 600px; margin: 0 auto 40px; line-height: 1.6;",
      "Wybierz zadanie z menu po prawej stronie, aby rozpocząć pracę. Każde zadanie zawiera praktyczne przykłady i ćwiczenia do wykonania."
    ),

    # Instructions Box
    div(
      style = "background: #F4F6F9; padding: 30px; border-radius: 12px;
               border: 1px solid #e1e4e8; max-width: 500px; margin: 0 auto;",
      h4(
        style = "color: #b1404f; margin-top: 0; margin-bottom: 15px; font-weight: 600;",
        icon("list-check"), " Dostępne zadania"
      ),
      p(
        style = "margin-bottom: 0px; color: #505050;",
        "Zadania znajdują się w panelu bocznym po prawej stronie. Kliknij na numer lub nazwę zadania, aby przejść do jego treści."
      )
    ),

    # Arrow pointing right (visual cue)
    div(
      style = "margin-top: 40px; color: #b1404f; animation: bounceRight 2s infinite;",
      icon("arrow-right-long", class = "fa-2x")
    ),

    # CSS Animation for the arrow
    tags$style(HTML("
      @keyframes bounceRight {
        0%, 20%, 50%, 80%, 100% {transform: translateX(0);}
        40% {transform: translateX(10px);}
        60% {transform: translateX(5px);}
      }
    "))
  )
}

#' Display task content body
#' @param task Task object with content
#' @return Shiny div
task_display_body <- function(task) {
  # Just return the content. The header is now handled separately.
  # If task$content was wrapped in `main-content-body` before (in V3 it wasn't, in old tasks it wasn't, the wrapper was added in task_display).
  # renderers.R now puts this into a uiOutput with class "main-content-body".
  # So we just return the raw content.

  task$content
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
