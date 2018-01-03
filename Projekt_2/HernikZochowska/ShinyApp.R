source("GraphCreation.R")
source("DataReading.R")
library(shiny)


ui <- shinyUI(fluidPage(
  
    titlePanel("Interpersonal relations in House"),
    sidebarLayout(
      sidebarPanel(
        checkboxInput("season4", "4", value = TRUE, width = NULL),
        checkboxInput("season5", "5", value = TRUE, width = NULL)
      ),
      mainPanel(
          tabPanel("Force Network", forceNetworkOutput("force"))
    )
    
  
    )
  )
)

server <- shinyServer(function(input, output) {

  output$force <- renderForceNetwork({ 
    seasons = c()
    if (input$season4) { seasons = c(seasons, 4)}
    if (input$season5) { seasons = c(seasons, 5)}
    print(seasons)
    df = filter(house, Season %in% seasons)
    print(nrow(df))
    createRelationPlot(df)
  })
})

shinyApp(ui, server)
