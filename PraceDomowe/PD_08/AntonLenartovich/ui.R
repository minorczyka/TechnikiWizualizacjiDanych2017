library(shiny)
library(ggplot2)
library(plotly)

shinyUI(fluidPage(
  tags$head(
    tags$style(HTML("
      .modebar  {
        display: none
      }
    "))
  ),
 
  titlePanel("Porównanie wyników drużyn NBA z lat 1998 - 2017"),
  wellPanel(
    
    tags$div(
      "Celem tej pracy domowej jest przedstawienie zależności pomiędzy uzyskanie tytułu mistrza NBA a statystykami, które konkretna drużyna uzyskała. Dane
             pochodzą ze strony ", 
          a("www.nbaminer.com", href="http://www.nbaminer.com/basic-stats/"),
      "Zostały wybrane 7 podstawowych statystyk. Opis każdej z nich pojawi się bezpośrednio po jej wybraniu. Na tak przedstwionych danych można spróbować odczytać 
      pewny trend konkretnych statystyk (o ile taki istnieje) na przestrzeni prawie 20-letniego rozwoju tego sportu." 
    )
  ),
  sidebarLayout(
    sidebarPanel(
     sliderInput(inputId="year",
                 label="Choose year:",
                 min = 1998,
                 max = 2017,
                 value = c(1998, 2017),sep = ""),
     selectInput(inputId="category",
                 label="Choose variable:",
                 choices = c("Points", "Fast break points", "Points scores in paint", "Points off turnovers",  
                             "Second chance points scored", "Average lead change",  "Average number of tied times"),
                 selected = "Points"),
     checkboxInput(inputId="showChampions",
                   value = FALSE, label = "show only champions stats"),
     wellPanel(
       textOutput("description")
     )
     
    ),
    mainPanel(
      plotlyOutput("trend"),
      verbatimTextOutput("model")
    )
  )
))


