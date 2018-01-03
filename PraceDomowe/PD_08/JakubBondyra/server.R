library (ggplot2)
library(shiny)
library(plotly)
library(ggthemes)

load("data.rda")

shinyServer(function(input, output) {
  default_countries = "Poland"
  output$df = renderDataTable(datar())
  
  datar = reactive(
    {
      countries=  input$country
      if (length(countries)==0){
        countries=default_countries
      }
      data[which(data$country %in% countries),]
    }
  )
  output$dairyPlot = renderPlotly({
    df = datar()
  ggplotly(ggplot(data=df)+geom_line(aes(x=year,y=value, col=country))+
             scale_x_continuous(expand=c(0,0))+scale_y_continuous(expand=c(0,0))+expand_limits(y=0)+
             facet_wrap("type",scales="free")+ggtitle("Production of specified products (MT)")
           + guides(col=guide_legend(title="Countries")) + theme_bw()+
             theme(panel.spacing.y= unit(10,"points"),
                   plot.margin = unit(c(20,20,20,20),"points"), strip.text = element_text(size=9),
                   axis.title.x=element_text(size=1),
                   axis.title.y=element_text(size=1)))
  }
  )
})
