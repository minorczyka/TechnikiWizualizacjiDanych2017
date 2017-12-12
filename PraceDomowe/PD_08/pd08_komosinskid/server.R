library(PogromcyDanych)
library(ggplot2)

shinyServer(function(input, output, session) {

  db <- read.csv2("dane_pd08.csv")
  
  ############ wyk1
  output$wyk1 = renderPlot({
    
    if (input$sortowanie=="alfabetycznie") {
      db <- db[order(db$lokalna_grupa_dzialania, decreasing = FALSE), ]
    }
    
    if (input$sortowanie=="rosnaco") {
      db <- db[order(db$liczba_naborow, decreasing = FALSE), ]
    }
    
    if (input$sortowanie=="malejaco") {
      db <- db[order(db$liczba_naborow, decreasing = TRUE), ]
    }
    
    positions <- db$lokalna_grupa_dzialania
    
    pl <- ggplot(db, aes(x=lokalna_grupa_dzialania, y=liczba_naborow)) +
      geom_bar(stat="identity", fill="red") +
      theme(axis.text.x = element_text(angle = 90, hjust = 1)) +
      scale_x_discrete(limits = positions)
    
    if (input$wysokoscSlupka) {
      pl <- pl + geom_text(aes(y=liczba_naborow-0.5, label=liczba_naborow))
    }
    
    pl
  })
  
  ################## wyk2
  output$wyk2 = renderPlot({
    db$ilosc_srodkow <-  round(db$ilosc_srodkow/10^6,2)
    
    if (input$sortowanie=="alfabetycznie") {
      db <- db[order(db$lokalna_grupa_dzialania, decreasing = FALSE), ]
    }
    
    if (input$sortowanie=="rosnaco") {
      db <- db[order(db$ilosc_srodkow, decreasing = FALSE), ]
    }
    
    if (input$sortowanie=="malejaco") {
      db <- db[order(db$ilosc_srodkow, decreasing = TRUE), ]
    }
    
    positions <- db$lokalna_grupa_dzialania
    
    
    
    pl <- ggplot(db, aes(x=lokalna_grupa_dzialania, y=ilosc_srodkow)) +
      geom_bar(stat="identity", fill="green") +
      theme(axis.text.x = element_text(angle = 90, hjust = 1)) +
      scale_x_discrete(limits = positions) +
      ylab("ilosc srodkow [mln PLN]")
    
    if (input$wysokoscSlupka) {
      pl <- pl + geom_text(aes(y=ilosc_srodkow-0.3, label=ilosc_srodkow))
    }
    
    pl
  })
  
  
  ############## wyk3
  output$wyk3 = renderPlot({
    if (input$sortowanie=="alfabetycznie") {
      db <- db[order(db$lokalna_grupa_dzialania, decreasing = FALSE), ]
    }
    
    if (input$sortowanie=="rosnaco") {
      db <- db[order(db$wykorzystanie_budzetu, decreasing = FALSE), ]
    }
    
    if (input$sortowanie=="malejaco") {
      db <- db[order(db$wykorzystanie_budzetu, decreasing = TRUE), ]
    }
    
    positions <- db$lokalna_grupa_dzialania
    
    pl <- ggplot(db, aes(x=lokalna_grupa_dzialania, y=wykorzystanie_budzetu)) +
      geom_bar(stat="identity", fill="blue") +
      theme(axis.text.x = element_text(angle = 90, hjust = 1)) +
      scale_x_discrete(limits = positions) +
      ylab("wykorzystanie budzetu [%]")
    
    if (input$wysokoscSlupka) {
      pl <- pl + geom_text(aes(y=wykorzystanie_budzetu-3, label=wykorzystanie_budzetu))
    }
    
    pl
  })
  
  
  ############# tab
  output$tab = renderPrint({
    db
  })
})