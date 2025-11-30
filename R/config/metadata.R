# ============================================
# LIST METADATA CONFIGURATION
# ============================================
# Defines all task lists with their properties

get_list_metadata <- function() {
  list(
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
      subtitle = "Zaawansowane",
      visible = FALSE
    ),
    list7 = list(
      id = "list7",
      name = "Lista VII",
      subtitle = "Projekty",
      visible = FALSE
    ),
    list8 = list(
      id = "list8",
      name = "Lista VIII",
      subtitle = "Aplikacje",
      visible = FALSE
    )
  )
}
