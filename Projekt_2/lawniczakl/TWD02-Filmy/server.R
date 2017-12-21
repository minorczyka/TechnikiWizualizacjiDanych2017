#
# This is the server logic of a Shiny web application. You can run the 
# application by clicking 'Run App' above.
#
# Find out more about building applications with Shiny here:
# 
#    http://shiny.rstudio.com/
#

library(shiny)
library(dplyr)
library(ggplot2)
library(hms)
library(stringr)
library(reshape2)

# Define server logic required to draw a histogram
shinyServer(function(input, output) {
  
  scenario <- read.csv("data/scenario.csv", stringsAsFactors=TRUE) %>% 
      filter(start != 0, end != 0)
  
  timeHeroData <- reactive({
    dtl <- 60
    dtr <- 300
    time <- input$sliderTime
    if(is.null(time))
      time <- 0
    d1 <- scenario
    
    d1 <- d1 %>% filter(end > time-dtl, start < time+dtr)
    d1$start <- pmax(d1$start, time-dtl)
    d1$end <- pmin(d1$end, time+dtr)
    d1
  })
  
  sceneHeroData <- reactive({
    d1 <- scenario
    scenes <- input$sliderScene
    
    d1$scene <- d1$scene %>% as.factor %>% as.integer
    if(!is.null(scenes)) {
      d1 <- d1 %>% filter(scene >= scenes[1], scene <= scenes[2])
    }
    d1
  })
  
  
  timeHeroPlot <- function(heroes) {
    time <- input$sliderTime
    if(is.null(time))
      time <- 0
    d1 <- timeHeroData()
    if(!is.null(heroes)) {
      d1 <- d1 %>% filter(name %in% heroes)
      d1$name <- factor(d1$name, levels=heroes)
    }
    
    ggplot(d1, 
           aes(x=start, xend=end, y=name, yend=name, color=name)) +
      geom_segment(size=6) +
      geom_vline(xintercept=time) +
      scale_x_time(name="time") +
      theme(axis.title.y=element_blank(), 
            axis.title.x=element_blank(),
            legend.position="none")
  }
  
  sceneHeroPlot <- function(heroes) {
    d1 <- sceneHeroData() %>% select(name, scene) %>% distinct
    if(is.null(heroes)) {
      most_frequent <- d1 %>% group_by(name) %>%
        summarise(n = n()) %>% arrange(desc(n)) %>% head(n=9)
      d1 <- d1 %>% filter(name %in% most_frequent$name)
    } else {
      d1 <- d1 %>% filter(name %in% heroes)
      d1$name <- factor(d1$name, levels=heroes)
    }
    ggplot(d1, aes(x=scene, xend=scene+1, y=name, yend=name, color=name)) +
      geom_segment(size=6) +
      theme(legend.position="none",
            axis.title.x=element_blank(),
            axis.title.y=element_blank())
  }
  
  
  output$sliderTimeUI <- renderUI({
    data <- scenario
    if(input$group == "time") {
      maxTime <- data %>% select(end) %>% as.vector %>% max
      minVal <- as.POSIXct(0, origin="1970-01-01", tz="UTC")
      maxVal <- as.POSIXct(maxTime, origin="1970-01-01", tz="UTC")
      sliderInput("sliderTime", label="time", 
                  minVal, maxVal, minVal, timeFormat="%T",
                  timezone="UTC")
    } else {
      maxVal <- data %>% select(scene) %>% distinct %>% nrow
      sliderInput("sliderScene", label="scene",
                  1, maxVal, c(1, maxVal), step=1)
    }
  })
  
  output$sceneName <- renderText({
    if(input$group == "time") {
      time <- input$sliderTime
      if(is.null(time))
        time <- 0
      
      sc <- scenario %>% 
        filter(start <= time) %>%
        arrange(desc(start))
      if(nrow(sc) == 0)
        sc <- "UNKNOWN"
      else if(sc[1, "scene"] == "")
        sc <- "UNKNOWN"
      else
        sc <- sc[1, "scene"] %>% as.character
      sc
    } else {
      scNames <- scenario$scene %>% as.factor %>% levels
      scNames[scNames == ""] <- "UNKNOWN"
      scenes <- input$sliderScene
      paste(scNames[scenes[1]], scNames[scenes[2]], sep=" ~ ")
    }
  })
  
  output$heroesUI <- renderUI({
    if(input$heroAutoSel == "manually") {
      if(input$group == "time")
        names <- scenario$name %>% as.character %>% unique
      else
        names <- sceneHeroData()$name %>% as.character %>% unique
      names <- c(input$heroes, names)
      selectInput("heroes", "", multiple=TRUE, choices=names,
                  selected=input$heroes)
    }
  })
  
  output$heroGantt <- renderPlot({
    heroes <- input$heroes
    autoSel <- input$heroeAutoSel
    if(is.null(autoSel))
      autoSel <- "automatically"
    if(input$heroAutoSel == "automatically")
      heroes <- NULL
    if(input$group == "scenes") {
      sceneHeroPlot(heroes)
    } else {
      timeHeroPlot(heroes)
    }
  })
  
  output$keyWords <- renderPlot({
    if(is.null(input$keyWordSelection)) {
      kws <- "\\bRING\\b"
      kws1 <- "RING"
    } else {
      kws <- paste0("\\b", input$keyWordSelection, "\\b")
      kws1 <- input$keyWordSelection
    }
    if(input$group == "scenes")
      data <- sceneHeroData()
    else
      data <- timeHeroData()
    
    present<-matrix(nrow=nrow(data), ncol=length(kws))
    time <- numeric(nrow(data))
    for(i in 1:nrow(data)) {
      present[i,]<-str_count(toupper(data$dialog[i]), kws)
      time[i] <- (data$start[i]+data$end[i])/2
    }
    
    words <- data.frame(time, present)
    names(words) <- c("time", kws1)
    words <- melt(words, id.vars="time")
    
    ggplot(words, aes(x=time, y=value, color=variable)) + 
      geom_line(size=1) + 
      scale_x_time() +
      scale_y_continuous(expand=c(0, 0), limits=c(0, max(words$value)+0.1)) +
      scale_color_discrete(name="word") +
      theme(
        axis.title.x=element_blank(),
        axis.title.y=element_blank(),
        axis.ticks.y=element_blank()
      ) + 
      ggtitle("Key word frequency")
  })
})
