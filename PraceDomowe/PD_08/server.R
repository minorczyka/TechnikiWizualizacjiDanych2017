source("data.R")
library(shiny)
library(ggplot2)

function(input, output) {
  data <- getData()
  colors <- c("#efcdb8","#efcdb8", "#c72f2e", "#a4142b", "#800027", "#6f0433", "#810038", "#78191f", "#883333", "#712b2b")
  cities <- data[, 1]
  
  output$temperaturePlot <- renderPlot({

    colors_cities <- colors[order(data[,input$month])]
    temperatures <- as.data.frame(data[,input$month])
    temperatures <- setNames(temperatures, c("temperatures"))
    data2 <- cbind(temperatures, cities)
      
      ggplot(data2, aes(x=cities, y=temperatures, fill=temperatures)) + geom_bar(stat = "identity") + 
        labs(x="City", y="Temperature in degrees") + 
        geom_text(aes(x=cities, y=temperatures+0.7, 
                     label=temperatures), size=4, colour="black") +
        theme(legend.position="none") +
        scale_fill_gradient2(low='blue', high='red', space='Lab')
      })
}