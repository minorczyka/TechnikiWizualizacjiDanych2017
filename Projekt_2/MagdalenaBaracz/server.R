library(ggplot2)
library(extrafont)
library(dplyr)
library(stringr)
library(ggthemes)
#font_import(pattern = "AVENGEANCE")
script_combined <- read.csv("script_combined.csv", h = T)


shinyServer(function(input, output) {
  
  output$quote <- renderText({ 
    input$refreshButton
    if (input$character == "ALL") {
      text <- script_combined %>%
        select(scene, script, person)
    } else {
      text <- script_combined %>%
        select(scene, script, person) %>%
        filter(person==input$character)
    }
    rand <- sample(1:nrow(text), 1)
    str <- str_trim(str_extract_all(text[rand,]$script, "([A-Z][^.]*)")[[1]])
    while(length(str) == 0 || str_count(str, "\\b[A-Z]{2,}\\b")!=0 || !grepl("\\b[.?!*_]\\b", str))
    {
      rand <- sample(1:nrow(text), 1)
      str <- str_trim(str_extract_all(text[rand,]$script, "([A-Z][^.]*)")[[1]])
    }
    paste('<br/><br/>',text[rand,]$person, " : ",'<br/>',"\"", str,"\"")
  })
  
  output$avngImage <- renderImage({
    img <- switch(input$character,
                  "ALL" = "avengers.png",
                  "TONY/IRON MAN" = "iron_man.png", 
                  "THOR" = "thor.png", 
                  "STEVE/CAPTAIN AMERICA" = "captain_america.png", 
                  "NICK FURY" = "nick_fury.png", 
                  "NATASHA/BLACK WIDOW" = "black_widow.png", 
                  "LOKI" = "loki.png",
                  "CLINT BARTON/HAWKEYE" = "hawkeye.png",
                  "BANNER/HULK" = "hulk.png")
    
    filename <- normalizePath(file.path('./img',
                                        paste(img)))
    
    # Return a list containing the filename and alt text
    list(src = filename,
         alt = "Error",
         width = 150,
         height = 200)
    
  }, deleteFile = FALSE)
  
  output$avngPlot <- reactivePlot(function() {
    
    if (input$character == "ALL") {
      aPlot <- script_combined %>%
        select(scene, person, hero, daytime, place, emo) %>%
        unique() %>%
        ggplot() +
        labs(y = "Character", x = "Scene") +
        switch(input$fill,
               "emo" = geom_tile(aes(scene, person, fill = emo, text = place, height = 0.6, width = 1.5)),
               "daytime" = geom_tile(aes(scene, person, fill = daytime, text = place, height = 0.6, width = 1.5)),
               "hero" = geom_tile(aes(scene, person, fill = hero, text = place, height = 0.6, width = 1.5)))
      
      aPlot <- aPlot + switch(input$fill,
                      "emo" = scale_fill_manual("Emotions", values=c("anger"="#fc0101","anticipation"="#ff8300","disgust"="#a00055","fear"="#9200a0","joy"="#41f4e5","negative"="#000000","neutral"="#7fceff","positive"="#41f4a0","sadness"="#828187","trust"="#4286f4","surprise"="#cbf27d")),
                      "daytime" = scale_fill_manual("Daytime", values=c("DAY"="#f4f142","LATER"="#41a3f4","MORNING"="#f4bb41","NIGHT"="#346e9e","SKY"="#a9d1f2","SPACE"="#070b0f")),
                      "hero" = scale_fill_manual("Character type",values=c("hero"="#ad1d28","alter ego"="#029cfc")))+
        theme_hc() + 
        scale_colour_hc() +
        theme(legend.title = element_text(colour="#ad1d28", size=10, face="bold")) + 
        theme(legend.position="right") +
        scale_x_continuous(breaks = round(seq(0, max(script_combined$scene), by = 10),1))
      
      print(aPlot)
    } else {
      aPlot <- script_combined %>%
        select(scene, person, hero, daytime, place, emo) %>%
        filter(person==input$character) %>%
        unique() %>%
        ggplot() +
        labs(y = "Character", x = "Scene") +
        switch(input$fill,
               "emo" = geom_tile(aes(scene, person, fill = emo, text = place, height = 0.25, width = 2)),
               "daytime" = geom_tile(aes(scene, person, fill = daytime, text = place, height = 0.25, width = 2)),
               "hero" = geom_tile(aes(scene, person, fill = hero, text = place, height = 0.25, width = 2)))
      
      aPlot <- aPlot + switch(input$fill,
                      "emo" = scale_fill_manual("Emotions", values=c("anger"="#fc0101","anticipation"="#ff8300","disgust"="#a00055","fear"="#9200a0","joy"="#41f4e5","negative"="#000000","neutral"="#7fceff","positive"="#41f4a0","sadness"="#828187","trust"="#4286f4", "surprise"="#cbf27d")),
                      "daytime" = scale_fill_manual("Daytime", values=c("DAY"="#f4f142","LATER"="#41a3f4","MORNING"="#f4bb41","NIGHT"="#346e9e","SKY"="#a9d1f2","SPACE"="#070b0f")),
                      "hero" = scale_fill_manual("Character type",values=c("hero"="#ad1d28","alter ego"="#029cfc"))) +
        theme_hc() + 
        scale_colour_hc() +
        theme(legend.title = element_text(colour="#ad1d28", size=10, face="bold")) + 
        theme(legend.position="right")+
        scale_x_continuous(breaks = round(seq(0, max(script_combined$scene), by = 10),1))
      
      print(aPlot)
    }
  }, height = 400, width = 1150 )
})