library(shiny)
library(ggplot2)
library(plotly)

load("currencies.rda")

shinyServer(function(input, output, session) {
  cryptoframe <- reactive({
    timeframe <- as.numeric(substr(input$weeks, 1, 1))
    diffs <- abs(difftime(as.Date("2017-12-06"), currencies$Date , units = c("days"))) < (timeframe * 7)
    
    curr <- currencies[diffs, ]
    curr[curr$Currency %in% input$cryptocurrency, ]
  })
  
  cryptoMetric <- reactive({
    if (input$metric == "Najniższa cena") {return("Low")}
    if (input$metric == "Najwyższa cena") {return("High")}
    if (input$metric == "Cena otwarcia") {return("Open")}
    if (input$metric == "Cena zamknięcia") {return("Close")}
  })
  
  cryptoMinMax <- reactive({
    frame <- cryptoframe()
    
    vec <- c(frame$Low, frame$High, frame$Open, frame$Close)
    return(c(min(vec), max(vec)))
  })
  
  output$currencyPlot = renderPlot({
    crypto <- cryptoframe()
    
    pl <- ggplot(crypto, aes_string(x="Date", y=cryptoMetric(), color="Currency")) +
      geom_line(size=2) +
      labs(title=paste("Ceny wybranych kryptowalut w ostatnich",as.numeric(substr(input$weeks, 1, 1)) * 7,"dniach"),
           x = "Dzień",
           y = "Cena jednostkowa w dolarach") +
      theme(axis.text=element_text(size=12),
            axis.title=element_text(size=14),
            title = element_text(size=18),
            legend.text=element_text(size=12)) +
      scale_y_continuous(limits = cryptoMinMax()) +
      guides(color=guide_legend(title="Waluta"))
    if (input$trendLine) {
      pl <- pl + geom_smooth(se=FALSE, method="lm", size=1, linetype=4)
    }
    pl
  })
  
  output$currencyPlotly = renderPlotly({
    crypto <- cryptoframe()
    
    if (nrow(crypto) == 0) {
      return(plot_ly())
    }
    
    pl <- ggplot(crypto, aes_string(x="Date", y=cryptoMetric(), color="Currency")) +
      geom_line(size=2) +
      labs(title=paste("Ceny wybranych kryptowalut w ostatnich",as.numeric(substr(input$weeks, 1, 1)) * 7,"dniach"),
           x = "Dzień",
           y = "Cena jednostkowa w dolarach") +
      theme(plot.margin = unit(c(1,1,1,1), "cm")) +
      theme(legend.position="right") +
      scale_y_continuous(limits = cryptoMinMax()) +
      guides(color=guide_legend(title="Waluta"))
    if (input$trendLine) {
      pl <- pl + geom_smooth(se=FALSE, method="lm", size=1, linetype=4)
    }
    ggplotly(pl, tooltip=c("color", "y"))
    
    
  })
  
  output$details = renderDataTable({
    cryptoframe()
  })
})