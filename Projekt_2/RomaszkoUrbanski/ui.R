library(shiny)
library(PogromcyDanych)

nazwySeriali <- sort(levels(serialeIMDB$serial))
characters <- c("JULES", "VINCENT", "LANCE", "PUMPKIN", "HONEY BUNNY", "MARSELLUS", "BUTCH", "JIMMIE", "THE WOLF" )

shinyUI(fluidPage(
  tags$head(tags$style(HTML("
                            .col-sm-8 {
                              width: 100%;
                            }

                            "))),
  titlePanel("Pulp Fiction"),
  sidebarLayout(
    sidebarPanel = NULL,
    mainPanel(
      tabsetPanel(
        tabPanel("Sentiment", 
                 checkboxInput("scenes",
                               "Show scene images?",
                               value = TRUE),
                 checkboxInput("chronology",
                               "Show scenes in chronological order?",
                               value = FALSE),
                 plotOutput("sentiment")),
        tabPanel("Fucks", 
                 selectInput("baseBar", 
                                         label = "Choose a reference character",
                                         choices = characters,
                                         selected = characters[1]),
                 plotOutput("fucks"))
        
      ),
      width = 8
    )
  )
))