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
    column(4, selectInput(inputId="group", label="Group by", 
                choices=c("scenes", "time"))),
    column(8, htmlOutput("sliderTimeUI"))
  ),
  fluidRow(
    column(12, "scene name(s):", align="center"),
    column(12, textOutput("sceneName"), 
           align="center", style="margin-top:-8px;
           margin-bottom:8px;font-size:28pt;")
  ),
  fluidRow(
    sidebarLayout(
      sidebarPanel(
        selectInput("heroAutoSel", "Select visible heroes", 
                    choices=c("automatically", "manually")),
        htmlOutput("heroesUI"),
        selectInput("keyWordSelection", "Select key word", 
                    choices=c("RING", "MORDOR", "ELVES", "RIVENDELL", "MORIA", "SAURON", "SARUMAN", "ELROND", "SHIRE"))
      ),
      
      mainPanel(
        plotOutput("heroGantt"),
        br(),
        plotOutput("keyWords", height = "80px")
      )
    )
  )
))
