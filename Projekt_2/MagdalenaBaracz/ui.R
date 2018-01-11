shinyUI(fluidPage(
  
  includeCSS("style.css"),
  headerPanel("Pick your favourite hero in the Avengers movie"),
  
  sidebarPanel(
    width = 2,
    tags$head(tags$script('$(document).on("shiny:connected", function(e) {
                          Shiny.onInputChange("innerWidth", window.innerWidth);
                          });
                          $(window).resize(function(e) {
                          Shiny.onInputChange("innerWidth", window.innerWidth);
                          });
                          ')),
    helpText("Select your favourite hero"),
    selectInput("character", "Character:",
                list("ALL" = "ALL",
                     "IRON MAN" = "TONY/IRON MAN", 
                     "THOR" = "THOR", 
                     "CAPTAIN AMERICA" = "STEVE/CAPTAIN AMERICA", 
                     "NICK FURY" = "NICK FURY", 
                     "BLACK WIDOW" = "NATASHA/BLACK WIDOW", 
                     "LOKI" = "LOKI",
                     "HAWKEYE" = "CLINT BARTON/HAWKEYE",
                     "HULK" = "BANNER/HULK"),
                selected="ALL"
    ),
    hr(),
    helpText("Select a feature to compare"),
    selectInput("fill", "Fill:",
                list("EMOTIONS" = "emo",
                     "DAYTIME" = "daytime", 
                     "HERO SCREEN TIME" = "hero"),
                selected="hero"),
    hr(),
    helpText("Find out more quotes!"),
    actionButton("refreshButton", "Refresh quote!")
    ),
  
  mainPanel(
    fluidRow(
      column(12, align="center",
             plotOutput("avngPlot"),
             fluidRow(
               column(12, align="center",
                      fluidRow(
                        column(6,align="right", 
                               imageOutput("avngImage")),
                        column(6,align="left",
                               h3(htmlOutput("quote"), inline=TRUE))
                      )
               )
             )
      )
    )
  )
  
  
    ))