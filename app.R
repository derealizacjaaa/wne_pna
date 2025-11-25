# ============================================
# UNIVERSITY TASKS HUB - SHINY APP
# Programowanie narzędzi analitycznych
# ============================================

# Load required libraries
library(shiny)
library(bslib)
library(dplyr)
library(base64enc)
library(fontawesome)
library(maxLik)

# Load helper functions and task loader
source("tasks/helpers.R")
source("tasks/task_loader.R")

# Load all tasks
all_lists <- load_all_tasks()

# ============================================
# LIST METADATA
# ============================================

list_metadata <- list(
  list1 = list(
    id = "list1",
    name = "Lista I",
    subtitle = "Podstawy R"
  ),
  list2 = list(
    id = "list2",
    name = "Lista II",
    subtitle = "Wizualizacja"
  ),
  list3 = list(
    id = "list3",
    name = "Lista III",
    subtitle = "Struktury danych"
  ),
  list4 = list(
    id = "list4",
    name = "Lista IV",
    subtitle = "Analiza statystyczna"
  ),
  list5 = list(
    id = "list5",
    name = "Lista V",
    subtitle = "Programowanie"
  ),
  list6 = list(
    id = "list6",
    name = "Lista VI",
    subtitle = "Zaawansowane"
  ),
  list7 = list(
    id = "list7",
    name = "Lista VII",
    subtitle = "Projekty"
  )
)

# ============================================
# HELPER FUNCTIONS FOR UI GENERATION
# ============================================

# Generate LEFT sidebar (List Selection)
generate_list_sidebar <- function(list_metadata, current_list_id, all_lists, sidebar_collapsed) {
  list_items <- lapply(list_metadata, function(list_info) {
    # Handle NULL current_list_id - no list is active
    is_active <- !is.null(current_list_id) && list_info$id == current_list_id

    # Calculate progress for this list
    stats <- get_list_stats(all_lists, list_info$id)
    progress_text <- sprintf("%d/%d", stats$completed, stats$total)
    progress_percentage <- if(stats$total > 0) (stats$completed / stats$total) * 100 else 0
    is_complete <- stats$total > 0 && stats$completed == stats$total
    is_partial <- progress_percentage > 0 && progress_percentage < 100

    # Determine counter class based on completion
    counter_class <- if(is_complete) {
      "progress-text complete"
    } else if(is_partial) {
      "progress-text partial"
    } else {
      "progress-text empty"
    }

    tags$li(
      class = if(is_active) "list-item active" else "list-item",
      actionLink(
        paste0("select_", list_info$id),
        div(
          class = "list-item-content",
          # Vertical progress bar on the left
          div(
            class = "progress-bar-container-vertical",
            div(
              class = if(is_partial) "progress-bar-fill-vertical partial" else "progress-bar-fill-vertical",
              style = sprintf("height: %s%%;", progress_percentage)
            )
          ),
          # Text content
          div(
            class = "list-text",
            h4(
              HTML(gsub("(Lista\\s+)([IVX]+)", "\\1<span class='roman-numeral'>\\2</span>", list_info$name))
            )
          ),
          # Counter on the right
          div(
            class = "list-progress",
            tags$span(class = counter_class, progress_text)
          )
        )
      )
    )
  })

  # Calculate overall stats
  overall_stats <- get_overall_stats(all_lists)
  progress_percentage <- overall_stats$percentage

  tagList(
    # Section 1: Header
    div(
      class = "lists-sidebar-header",
      # Home button in dark section
      div(
        class = "sidebar-home-btn-container",
        actionButton(
          "home_btn",
          label = NULL,
          icon = icon("home"),
          class = "sidebar-home-btn"
        )
      ),
      div(
        class = "lists-sidebar-header-inner",
        h3("Listy Zadań"),
        actionButton(
          "toggle_sidebar",
          label = NULL,
          icon = icon("times"),
          class = "sidebar-toggle-btn"
        )
      )
    ),

    # Section 2: List of lists
    div(
      class = "lists-sidebar-menu",
      tagAppendChildren(
        tags$ul(class = "lists-menu"),
        list_items
      )
    ),

    # Section 3: Summary card
    div(
      class = "lists-sidebar-summary",
      div(
        class = "progress-summary-card",
        div(
          class = "summary-header",
          icon("chart-pie"),
          tags$span("Postęp ", class = "summary-header-text"),
          tags$span(overall_stats$total_lists, class = "summary-header-count"),
          tags$span(" list", class = "summary-header-text")
        ),
        div(
          class = "summary-stats",
          div(class = "summary-stat",
            tags$span(class = "stat-value stat-value-completed", overall_stats$completed_tasks),
            tags$span(class = "stat-label", "Ukończone")
          ),
          div(class = "summary-stat",
            tags$span(class = "stat-value stat-value-total", overall_stats$total_tasks),
            tags$span(class = "stat-label", "Zadania")
          )
        ),
        div(
          class = "summary-progress-bar",
          div(
            class = "summary-progress-fill",
            style = sprintf("width: %s%%;", progress_percentage)
          )
        ),
        div(class = "summary-percentage", sprintf("%d%%", progress_percentage))
      )
    )
  )
}

# Generate RIGHT sidebar (Task Selection within List)
generate_task_sidebar <- function(tasks, current_task_id, current_list_name, all_lists) {
  if (is.null(tasks) || length(tasks) == 0) {
    return(div(
      class = "tasks-sidebar-content",
      h3(icon("list"), " Zadania"),
      p("Brak zadań w tej liście")
    ))
  }

  task_items <- lapply(seq_along(tasks), function(i) {
    task_id <- names(tasks)[i]
    task_info <- tasks[[i]]
    is_active <- task_id == current_task_id

    # Generate task name from task_num if not provided
    task_name <- if(!is.null(task_info$name)) {
      task_info$name
    } else {
      sprintf("Zadanie %d", task_info$task_num)
    }

    # Use completed field (TRUE/FALSE) instead of status
    is_completed <- isTRUE(task_info$completed)

    tags$li(
      class = if(is_active) "task-item active" else "task-item",
      actionLink(
        paste0("select_task_", task_id),
        div(
          div(class = "task-number", sprintf("%02d", task_info$task_num)),
          div(class = "task-name", task_name),
          if(is_completed) {
            div(
              class = "task-status status-completed",
              icon("circle-check")
            )
          }
        )
      )
    )
  })

  div(
    class = "tasks-sidebar-content",
    h3(icon("list"), " ", current_list_name),
    tags$ul(class = "tasks-menu", task_items)
  )
}

# ============================================
# USER INTERFACE
# ============================================

ui <- fluidPage(
  # Page title
  title = "University Tasks Hub",

  # Include CSS files in specific order
  tags$head(
    tags$link(rel = "stylesheet", type = "text/css", href = "css/main.css"),
    tags$link(rel = "stylesheet", type = "text/css", href = "css/header.css"),
    tags$link(rel = "stylesheet", type = "text/css", href = "css/navbar.css"),
    tags$link(rel = "stylesheet", type = "text/css", href = "css/layout.css"),
    tags$link(rel = "stylesheet", type = "text/css", href = "css/left-sidebar.css"),
    tags$link(rel = "stylesheet", type = "text/css", href = "css/right-sidebar.css"),
    tags$link(rel = "stylesheet", type = "text/css", href = "css/progress-card.css"),
    tags$link(rel = "stylesheet", type = "text/css", href = "css/main-content.css")
  ),

  # Hero Header Section
  div(
    class = "hero-header",

    # Text on left
    div(
      class = "hero-text",
      h1("Programowanie narzędzi analitycznych"),
      p(tags$span("Grupa ", class = "subtitle-top"),
        tags$span("16:45", class = "subtitle-top-red")),
      tags$hr(class = "hero-divider"),
      p(tags$span("Maksymilian Okumski | ", class = "subtitle-bottom"),
        tags$span("Zima 2025/26", class = "subtitle-bottom-red"))
    ),

    # Logo on right
    div(
      class = "hero-logo",
      tags$img(
        src = "https://coin.wne.uw.edu.pl/dmycielska/Logo_WNE_UW_PL.png",
        alt = "University Logo"
      )
    )
  ),

  # Main content wrapper
  div(
    class = "content-wrapper-dual",
    uiOutput("dynamic_layout")
  )
)

# ============================================
# SERVER LOGIC
# ============================================

server <- function(input, output, session) {

  # Reactive values
  current_list <- reactiveVal(NULL)  # Start with no list selected
  current_task <- reactiveVal(NULL)
  sidebar_collapsed <- reactiveVal(FALSE)

  # Reactive: Get tasks for current list
  current_list_tasks <- reactive({
    if (is.null(current_list())) {
      return(NULL)
    }
    all_lists[[current_list()]]
  })

  # Observer for sidebar toggle
  observeEvent(input$toggle_sidebar, {
    sidebar_collapsed(!sidebar_collapsed())
  }, priority = 100)

  # Observer for home button - return to main container
  observeEvent(input$home_btn, {
    current_list(NULL)
    current_task(NULL)
  }, priority = 100)

  # Create observers for list selection
  observe({
    lapply(names(list_metadata), function(list_id) {
      observeEvent(input[[paste0("select_", list_id)]], {
        current_list(list_id)
        # Reset to first task of new list
        tasks <- all_lists[[list_id]]
        if (!is.null(tasks) && length(tasks) > 0) {
          current_task(names(tasks)[1])
        } else {
          current_task(NULL)
        }
      }, ignoreInit = TRUE, priority = 100)
    })
  })

  # Create observers for task selection
  observe({
    tasks <- current_list_tasks()
    if (!is.null(tasks)) {
      lapply(names(tasks), function(task_id) {
        observeEvent(input[[paste0("select_task_", task_id)]], {
          current_task(task_id)
        }, ignoreInit = TRUE, priority = 100)
      })
    }
  })

  # Render left sidebar
  output$list_sidebar <- renderUI({
    generate_list_sidebar(list_metadata, current_list(), all_lists, sidebar_collapsed())
  })

  # Render right sidebar
  output$task_sidebar <- renderUI({
    if (is.null(current_list())) {
      return(div(
        class = "tasks-sidebar-content",
        h3(icon("list"), " Zadania"),
        p(style = "color: #606060; padding: 20px; text-align: center;",
          "Wybierz listę z lewego panelu")
      ))
    }
    current_list_name <- list_metadata[[current_list()]]$name
    generate_task_sidebar(current_list_tasks(), current_task(), current_list_name, all_lists)
  })

  # Render main content
  output$main_content <- renderUI({
    if (is.null(current_task())) {
      return(div(
        class = "main-content",
        # Navbar to match task navbars
        div(
          class = "navbar",
          style = "background: #b1404f; color: white; border-bottom: 4px solid #4A4A4A; min-height: 56px; height: 56px; box-sizing: border-box; display: flex; align-items: center; padding: 0 20px; margin: 0;",
          h3(style = "margin: 0; color: white; font-size: 1.1em; font-weight: 600;",
             icon("home"), " Strona główna")
        ),
        # Main content
        div(
          class = "main-content-empty",
          style = "padding: 60px 40px;",
          icon("graduation-cap", class = "fa-3x", style = "color: #b1404f; opacity: 0.7; margin-bottom: 20px;"),
          h2("Witaj w Hub'ie Zadań!", style = "color: #4A4A4A; margin-bottom: 15px;"),
          p(style = "color: #606060; font-size: 1.1em; max-width: 600px; margin: 0 auto 30px;",
            "System zarządzania zadaniami z kursu Programowanie Narzędzi Analitycznych"),
          div(
            style = "background: #F4F6F9; padding: 30px; border-radius: 8px;
                     border-left: 4px solid #b1404f; max-width: 700px; margin: 0 auto;",
            h3(style = "color: #4A4A4A; margin-top: 0;", icon("lightbulb"), " Jak zacząć?"),
            tags$ol(
              style = "text-align: left; color: #606060; line-height: 1.8;",
              tags$li("Wybierz listę zadań z ", tags$strong("lewego panelu"), " (np. Lista I - Podstawy R)"),
              tags$li("Następnie wybierz konkretne zadanie z ", tags$strong("prawego panelu")),
              tags$li("Zadanie wyświetli się tutaj wraz z kodem i rozwiązaniami")
            )
          ),
          div(
            style = "margin-top: 40px; padding: 20px; background: white;
                     border-radius: 8px; border: 2px dashed #b1404f;
                     max-width: 500px; margin-left: auto; margin-right: auto;",
            p(style = "color: #b1404f; font-weight: 600; margin: 0;",
              icon("arrow-left"), " Zacznij od wyboru listy po lewej stronie")
          )
        )
      ))
    }

    tasks <- current_list_tasks()
    task <- tasks[[current_task()]]

    # Simply render task content
    div(
      class = "main-content",
      task$content
    )
  })

  # Dynamic UI for layout based on sidebar state
  output$dynamic_layout <- renderUI({
    div(
      class = if(sidebar_collapsed()) "app-container sidebar-collapsed" else "app-container",

      # Toggle button for collapsed state
      if(sidebar_collapsed()) {
        actionButton(
          "toggle_sidebar",
          label = NULL,
          icon = icon("bars"),
          class = "sidebar-toggle-btn-collapsed"
        )
      },

      # LEFT SIDEBAR - Lists (collapsible)
      if(!sidebar_collapsed()) {
        div(
          class = "left-sidebar",
          uiOutput("list_sidebar")
        )
      },

      # MAIN CONTENT
      div(
        class = "main-area",
        uiOutput("main_content")
      ),

      # RIGHT SIDEBAR - Tasks
      div(
        class = "right-sidebar",
        uiOutput("task_sidebar")
      )
    )
  })
}

# ============================================
# RUN APPLICATION
# ============================================

shinyApp(ui = ui, server = server)
