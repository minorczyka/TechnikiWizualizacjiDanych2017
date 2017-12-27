library(shiny)
library(ggplot2)
library(dplyr)
library(stringr)
library(reshape)


pl_energy <- read.csv('PL_energy.csv')
zrodla <- sort(levels(pl_energy$Zrodlo.Energii))

shinyUI(fluidPage(
  tags$head(tags$style(HTML("
                            .well {
                            width: 200px;
                            }
                            "))),
  titlePanel("Energia w Polsce"),
  sidebarLayout(
    sidebarPanel(
      checkboxGroupInput("Zrodla", 
                  label = "Wybierz zrodla energii",
                  choices = zrodla,
                  selected = "coal"),
      
      sliderInput("Rok",
                  label = "Przedzial lat",
                 min=1980, max=2017, value=c(2000, 2017)),
      
      htmlOutput("PrzedzialLat")
    ),
    mainPanel(

        tabPanel("Wykres", 
                 p(""), 
                 plotOutput("energy_plot", width="100%"))
        
      )
    )
  )
)
