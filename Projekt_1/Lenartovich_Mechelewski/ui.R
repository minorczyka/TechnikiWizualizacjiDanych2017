library(shiny)
library(DT)
library(leaflet)

fluidPage(
  tags$head(
    tags$link(rel="stylesheet", type="text/css",href="style.css"),
    tags$script(type="text/javascript", src = "busy.js")
  ),
  div(class = "busy",  
      p("Trwa pobieranie danych..."), 
      img(src="Spinner.gif")
  ),
  titlePanel("Tramwaje Warszawskie"),
  verbatimTextOutput("currentTime"),
  column(4,
         h4("Aktualne opóźnienia"),
         leafletOutput("delaysMap")
  ),
  column(4,
         h4("Aktualna prędkość"),
         leafletOutput("speedsMap")
  ),
  column(4,
         h4("Liczba tramwajów w dzielnicach"),
         leafletOutput("districtsMap")
  ),
  textInput("nextStop", "Następny przystanek", "7002-Dw.Centralny"),
  tabPanel("Najbliższe odjazdy", dataTableOutput("stopTrams"))
)