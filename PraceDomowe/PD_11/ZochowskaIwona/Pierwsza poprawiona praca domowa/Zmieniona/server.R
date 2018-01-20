library(dplyr)
library(plotly)
library(shiny)

function(input, output) {
  
  data <- read.csv("data.csv", h=TRUE)
  output$plot <- reactivePlot(function() {
    p <- ggplot(data, aes_string(x=data$release_date, y=data$revenue, fill=input$variable)) + 
      coord_flip()+
      geom_text(aes(x=as.numeric(data$release_date),
                    y=data$revenue + 0.3 * sign(data$revenue),
                    label=data$title,
                    hjust=ifelse(data$revenue > 0,0,1)), 
                size=3,
                color=rgb(100,100,100, maxColorValue=255)) +
      theme(axis.text.x=element_text(angle=90,hjust=1)) + geom_bar(stat="identity") +
      scale_y_continuous(name="Revenue", labels = scales::comma) +
      scale_x_continuous(breaks=seq(input$range[1],input$range[2],1), limits = input$range) +
      scale_fill_gradient(low="blue", high="red")  +                                                                                                        
    
      labs(x="Year")
    print(p)
  })
}