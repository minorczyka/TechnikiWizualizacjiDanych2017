#
# This is the server logic of a Shiny web application. You can run the 
# application by clicking 'Run App' above.
#
# Find out more about building applications with Shiny here:
# 
#    http://shiny.rstudio.com/
#

library(shiny)
library(reshape2)
library(ggplot2)
library(dplyr)

# Define server logic required to draw a histogram
shinyServer(function(input, output) {
  device <- reactive({
    melt(read.csv("device.csv"),
         "urzadzenie", encoding="UTF-8")
  })
  
  intTele <- reactive({
    read.csv("internet_television.csv")
  })
  
  output$info <- renderUI({
    paste("Dane pochodzą ze strony http://www.wirtualnemedia.pl/artykul/gdzie-polacy-ogladaja-tresci-wideo-na-czele-youtube-cda-pl-ipla",
      "Na wykresie dotyczącym równoczesnego korzystania z telewizji i internetu błędnie została narysowana linia oznaczająca średnią - postanowiłem więc ją poprawić.",
      "Wykres 'urządzenia' przedstawia dane z obrazka z wykresem słupkowym obok tabeli.")
  })
   
  output$distPlot <- renderPlot({
    showAverages <- FALSE
    if(!is.null(input$showAverages))
      showAverages <- input$showAverages
    
    if(input$plotId == "urządzenia") {
      device1 <- device() %>% filter(variable == "srednia")
      device2 <- device() %>% filter(variable != "srednia")
      plt <- ggplot(mapping=aes(x=urzadzenie, y=value, label=value,
                                group=variable)) +
        geom_col(aes(fill=variable), device2,position="dodge")+
        scale_fill_discrete(labels=c("15-20", "21-29", "30-39", "40-49", "50+"),
                          name="Wiek") +
        labs(x="Urządzenie", y="% użytkowników",
             title="Urządzenia wykorzystywane do oglądania treści wideo")+
        scale_y_continuous(expand=c(0, 0), limits=c(0, 85)) +
        theme_classic()
      if(showAverages) {
        plt <- plt +
          geom_col(data=device1, fill="transparent", color="black") +
          labs(subtitle="Czarny słupek oznacza dane uśrednione dla wszystkich grup wiekowych")
      }
      if(input$showValues) {
        plt <- plt + 
          geom_text(aes(y=value-1.5), data=device2, 
                               position=position_dodge(0.9),
                               color="white")
        if(showAverages)
          plt <- plt +
            geom_text(aes(y=value-1.1), data=device1, 
                      position=position_dodge(0.9))
      }
    } else if(input$plotId == "internet+telewizja") {
      plt <- ggplot(intTele(), aes(x=age, y=users)) +
        geom_col(fill="transparent", color="black") +
        geom_hline(yintercept=58, linetype="dashed", size=1) +
        labs(x="Wiek (lat)", y="% użytkowników",
             title="Używający równocześnie internetu i telewizji") +
        scale_y_continuous(expand=c(0, 0), limits=c(0,67)) +
        theme_classic() +
        labs(subtitle="Przerywana linia oznacza średnią")
      if(input$showValues) {
        plt <- plt +
          geom_text(aes(y=users-1.2, label=users)) +
          geom_text(x=5, y=59.5, label="58")
      }
    }
    
    plt
  })
  
  output$showAverages <- renderUI({
    if(input$plotId == "urządzenia") {
      checkboxInput("showAverages", "Pokaż średnie", FALSE)
    }
  })
  
})
