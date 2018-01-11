
library(shiny)
library(ggplot2)
library(plotly)
library(dplyr)
library(lubridate)


shinyServer(function(input, output) {
  
  
  getWIGData <- reactive({
    
    from <- as.Date(input$daterange[1])
    to <- as.Date(input$daterange[2])

    validate(
      need(from < to, "End date is earlier than start date. Please choose another range."
      )
    )
    
    if(input$showSelectedMonth){
      futureDate <- from
      
      month(futureDate) <- month(futureDate) + 1
      mday(futureDate) <- 1
      
      
      print(futureDate)
      print(from)
      
      dane <- dane %>% filter(as.POSIXct(Date) > from & as.POSIXct(Date) < futureDate)
    } else {
      dane <- dane %>% filter(Date > from & Date < to)
    }
    
    validate(
      need(nrow(dane) > 0, "There is no date in that range. Please choose another range."
      )
    )
    
    return(dane)
  })
  
  output$trend = renderPlotly({
    dane <- getWIGData();
    rectwidth <- 1
    p <- ggplot(dane, aes(x=Data)) +
         geom_linerange(aes(ymin=Kurs.minimalny, ymax=Kurs.maksymalny)) +
         geom_rect(aes(ymin=Kurs.otwarcia,
                      ymax=Kurs.zamkniecia,
                      xmin=Data-rectwidth/2*0.9,
                      xmax=Data+rectwidth/2*0.9,
                      fill=Status),
                  color="black") +
         scale_fill_manual(values=c("red", "green")) +
         theme(legend.position="none") +
         ggtitle("WIG20") + 
         xlab("Date") + 
         ylab("Price")
    
    ggplotly(p)
  })
})
