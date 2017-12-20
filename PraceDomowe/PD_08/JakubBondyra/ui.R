library(shiny)
library(plotly)
library(ggplot2)

load("data.rda")
unique(data$country)
shinyUI(fluidPage(
  titlePanel("Dairy production in different countries"),
  sidebarPanel(
    #input kraju
    selectInput("country",
                choices = unique(data$country),
                label="Select countries...",
                multiple=T,
                selected=c("Poland","Afghanistan")
                )
  ),
  mainPanel(
    plotlyOutput("dairyPlot"),
    HTML("<p>Source: https://apps.fas.usda.gov/psdonline/downloads/psd_dairy_csv.zip</p>")
  )
  )
)