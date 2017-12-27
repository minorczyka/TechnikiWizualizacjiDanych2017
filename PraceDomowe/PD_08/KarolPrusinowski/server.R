library(shiny)
library(jsonlite)
library(ggplot2)
library(plotly)
library(scales)
library(dplyr)
library("ggthemes")

parts <- read.csv("pc_parts.csv", stringsAsFactors = FALSE)

getUrl <- function (part) {
  paste0("https://pricespy.co.uk/ajax/server.php?class=Graph_Product&method=price_history&skip_login=1&product_id=",
         part$Id)
}

createLink <- function(val) {
  sprintf('<a href="%s">%s</a>',val, val)
}

getData <- function(part) {
  url <- getUrl(part)
  data <- fromJSON(url)$items[[1]]
  data$time <- as.Date(as.POSIXct(data$time, origin="1970-01-01")) 
  fullData <- data.frame(time = seq(data$time[1], Sys.Date(), by="day"))
  fullData$value <- rep(NA, nrow(fullData))
  fullData$type <- rep(paste0(part$Type, ": ", part$Part), nrow(fullData))
  fullData$value[fullData$time %in% data$time] <- data$value
  
  for(i in 1:nrow(fullData)) {
    if(is.na(fullData$value[i])) {
      fullData$value[i] <- fullData$value[i-1]
    }
  }
  
  fullData[fullData$time >= "2017-01-01",]
}



shinyServer(function(input, output) {
  
  selectedGpu <- reactive({
    parts[parts$Part == input$gpu,]
  })
  
  selectedGpuData <- reactive({
    getData(selectedGpu())
  })
  
  selectedCpu <- reactive({
    parts[parts$Part == input$cpu,]
  })
  
  selectedCpuData <- reactive({
    getData(selectedCpu())
  })
  
  selectedRam <- reactive({
    parts[parts$Part == input$ram,]
  })
  
  selectedRamData <- reactive({
    getData(selectedRam())
  })
  
  selectedStorage <- reactive({
    parts[parts$Part == input$storage,]
  })
  
  selectedStorageData <- reactive({
    getData(selectedStorage())
  })
  
  output$partPlot <- renderPlotly({
    gpu <- selectedGpuData()
    cpu <- selectedCpuData()
    ram <- selectedRamData()
    storage <- selectedStorageData();
    data <- rbind(rbind(rbind(cpu, gpu), ram), storage)
    colnames(data) <- c("Data", "Cena", "Nazwa")
    
    if(input$sum) {
      group <- as.data.frame(data %>% group_by(Data) %>% filter(n()==4) %>% summarise(Cena = sum(Cena), Nazwa="Suma"))
      data <- rbind(data, group)
    }
    
    g <- ggplot(data, aes(x=Data, y= Cena, col=Nazwa)) +
      geom_line() +
      scale_x_date(date_breaks = "1 month", 
                   labels=date_format("%b %y")) +
      scale_y_continuous(labels = scales::dollar_format("£")) + 
      ggtitle("Jak zmieniała się cena sprzętu?") +
      labs(x = "", y = "", colour = "") +
      scale_colour_hc() +
      theme_minimal() 
    
    ggplotly(g)
  })
  
  output$summary <- renderUI({
    cpu <- tail(selectedCpuData(), 1)
    gpu <- tail(selectedGpuData(), 1)
    ram <- tail(selectedRamData(), 1)
    storage <- tail(selectedStorageData(), 1)
    div(
      h3("Wybrany sprzęt"),
      h4("Procesor"),
      p(input$cpu, ": ", strong(paste0("£", cpu$value))),
      h4("Karta graficzna"),
      p(input$gpu, ": ", strong(paste0("£", gpu$value))),
      h4("RAM"),
      p(input$ram, ": ", strong(paste0("£", ram$value))),
      h4("Pamięć"),
      p(input$storage, ": ", strong(paste0("£", storage$value))),
      h3("Suma: ", paste0("£", sum(c(cpu$value, gpu$value, ram$value, storage$value))))
    )
    
  })
  
  output$source <- renderDataTable({
    data.frame(Nazwa = parts[,1],
               Dane = createLink(getUrl(parts)), 
               Wykres = createLink(paste0("https://pricespy.co.uk/product.php?pu=", parts$Id)))
  }, escape = FALSE,   options = list(
    pageLength = 10,
    lengthMenu = c(5, 10, 15, 20, 25)
  ))

})
