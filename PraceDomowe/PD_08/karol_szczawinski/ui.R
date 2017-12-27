library(shiny)
library(PogromcyDanych)


choices <-c("Kraju", "Zawodnika", "Klubu")

shinyUI(fluidPage(
  titlePanel("Ranking Złotej Piłki"),
  p("W związku z tym, że niedawno przyznano nagrodę Złotej Piłki, przygotowano aplikację przedstawiającą ranking dla
    tej nagrody w trzech kateogriach. Dane pobrano ze strony: ", 
    HTML(paste0('',a(href = 'https://en.wikipedia.org/wiki/Ballon_d%27Or', 'https://en.wikipedia.org/wiki/Ballon_d%27Or')))
    ),
  sidebarLayout(
    sidebarPanel(
      selectInput(inputId = "chart", 
                  label = "Wybierz wykres do analizy (ranking wzlędem)",
                  choices = choices,
                  selected = "Kraj"),
      checkboxInput("show", "Wykres interaktywny", value = TRUE),
      sliderInput(min = 3,max = 9, value = 9, inputId = "sl1", label = "Liczba pokazywanych rekordów")
    ),
    mainPanel(
      conditionalPanel("!input.show", plotOutput("trend", height = "600px")),
      conditionalPanel("input.show", plotlyOutput("trend2", height = "600px"))
    )
  )
))