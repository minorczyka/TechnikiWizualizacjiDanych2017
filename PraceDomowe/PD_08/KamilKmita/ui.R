options(shinyapps.locale='pl_PL')

dane <- readRDS("dane.RDS")


library(shiny)
library(shinyjs)




shinyUI(fluidPage(
  
  useShinyjs(),

  titlePanel("Jak grają Legioniści w sezonie 2017/2018?"),
  
  sidebarLayout(
    sidebarPanel(
      

      
      radioButtons(
        inputId="filtr",
        label="Ukryj/pokaż panel filtru poszczególnych piłkarzy",
        choices=list(
          "Pokaż",
          "Ukryj"
        ),
        selected="Pokaż"),      


      checkboxGroupInput(inputId = "wybraneformacje",
                         label = "Zaznacz formacje, które chcesz analizować (można kilka na raz)",
                         choices = c("bramka", "obrona", "pomoc", "atak"),
                         selected = character(0)),

      conditionalPanel(
        condition = "input.filtr == 'Pokaż'",
      htmlOutput("listaPilkarzy")),
      
      sliderInput(inputId = "range", label = "Zaznacz zakres kolejek:",
                  min = 1, max = 15,
                  value = c(1,1))
    ),
    
    mainPanel(
      
      tabsetPanel(
        tabPanel("Wykres", 
                 p("Oceny w poszczególnych kolejkach Ekstraklasy"), 
                 plotlyOutput("trend")),
        
        tabPanel("Informacje dot. wykonanej wizualizacji",
                 
                 verbatimTextOutput("napis")
        )    
      )
    )
  )
  ))
  
