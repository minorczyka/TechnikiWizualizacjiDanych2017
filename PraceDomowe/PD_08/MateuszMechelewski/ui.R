library(shiny)
library(DT)
library(plotly)

fluidPage(
  titlePanel("Liczba wydanych praw jazdy w 2016 roku"),
  sidebarPanel(
         selectInput("district", "Województwo:",
                     c("Dolnośląskie" = "1",
                       "Kujawsko-pomorskie" = "2",
                       "Lubelskie" = "3",
                       "Lubuskie" = "4",
                       "Łódzkie" = "5",
                       "Małopolskie" = "6",
                       "Mazowieckie" = "7",
                       "Opolskie" = "8",
                       "Podkarpackie" = "9",
                       "Podlaskie" = "10",
                       "Pomorskie" = "11",
                       "Śląskie" = "12",
                       "Świętokrzyskie" = "13",
                       "Warmińsko-mazurskie" = "14",
                       "Wielkopolskie" = "15",
                       "Zachodniopomorskie" = "16"
                       ))
  ),
  mainPanel(
  tabsetPanel(
    tabPanel("Wykres statyczny", plotOutput("chart1")),
    tabPanel("Wykres interaktywny", plotlyOutput("chart2"))
  ))
)