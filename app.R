# ============================================
# UNIVERSITY TASKS HUB - SHINY APP
# Programowanie narzędzi analitycznych
# ============================================
# Modular architecture for maintainability

# Load required libraries
library(shiny)
library(bslib)
library(dplyr)
library(base64enc)
library(fontawesome)
library(maxLik)
library(ggplot2)

# ============================================
# SOURCE MODULES
# ============================================

# Configuration
source("R/config/metadata.R")

# Task system
source("R/tasks/display.R")
source("R/tasks/executor.R")
source("R/tasks/builder.R")
source("R/tasks/builder_v2.R")  # File-based builder (typed files)
source("R/tasks/builder_v3.R")  # File-based builder (inline functions)
source("R/tasks/loader.R")

# UI components
source("R/ui/components.R")
source("R/ui/sidebar_left.R")
source("R/ui/sidebar_right.R")
source("R/ui/main_content.R")

# Server logic
source("R/server/state.R")
source("R/server/observers.R")
source("R/server/renderers.R")

# ============================================
# INITIALIZE DATA
# ============================================

# Dynamically discover list metadata from tasks directory
# Lists are auto-generated based on existing folders (list1, list2, etc.)
# Tasks are loaded lazily when user selects a list
list_metadata <- get_list_metadata()

# ============================================
# USER INTERFACE
# ============================================

ui <- fluidPage(
  title = "University Tasks Hub",

  # Include CSS files
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

  # Hero header
  div(
    class = "hero-header",
    div(
      class = "hero-text",
      h1("Programowanie narzędzi analitycznych"),
      p(
        tags$span("Grupa ", class = "subtitle-top"),
        tags$span("16:45", class = "subtitle-top-red")
      ),
      tags$hr(class = "hero-divider"),
      p(
        tags$span("Maksymilian Okumski | ", class = "subtitle-bottom"),
        tags$span("Zima 2025/26", class = "subtitle-bottom-red")
      )
    ),
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

  # Initialize reactive state
  state <- init_reactive_state()

  # Reactive value for loaded lists (initially empty, loaded on demand)
  all_lists <- reactiveVal(list())

  # Create reactive expressions
  current_list_tasks <- create_current_list_tasks(state, all_lists)

  # Setup observers (includes lazy loading logic)
  setup_observers(input, state, list_metadata, all_lists, current_list_tasks)

  # Setup renderers
  setup_renderers(output, state, list_metadata, all_lists, current_list_tasks)
}

# ============================================
# RUN APPLICATION
# ============================================

shinyApp(ui = ui, server = server)
