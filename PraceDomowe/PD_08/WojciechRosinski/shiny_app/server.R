library(shiny)
library(ggplot2)
library(dplyr)


shinyServer(function(input, output, session) {
  
  pl_energy <- read.csv('PL_energy.csv')
  
  pl_subset <- reactive({
    pl_energy[pl_energy$Zrodlo.Energii == input$Zrodla, ] %>% filter(variable > input$Rok[1] & variable < input$Rok[2])
  })
  
  output$Rok <- renderUI({ 
    selectInput("Zrodla", "Zrodla energii", as.character(pl_energy$Zrodlo.Energii) )
  })
  
  sliderValues <- reactive({
    data.frame(
      Name = c("Rok"),
      Value = as.character(c(input$Rok)),
      stringsAsFactors = FALSE)
  })
  
  output$values <- renderTable({
    sliderValues()
  })
  
  output$energy_plot = renderPlot({
    
    pl_data <- pl_subset()
    x_axis_text_size = 14
    legend_text_size = 16
    
    pl <- ggplot(pl_data, aes(x = variable, y = value)) +
      geom_point(aes(color=Zrodlo.Energii)) +
      scale_color_brewer(palette = 'Set1') +
      xlab('Rok') +
      ylab('Ilosc pozyskanej energii [%]') +
      ggtitle("Wykorzystanie zrodel energii do produkcji energii w Polsce") +
      theme(axis.title.y = element_text(size = x_axis_text_size), axis.title.x = element_text(size = x_axis_text_size), 
            axis.text.x = element_text(size = x_axis_text_size), axis.text.y = element_text(size = x_axis_text_size),
            legend.text=element_text(size=legend_text_size)) +
      theme(plot.title = element_text(size=18))
      
    pl
  }, height=600, width=1000)
  
}) 
