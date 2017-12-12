library(ggplot2)
library(dplyr)
library(reshape2)
library(plotly)
library(shiny)


plotTypeNames<-c("dzielnice","typ")


partNames<-c("Bemowo","Białołęka","Bielany","Mokotów","Ochota","Praga-Północ","Praga-Południe","Rembertów","Śródmieście","Targówek",
             "Ursus","Ursynów","Wawer","Wesoła","Wilanów","Włochy" ,"Wola", "Żoliborz" )

shinyUI(fluidPage(
  titlePanel("Bezrobotni w Warszawie"),
  sidebarLayout(
    sidebarPanel(
      
     selectInput(inputId="plotType",
      label="Wybierz kryterium",
      choices=plotTypeNames,
      selected="dzielnice"),
      
     conditionalPanel(
       condition = "input.plotType == 'dzielnice'",
       selectInput("sectorMultiple", "Wybierz dzielnice",
                   partNames,
                   selected = partNames[1:10],
                   multiple = TRUE)
                  ),
     checkboxGroupInput("options", "Wybierz opcje", choices=c("Wszyscy","Kobiety","Mężczyźni"),selected=c("Kobiety","Mężczyźni"))
    ),
    mainPanel(
      plotlyOutput("plot", inline = T),
      dataTableOutput("table")
    )
  )
))