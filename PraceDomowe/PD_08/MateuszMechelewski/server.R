library(shiny)
library(ggplot2)
library(directlabels)
library(plotly)

source("data.R")
source("plotChart.R")

function(input, output, session) {
  data <- getData()
  
  output$chart1 <- renderPlot(getChart(data, as.integer(input$district)))
  #output$chart2 <- renderPlot()
  output$chart2 <- renderPlotly(ggplotly(getChart(data, as.integer(input$district)), tooltip = c("group", "x", "y")))
}