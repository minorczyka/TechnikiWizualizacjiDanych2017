

# library(ggplot2)
# library(plotly)
# library(shiny)
# library(dplyr)
#devtools::install_github('hadley/ggplot2')




shinyServer(function(input, output, session) {
  
  danebinsFiltr <- reactive({
    danebins %>%
      filter(breaki %in% unlist(select(filter(danelong.filtr, postac %in% input$postaci), breaki)))
  })
  
  
  output$trend <- renderPlotly({
    
    p <- ggplot() +
      geom_point(data = filter(danelong.filtr, postac %in% input$postaci),
                               aes(x = breaki, y = udzial, color = postac,
                                   text = paste(scena, opis)), size = 2) +
      xlab("nr sceny") + ylab("udział postaci w scenie")      
      # scale_x_continuous(breaks = unique(danelong$breaki), labels = labele)
    
    if (input$geomline){

      p <- ggplot() +
            geom_line(data = filter(danelong, postac %in% input$postaci),
                        aes(x = breaki, y = udzial, color = postac)) +
            geom_point(data = filter(danelong.filtr, postac %in% input$postaci),
                       aes(x = breaki, y = udzial, color = postac,
                          #text = paste(emocje, "olaola\nhiphip"))) +
                          text = paste(scena, opis)), size = 2) +
            xlab("nr sceny") + ylab("udział postaci w scenie")
    }
    
    if ((input$geomtlo) & (input$geomline)){
      
      danebinsf <- danebinsFiltr()
      
      p <- ggplot() +
            # geom_col(data = danebins, aes(x=breaki, y=1, fill=emocje), alpha = 0.3, 
            #          width = 1, show.legend = FALSE) +
            geom_line(data = filter(danelong, postac %in% input$postaci),
                  aes(x = breaki, y = udzial, color = postac)) +
            geom_col(data = danebinsf, aes(x=breaki, y=1, fill=emocje), alpha = 0.3,
                   width = 1, show.legend = FALSE) +
            geom_point(data = filter(danelong.filtr, postac %in% input$postaci),
                   aes(x = breaki, y = udzial, color = postac,
                       text = paste(scena, opis)), size = 2) +
            xlab("nr sceny") + ylab("udział postaci w scenie")

    }
    
    if ((input$geomtlo) & !(input$geomline)){
      
      danebinsf <- danebinsFiltr()
      
      p <- ggplot() +
            geom_col(data = danebinsf, aes(x=breaki, y=1, fill=emocje), alpha = 0.3, 
                     width = 1, show.legend = FALSE) +
            geom_point(data = filter(danelong.filtr, postac %in% input$postaci),
                       aes(x = breaki, y = udzial, color = postac,
                           text = paste(scena, opis)), size = 2) +
            xlab("nr sceny") + ylab("udział postaci w scenie")
        
    }
    
    
    
    gp <- ggplotly(p, tooltip = c("text"))
    
    gp$x$layout$xaxis$tickvals <- breaki
    gp$x$layout$xaxis$ticktext <- labele
    gp$x$layout$xaxis$range <- c(-0.05, 23.05)
    
    gp$x$layout$yaxis$range <- c(-0.029, 1.049)
    gp$x$layout$yaxis$tickvals <- c(0, 0.25, 0.5, 0.75, 1)
    gp$x$layout$yaxis$ticktext <- c("0.00", "0.25", "0.50", "0.75", "1.00")
    
    #gp$x$data[[1]]$marker$color <-c("rgba(248,118,109,1)")

    #kolors <- c("rgba(248,118,109,1)", "rgba(124,174,0,1)", "rgba(0,191,196,1)", "rgba(199,124,255,1)")
    kolors <- c("rgba(248,118,109,1)", "rgba(124,174,0,1)", "rgba(0,191,196,1)", "rgba(199,124,255,1)")
    
    for (j in 1:length(gp$x$data)){
      #gp$x$data[[j]]$marker$color <- kolors[j]
      if (gp$x$data[[j]]$name == 'jack'){
          if (gp$x$data[[j]]$mode == 'markers'){
            gp$x$data[[j]]$marker$color <- kolors[1]
            gp$x$data[[j]]$marker$line$color <- kolors[1]
          } else if (gp$x$data[[j]]$mode == 'lines') {
            gp$x$data[[j]]$line$color <- kolors[1]
          }
      } else if (gp$x$data[[j]]$name == 'marla'){
        if (gp$x$data[[j]]$mode == 'markers'){
          gp$x$data[[j]]$marker$color <- kolors[2]
          gp$x$data[[j]]$marker$line$color <- kolors[2]
        } else if (gp$x$data[[j]]$mode == 'lines') {
          gp$x$data[[j]]$line$color <- kolors[2]
        }
      } else if (gp$x$data[[j]]$name == 'tyler'){
        if (gp$x$data[[j]]$mode == 'markers'){
          gp$x$data[[j]]$marker$color <- kolors[3]
          gp$x$data[[j]]$marker$line$color <- kolors[3]
        } else if (gp$x$data[[j]]$mode == 'lines') {
          gp$x$data[[j]]$line$color <- kolors[3]
        }
      } else if (gp$x$data[[j]]$name == 'other'){
        if (gp$x$data[[j]]$mode == 'markers'){
          gp$x$data[[j]]$marker$color <- kolors[4]
          gp$x$data[[j]]$marker$line$color <- kolors[4]
        } else if (gp$x$data[[j]]$mode == 'lines') {
          gp$x$data[[j]]$line$color <- kolors[4]
        }
      }    
    }
    
    

    
    gp
    
  }) # koniec renderPlotly
  
  #-----------------------------------#
  
  output$numer <- renderText({
    
    if (input$num %in% labele){
    #HTML(paste("<h3>INT. TRALALA</h3>", "<b>JACK</b><br>", tek, sep = "<br>"))
    HTML(paste0(danesceny$all_data[danesceny$scena==input$num], 
                collapse = "<br>"))
    } else {
      HTML(paste0("<h3>Wybrałeś nieistniejącą scenę</h3>"))
    }
    
  })
  
}) # koniec shinyServer
