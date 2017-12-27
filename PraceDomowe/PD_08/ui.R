library(shiny)
source("data.R")
data <- getData() 

fluidPage(    
  titlePanel("Temperatures by month"),
  
  sidebarLayout(      
    
    sidebarPanel(
      selectInput("month", "Month:", 
                  choices=colnames(data), selected = "January"),
      hr(),
      helpText("Yearly temperatures in most popular holiday cities"),
      helpText("Source: http://www.holiday-weather.com/bali/averages/")
    ),
    
    mainPanel(
      plotOutput("temperaturePlot")  
    )
    
  )
)