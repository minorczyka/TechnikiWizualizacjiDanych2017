library(shiny)
library(plotly)

load("currencies.rda")

shinyUI(fluidPage(
  titlePanel("Ceny kryptowalut cały czas rosną"),
  sidebarLayout(
    sidebarPanel(
      selectInput("cryptocurrency", 
                  label = "Wybierz kryptowaluty",
                  choices = levels(currencies$Currency),
                  selected = "BitCoin",
                  multiple = TRUE),
      checkboxInput("trendLine",
                    "Czy zaznaczyć linię trendu?",
                    value = TRUE),
      selectInput("weeks",
                  label = "Z ilu ostatnich tygodni pokazać dane?",
                  choices = c("1 tydzień", "2 tygodnie", "3 tygodnie", "4 tygodnie"),
                  selected = "4 tygodnie"
                  ),
      selectInput("metric",
                  label="Wybierz metrykę",
                  choices=c("Najniższa cena", "Najwyższa cena", "Cena otwarcia", "Cena zamknięcia"),
                  selected="Najniższa cena"),
      p("Dane na 06.12.2017r
        ")
    ),
    mainPanel(
      tabsetPanel(
        tabPanel("Wykres",
                 plotOutput("currencyPlot")),
        tabPanel("Interaktywny",
                 plotlyOutput("currencyPlotly")),
        tabPanel("Szczegóły",
                 dataTableOutput("details")
        )    
      )
    )
  )
  ))