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
  
  titlePanel("TWD 02 - Władca pierścieni"),
  fluidRow(column(12, "Łukasz Ławniczak, Mateusz Mazurkiewicz",
                  style="margin-bottom:10px;")),
  
  fluidRow(
    column(12, "scene name(s):", align="center"),
    column(12, textOutput("sceneName"), 
           align="center", style="margin-top:-8px;
           margin-bottom:8px;font-size:20pt;")
  ),
  
  sidebarLayout(
    sidebarPanel(
      selectInput(inputId="group", label="Group by", 
                  choices=c("scenes", "time")),
      htmlOutput("sliderTimeUI"),
      selectInput("heroAutoSel", "Select visible heroes", 
                  choices=c("automatically", "manually")),
      htmlOutput("heroesUI"),
      selectInput("keyWordSelection", "Select key word", 
                  choices=c("RING", "MORDOR", "ELVES", "RIVENDELL", "MORIA", "SAURON", "SARUMAN", "ELROND", "SHIRE"),
                  selected="RING",
                  multiple=TRUE)
    ),
    
    mainPanel(
      plotOutput("heroGantt", height="250px"),
      br(),
      plotOutput("keyWords", height="250px")
    )
  )
))
