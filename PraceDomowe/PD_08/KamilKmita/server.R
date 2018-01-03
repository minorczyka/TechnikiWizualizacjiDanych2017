options(shinyapps.locale='pl_PL')

dane <- readRDS("dane.RDS")


library(ggplot2)
library(plotly)
library(shiny)


shinyServer(function(input, output, session) {
  

  wybraniPilkarze <- reactive({
    dane %>% filter(pozycja %in% input$wybraneformacje) %>% select(pilkarz) %>% unique()
  })
  
  output$listaPilkarzy <- renderUI({
    pilkarze <- wybraniPilkarze()
    
    checkboxGroupInput(inputId = "wybranipilkarze",
                       label = "Ktorych pilkarzy pokazac?",
                       choices = as.character(pilkarze$pilkarz),
                       selected = as.character(pilkarze$pilkarz))
  })
  
  
  output$trend = renderPlotly({
    
    danef <- dane %>% filter(id_mecz >= input$range[1] & id_mecz <= input$range[2]) %>%
      filter(pozycja %in% input$wybraneformacje) %>% filter(pilkarz %in% input$wybranipilkarze)
    
    p <- ggplot() +
      geom_point(position = position_jitterdodge(dodge.width=0.4, jitter.width = 0.3),
                 size = 4, data = danef, colour = "black", shape= 21,
                 aes(x = id_mecz, y = ocena, group = pozycja, fill = pozycja, text = pilkarz)) +
      scale_y_continuous(limits = c(0,10), breaks = c(0,1,2,3,4,5,6,7,8,9,10)) +
      scale_x_continuous(limits = c((input$range[1]-0.5),(input$range[2]+0.5)),
                         breaks = seq(input$range[1],input$range[2],1)) +
      xlab("kolejka")
    
    ggplotly(p,  tooltip = c("text", "ocena"))
 
  })
  
  output$napis = renderPrint({
    cat('Wizualizacja dotyczy ocen wystawianych piłkarzom Legii w poszczególnych
kolejkach Ekstraklasy przez `Weszło!`, jeden z najpopularniejszych \nserwisów internetowych dot. 
        polskiej piłki nożnej\n
        Ponieważ `Weszło!` nie udostępnia żadnej bazy danych, informacje dot. \noceny poszczególnych zawodników
        musiano pozyskać przy pomocy web-scrapingu.\n
        Funkcjonalność wizualizacji pozwala zarówno na analizowanie formy \nposzczególnego zawodnika w
        rundzie jesiennej sezonu 2017/2018, \njak i na porównywanie całych formacji.\n
        Kody tworzące odpowiednie tabele dostępne są na stronie:\nhttps://github.com/kkmita/wizualizacje/PD_08')
  })
})
