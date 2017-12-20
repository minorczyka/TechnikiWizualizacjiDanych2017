start_data = read.table("data/data.txt", header=TRUE, stringsAsFactors=FALSE)
countries = unique(start_data$country)
years = unique(start_data$year)

country=character()
year=numeric()
type=character()
value=numeric()

for (i in 1:nrow(start_data))
{
  for (j in 3:6)
  {
    country = c(country, start_data[i, 1])
    year = c(year, start_data[i, 2])
    type = c(type, names(start_data)[j])
    value = c(value, start_data[i, j])
  }
}
data = data.frame(country, year, type, value, stringsAsFactors=FALSE)

library(shiny)
library(ggplot2)
library(scales)
library(shinyjs)

ui <- fluidPage(
  useShinyjs(),
  titlePanel("Employment structure"),
  
  sidebarLayout(
    
    sidebarPanel(
      
    radioButtons("group_by", "Group by:",
                 c("Country", "Year")),
    
      selectInput("country", "Country:",
                  countries),
    
      selectInput("year", "Year:",
                  years),
      a(href="http://www.oecd-ilibrary.org/employment/oecd-labour-force-statistics_23083387", "Source")
    
    ),
    
    mainPanel(
      plotOutput(outputId = "distPlot")
      
    )
  )
)

server <- function(input, output) {
  observe({
    toggleElement("country", condition = (input$group_by == "Country"))
    toggleElement("year", condition = (input$group_by == "Year"))
  })
  output$distPlot <- renderPlot({
    
    if (input$group_by == "Country")
    {
      filtered_data = data[data$country == input$country, ]
      plot = ggplot(filtered_data, aes(x=year, y=value, fill=type)) +
        geom_bar(position = "fill",stat = "identity") +
        scale_y_continuous(labels = percent_format()) +
        scale_x_continuous(breaks=seq(min(filtered_data$year), max(filtered_data$year),1))
    }
    if (input$group_by == "Year")
    {
      filtered_data = data[data$year == input$year, ]
      plot = ggplot(filtered_data, aes(x=country, y=value, fill=type)) +
        geom_bar(position = "fill",stat = "identity") +
        scale_y_continuous(labels = percent_format())
    }
      return(plot)
  })
  
}

shinyApp(ui, server)