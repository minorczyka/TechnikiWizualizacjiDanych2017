
library(shiny)
library(ggplot2)
library(plotly)

shinyServer(function(input, output) {
  
  selectedCategory <- reactive({
   
    from <- as.numeric(input$year[1])
    to <- as.numeric(input$year[2])
    
    category <- mapper(input$category)
    
    dane <- dane %>% filter(SeasonType == "REG" & year >= from & year <= to) %>% select(year, Team, category, IsNBAChampion)
    dane$IsNBAChampion <- ifelse(dane$IsNBAChampion == 1, T, F)
    
    if(input$showChampions){
      dane <- dane %>% filter(IsNBAChampion == T)
    }
    
    dane
  })
  
  output$trend = renderPlotly({
    myColors <- c("gray", "orange")
    stats <- selectedCategory()
    names(stats) <- c("year", "team", "category", "IsNBAChampion")
    
    p <- ggplot(stats, aes(year,category,text=paste("team:",team))) +
      theme_light() + 
      theme(legend.position='none') + 
      ylab(input$category) + 
      xlab("year") + 
      geom_point(stroke=1, size=2) 
    
    if(input$showChampions){
      p <- p +
        geom_point(color="orange", size=2)
    } else {
      p <- p + 
        geom_point(aes(colour=IsNBAChampion), size=2) +
        scale_colour_manual(values = myColors)
    }
    
    ggplotly(p)
  })
  
  output$description = renderText({
    print(getDescription(input$category))
    getDescription(input$category)
  })
})


namesToShow <- function(){
  c("Points", "Fast break points", "Points scores in paint", "Points off turnovers",  
    "Second chance points scored", "Average lead change",  "Average number of tied times")
}

allowedCols <- function(){
  c("Pts", "FastBreakPts", "PointsInPaint", "PointsOffTO", 
    "X2ndChancePTS", "LeadChanges",  "TimesTied")
}

mapper <- function(value){
  allowedCols()[which(namesToShow() == value)]
}


getDescription <- function(value){
  index <- which(namesToShow() == value)
  descr <-  c("Points: average points per game",
              "Fast break points: an offensive strategy in which the team tries to move the ball into scoring position as quickly as possible (either by passing or by dribbling) in order to get a man advantage on offense.",
    "Points scores in paint: average number of points scored from the free-throw line per game",
    "Points off turnovers: when a team commits a turnover, the scoring crew records the turnover. On the following opponent possession, if the opponent scores, the scoring system credits that opponent with a 'point off a turnover'",
    "Second chance points scored: any points other than technical foul shots resulting from the possession following an offensive rebound. Possession is considered to have ended when the opposing team gains control of the ball.",
    "Average lead change: how many times per game a leader changes",
    "Average number of tied times"
    )
  
  descr[index]
}