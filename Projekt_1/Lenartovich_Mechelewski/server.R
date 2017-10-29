library(shiny)
library(DT)

source("delaysMap.R")
source("speedsMap.R")
source("districtsMap.R")
source("tramsOnNextStop.R")

ui <- fluidPage(
  titlePanel("Tramwaje Warszawskie"),
  column(4,
    h4("Aktualne opóźnienia"),
    tabsetPanel(
      tabPanel("Mapa", leafletOutput("delaysMap")), 
      tabPanel("Tabela", h4("Tabela")), 
      tabPanel("Podsumowanie", h4("Podsumowanie"))
    )
  ),
  column(4,
    h4("Aktualna prędkość"),
    tabsetPanel(
      tabPanel("Mapa", leafletOutput("speedsMap")), 
      tabPanel("Tabela", h4("Tabela")), 
      tabPanel("Podsumowanie", h4("Podsumowanie"))
    )
  ),
  column(4,
    h4("Liczba tramwajów w dzielnicach"),
    tabsetPanel(
      tabPanel("Mapa", leafletOutput("districtsMap")), 
      tabPanel("Tabela", h4("Tabela")), 
      tabPanel("Podsumowanie", h4("Podsumowanie"))
     )
  ),
  textInput("nextStop", "Następny przystanek", "7002-Dw.Centralny"),
  tabPanel("Najbliższe odjazdy", dataTableOutput("stopTrams"))
)

server <- function(input, output, session) {
  data <- getData()
  output$delaysMap <- renderLeaflet(getDelaysMap(data))
  output$speedsMap <- renderLeaflet(getSpeedsMap(data))
  output$districtsMap <- renderLeaflet(getDistrictsMap(data))
  output$stopTrams <- DT::renderDataTable({ getTramsForNextStop(data, input$nextStop) }) 
}

shinyApp(ui, server)