library(shiny)
library(PogromcyDanych)

nazwySeriali <- sort(levels(serialeIMDB$serial))

shinyUI(fluidPage(
  tags$head(tags$style(HTML("
                            .well {
                            background-color: #dd9999!important;
                            width: 200px;
                            }
                            "))),
  titlePanel("LEADER w 2017 roku – podsumowanie działalności lokalnych grup działania"),
  sidebarLayout(
    sidebarPanel(
      selectInput("sortowanie", 
                  label = "Wybierz rodzaj sortowania",
                  choices = c("alfabetycznie", "rosnaco", "malejaco"),
                  selected = "alfabetycznie"),
      checkboxInput("wysokoscSlupka",
                    "Czy zaznaczyć wysokość słupka?",
                    value = TRUE)
    ),
    mainPanel(
      tabsetPanel(
        tabPanel("Wykres 1", 
                 p("Liczba przeprowadzonych naborów przez poszczególne lokalne grupy działania."), 
                 plotOutput("wyk1")),
        tabPanel("Wykres 2", 
                 p("Ilość środków uruchomionych w ramach naborów wniosków."), 
                 plotOutput("wyk2")),
        tabPanel("Wykres 3", 
                 p("Wykorzystanie budżetu na wdrażanie lokalnych strategii przez poszczególne lokalne grupy działania."), 
                 plotOutput("wyk3")),
        tabPanel("Tabela",
                 p("Tabela podsumowująca poprzednie wykresy"),
                 verbatimTextOutput("tab")
        )    
      )
    )
  )
  ))