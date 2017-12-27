data <- read.csv("data.csv", h=TRUE)

ui<-shinyUI(pageWithSidebar(
  
  # Application title
  headerPanel("What was the top grossing film of the year?"),
  
  # Sidebar with controls to select the variable to plot against mpg
  # and to specify whether outliers should be included
  sidebarPanel(
    selectInput("variable", "Characteristics:",
                list("Popularity" = "popularity", 
                     "Vote average" = "vote_average", 
                     "Vote count" = "vote_count")),
    sliderInput("range", 
                "Years:",
                min = min(data$release_date), 
                max =  max(data$release_date), 
                value = c(min(data$release_date),max(data$release_date)),
                sep = "",
                animate=TRUE)
  ),
  
  mainPanel(
    plotOutput("plot", width = "100%"),
    verbatimTextOutput("event")
  )
))