# Paweł Pollak

library(ggplot2)
library(reshape)
library(shiny)

function(input, output) {
  data <- read.table("data.txt", header = TRUE)
  data$Country <- factor(data$Country, levels = rev(levels(data$Country)))

  output$plotYears <- reactivePlot(function() {
    if(length(input$years) == 0 || length(input$countries) == 0)
      return()
    
    data.m <- reshape::melt(data[data$Country %in% input$countries,c(1, rev(as.numeric(input$years)))], id.vars='Country')
    
    y <- c("X", "2010", "2014", "2015")
    
    p <- ggplot2::ggplot(data.m, aes(Country, value)) +   
      geom_bar(aes(fill = variable), position = "dodge", stat="identity") +
      coord_flip() + 
      labs(x = "Kraj", y = "Procent PKB") +
      ylim(0,40) +
      scale_fill_brewer(palette = "Dark2") +
      theme(legend.title=element_blank()) + 
      scale_fill_discrete(labels=y[rev(as.numeric(input$years))])
    print(p)
  })
  
  output$plotShare <- reactivePlot(function() {
    if(length(input$countries) == 0)
      
    data <- read.table("data.txt", header = TRUE)
    data$Country <- factor(data$Country, levels = rev(levels(data$Country)))
    
    data.m2 <- reshape::melt(data[data$Country %in% input$countries, c(1, 6:10)], id.vars = 'Country')
    data.m2$Country <- factor(data.m2$Country, levels = rev(levels(data.m2$Country)))
    
    p <- ggplot(data.m2, aes(x = Country, y = value,fill=variable)) +
      geom_bar(stat='identity') + 
      coord_flip() + 
      labs(x = "Kraj", y = "Udział w wydatkach") +
      scale_fill_brewer(palette = "Dark2") +
      theme(legend.title=element_blank()) + 
      scale_fill_discrete(labels=c("Rodzina i dzieci", 
                                   "Bezrobocie",
                                   "Opieka zdrowotna i niepełnosprawność", 
                                   "Osoby w podeszłym wieku", 
                                   "Bezdomni, odrzuceni przez społeczeństwo"))
    print(p)
  })
}