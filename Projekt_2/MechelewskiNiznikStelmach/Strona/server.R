library(tidyr)
library(plotly)
library(ggthemes)

load(file = "sentiment.rda")

shinyServer(function(input, output, session) {
  dataToPlot <- function(){
    reorder()
    # onlySelectedScenes()
    onlySelectedPeople()
  }

  onlySelectedScenes <- reactive({
    onlySelectedParts() %>%
      filter(between(scene, min(input$scenesRanger), max(input$scenesRanger)))
  })

  onlySelectedPeople <- reactive({
    selectedPeople <- c(input$selectedPeople1, input$selectedPeople2)
    # onlySelectedParts() %>%
    reorder() %>%
      filter(person %in% selectedPeople)
  })

  onlySelectedParts <- reactive({
    parts <- c(1, 2)
    if(input$sidebarmenu == "season1") {
      parts <- 1
    }
    if(input$sidebarmenu == "season2") {
      parts <- 2
    }

    sentiment %>%
      filter(part %in% parts)
  })

  reorder <- reactive({
    aggr_fun <- match.fun(input$scenesAggregation)
    
    curr_data <- onlySelectedScenes()
    ppl_order <- curr_data %>%
      group_by(person) %>%
      summarise(aggr = aggr_fun(sentiment))
    
    if (input$sortingDirection == "asc") {
      ppl_order <- ppl_order %>%
        arrange(aggr)
    } else {
      ppl_order <- ppl_order %>%
        arrange(desc(aggr))
    }
      
    top <- ppl_order[1:20,]

    updateSelectInput(session = session, inputId = "selectedPeople1", selected = top$person)
    updateSelectInput(session = session, inputId = "selectedPeople2", selected = top$person)
    curr_data %>%
      mutate(person = factor(person, rev(ppl_order$person)))
  })

  output$trend = renderPlotly({
    data <- dataToPlot()
    data$sentiment <- round(data$sentiment/10, digits = 2)
    p <- ggplot(data, aes(x=scene, y=person, z=sentiment, text = paste("sentiment:", data$sentiment))) +
      stat_summary_2d(binwidth=c(input$scenesFrequency,1)) +
      scale_fill_gradient2(low = "red", mid = "white", high = "green", guide = FALSE) +
      xlab("scena") +
      ylab("") +
      theme_few() +
      theme(axis.text.y = element_text(size = 8, hjust = 1))
    ggplotly(p, dynamicTicks = TRUE,  tooltip = c("scene", "person", "sentiment"))
  })

  output$personNumberBox <- renderValueBox(
    {
      data <- dataToPlot()
      people <- unique(data$person)
      valueBox(paste(length(people)), "Liczba postaci", icon = icon("group"))
    }
  )

  output$maxPositiveValue <- renderValueBox(
    {
      data <- dataToPlot()
      maxValue <- round(max((data$sentiment))/10, digits = 2)
      valueBox(paste(maxValue), "Max wartość pozytywna", icon = icon("thumbs-up"), color = "green")
    }
  )

  output$maxNegativeValue <- renderValueBox(
    {
      data <- dataToPlot()
      minValue <- round(min((data$sentiment))/10, digits = 2)
      valueBox(paste(minValue), "Max wartość negatywna", icon = icon("thumbs-down"), color = "red")
    }
  )
})
