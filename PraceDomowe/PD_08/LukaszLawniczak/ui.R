#
# This is the user-interface definition of a Shiny web application. You can
# run the application by clicking 'Run App' above.
#
# Find out more about building applications with Shiny here:
# 
#    http://shiny.rstudio.com/
#

library(shiny)

# Define UI for application that draws a histogram
shinyUI(fluidPage(
  
  # Application title
  titlePanel("Urządzenia wykorzystywane do oglądania treści wideo"),
  
  htmlOutput("info"),
  
  # Sidebar with a slider input for number of bins 
  sidebarLayout(
    sidebarPanel(
       selectInput("plotId", "Wykres", 
                   c("urządzenia",
                     "internet+telewizja"),
                   selected="urządzenia"),
       checkboxInput("showValues", "Pokaż wartości", FALSE),
       htmlOutput("showAverages")
    ),
    
    # Show a plot of the generated distribution
    mainPanel(
       plotOutput("distPlot")
    )
  )
))
