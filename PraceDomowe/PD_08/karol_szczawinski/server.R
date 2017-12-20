require(plotly)
library(PogromcyDanych)
library(ggplot2)
library(shinyjs)
library(shiny)

byPlayer <- as.data.frame(rbind(
  c("Argentyna","Lionel Messi",5),
  c("Portugalia","Cristiano Ronaldo",5),
  c("Holandia","Johan Cruijff",3),
  c("Francja","Michel Platini",3),
  c("Holandia","Marco van Basten",3),
  c("Hiszpania","Alfredo Di Stéfano",2),
  c("Republika Federalna Niemiec","Franz Beckenbauer",2),
  c("Anglia","Kevin Keegan",2),
  c("Republika Federalna Niemiec","Karl-Heinz Rummenigge",2),
  c("Brazylia","Ronaldo",2)))



byCountry <- as.data.frame(rbind(c("Holandia",3,7),
                                 c("Portugalia",3,7),
                                 c("Niemcy",5,7),
                                 c("Anglia",4,6),
                                 c("Francja",4,6),
                                 c("Argentyna",1,5),
                                 c("Brazylia",4,5),
                                 c("włochy",5,5),
                                 c("Hiszpania",2,3),
                                 c("ZSRR",3,3))
)

byClub <- as.data.frame(rbind(
  c("Hiszpania","Barcelona",6,11),
  c("Hiszpania","Real Madryt",5,10),
  c("włochy","Juventus",6,8),
  c("włochy","Milan",6,8),
  c("Niemcy","Bayern Monachium",3,5),
  c("Anglia","Manchester United",4,4),
  c("Ukraina","Dynamo Kijów",2,2),
  c("włochy","Inter Mediolan",2,2),
  c("Niemcy","Hamburg",1,2)
))


#byCountry <- byCountry[order(byCountry$V3, decreasing = TRUE),]
#byClub

byCountry$V1 <- factor(as.character(byCountry$V1), levels = c("Holandia", "Portugalia", "Niemcy",
                                                              "Anglia", "Francja", "Argentyna", "Brazylia", "włochy", "Hiszpania", "ZSRR"))

byPlayer$V2 <- factor(as.character(byPlayer$V2), levels = c("Lionel Messi", "Cristiano Ronaldo", "Johan Cruijff", "Michel Platini", 
                                                            "Marco van Basten", "Alfredo Di Stéfano", "Franz Beckenbauer", "Kevin Keegan", 
                                                            "Karl-Heinz Rummenigge", "Brazylia","Ronaldo"))

byClub$V2 <- factor(as.character(byClub$V2), levels = c("Barcelona", "Real Madryt", "Juventus", "Milan", "Bayern Monachium", "Manchester United",
                                                        "Dynamo Kijów", "Inter Mediolan", "Hamburg"))

byCountry$V2 <- as.integer(as.character(byCountry$V2))
byCountry$V3 <- as.integer(as.character(byCountry$V3))
byPlayer$V3 <- as.integer(as.character(byPlayer$V3))
byClub$V3 <- as.integer(as.character(byClub$V3))
byClub$V4 <- as.integer(as.character(byClub$V4))
colnames(byCountry) <- c("Kraj", "Liczba zawodników", "Liczba nagród")
colnames(byPlayer) <- c("Kraj", "Zawodnik", "Liczba nagród")
colnames(byClub) <- c("Kraj", "Klub", "Liczba zawodników","Liczba nagród")


shinyServer(function(input, output) {
  output$trend = renderPlot({
     if(is.null(input$chart) | input$chart == "Kraju"){
      data <- byCountry[1:input$sl1,]
      pl <- ggplot(data, aes(x = Kraj,y = `Liczba nagród`, fill = `Liczba zawodników`)) +
        geom_bar(stat = "identity") + labs(x = "", y = "Liczba nagród", title = "Ranking krajów")  +
        theme( plot.title = element_text(color="red", size=14, face="bold.italic",hjust = 0.5),
              axis.text.x = element_text(size = 11))
        return(pl)
     
    }
    else if(input$chart == "Zawodnika"){
      data <- byPlayer[1:input$sl1,]
      pl <- ggplot(data, aes(x = Zawodnik,y = `Liczba nagród`, fill = Kraj)) +
        geom_bar(stat = "identity") + labs(x = "Zawodnik", y = "Liczba nagród", title = "Ranking zawodników")  +
        theme( plot.title = element_text(color="red", size=14, face="bold.italic",hjust = 0.5),
              axis.text.x=element_text(angle=0, hjust=1, size = 9))
      return(pl)

    }
    data <- byClub[1:input$sl1,]
    pl <- ggplot(data, aes(x = Klub,y = `Liczba nagród`, fill = `Liczba zawodników`)) +
      geom_bar(stat = "identity") + labs(x = "Klub", y = "Liczba nagród", title = "Ranking klubów")  +
      theme( plot.title = element_text(color="red", size=14, face="bold.italic",hjust = 0.5),
                                                              axis.text.x=element_text(angle=0, hjust=1, size = 9))
    return(pl)
   
  })
  output$trend2 = renderPlotly({
    if(is.null(input$chart) | input$chart == "Kraju"){
      data <- byCountry[1:input$sl1,]
      pl <- ggplot(data, aes(x = Kraj,y = `Liczba nagród`, fill = `Liczba zawodników`)) +
        geom_bar(stat = "identity") + labs(x = "", y = "Liczba nagród", title = "Ranking krajów")  +
        theme( plot.title = element_text(color="red", size=14, face="bold.italic",hjust = 0.5),
              axis.text.x = element_text(size = 11))
      return(ggplotly(pl))
      
    }
    else if(input$chart == "Zawodnika"){
      data <- byPlayer[1:input$sl1,]
      pl <- ggplot(data, aes(x = Zawodnik,y = `Liczba nagród`, fill = Kraj)) +
        geom_bar(stat = "identity") + labs(x = "Zawodnik", y = "Liczba nagród", title = "Ranking zawodników")  +
        theme( plot.title = element_text(color="red", size=14, face="bold.italic",hjust = 0.5),
              axis.text.x=element_text(angle=0, hjust=0, size = 9))
      return(ggplotly(pl))
      
    }
    data <- byClub[1:input$sl1,]
    pl <- ggplot(data, aes(x = Klub,y = `Liczba nagród`, fill = `Liczba zawodników`)) +
      geom_bar(stat = "identity") + labs(x = "Klub", y = "Liczba nagród", title = "Ranking klubów")  +
      theme( plot.title = element_text(color="red", size=14, face="bold.italic",hjust = 0.5),
            axis.text.x=element_text(angle=0, hjust=0, size = 9))
    return(ggplotly(pl))
    
  })
})


