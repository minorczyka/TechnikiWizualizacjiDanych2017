library(ggplot2)
library(stringr)
library(plotly)
library(png)
library(grid)
library(tidytext)
library(janeaustenr)
library(dplyr)
library(ggthemes)

scenes <- read.csv(file = "./data/pulp_fiction_scenes.txt", sep="$", encoding = 'UTF-8')
scenes$ActualNumber <- scenes$ActualNumber - 1
scenes$Duration <- scenes$End-scenes$Start
scenes <- scenes %>% arrange(ActualNumber)
scenes$ActualEnd <- cumsum(scenes$Duration) + cumsum(rep(1,5))
scenes$ActualStart <- scenes$ActualEnd - scenes$Duration
scenes$Difference <- scenes$ActualStart - scenes$Start 


get_scene_index <- function(line_index) {
  sapply(line_index, function(l) {
    (scenes %>% filter(l >= Start & l <= End) %>% select(ActualNumber))[1,1]
  })
}

loadData <- function() {
  
  df <- read.csv(file = "./data/pulp_fiction_df.txt", sep="$", encoding = 'UTF-8')
  df$Sentence <- as.character(df$Sentence)
  
  trimmed_name <- sapply(df, function(x) { 
    matching <- str_match(df[x,"Character"], "(.*?) \\(O\\.S\\.\\)") 
    return(matching)
    if(is.na(matching[,1]) ) {
      return(df[x,"Character"])
    } else {
      return(matching[,2])
    }
    
  })[[1]][,2]
  
  df$TrimmedCharacter <- ifelse(is.na(trimmed_name), as.character(df$Character), trimmed_name)
  df$TrimmedCharacter[df$TrimmedCharacter == "YOUNG MAN"] <- "PUMPKIN"
  df$TrimmedCharacter[df$TrimmedCharacter == "YOUNG WOMAN"] <- "HONEY BUNNY"
  
  df <- df %>%
    mutate(linenumber = row_number())
  
  df$scene_index <- get_scene_index(df$linenumber)
  
  df
}


fuck_aggregate <- read.table(file = "f_aggregate.csv")


fuck_ordered <- fuck_aggregate[order(fuck_aggregate$x, decreasing = TRUE),]
fuck_ordered$num <- 1:nrow(fuck_ordered)
fuck_ordered$Character <- as.factor(fuck_ordered$Character)
fuck_ordered$Character <- factor(fuck_ordered$Character,levels(fuck_ordered$Character)[order(fuck_aggregate$x, decreasing = TRUE)])


shinyServer(function(input, output, session) {
  
  
  load_skull <- reactive({
    rasterGrob(readPNG("./images/skull.png"), interpolate=TRUE)
  })
  
  load_lips <- reactive({
    rasterGrob(readPNG("./images/lips.png"), interpolate=TRUE)
  })
  
  load_syringe <- reactive ({
    rasterGrob(readPNG("./images/syringe.png"), interpolate=TRUE)
  })
  
  load_dance <- reactive({
    rasterGrob(readPNG("./images/dance.png"), interpolate=TRUE)
  })
  
  
  sentiment_plot <- reactive ({
    chronology <- input$chronology
      
    #pulp_sentences <- df %>% ungroup() %>%
    #  unnest_tokens(word, Sentence)

    
    #pulp_sentiment <- pulp_sentences %>% inner_join(get_sentiments("afinn"), by = "word") %>% 
    #  group_by(index = linenumber %/% 10) %>% 
    #  summarise(sentiment = mean(score), scene_index = round(mean(scene_index))) %>% 
    #  mutate(method = "AFINN")
    # instead of above code we load precomputed values from file
    pulp_sentiment <- read.table(file ="sentiment.csv", header = TRUE)
    pulp_sentiment$scene_index[6] <- 3 #fir for weird scene_index
    
    local_scenes <- scenes
    
    if(chronology) {
      local_scenes$End <- local_scenes$ActualEnd
      local_scenes$Start <- local_scenes$ActualStart
      
      pulp_sentiment$real_index <- floor(pulp_sentiment$index + scenes$Difference[pulp_sentiment$scene_index]/10)
      pulp_sentiment <- pulp_sentiment %>% arrange(real_index) %>% mutate(real_index=row_number()-1)
      #pulp_sentiment <- pulp_sentiment %>% arrange(scene_index, index) %>% mutate(real_index=row_number())
    } else {
      pulp_sentiment <- pulp_sentiment %>% mutate(real_index=index)
    }

    scene_starts <- local_scenes$Start/10 +0.5
    scene_ends <- local_scenes$End/10 + 0.5

    colors <- c("#fbb4ae", "#fbb4ae", "#b3cde3", "#ccebc5", "#fed9a6")
    ymin = -4
    ymax = 3.5
    g <- ggplot() +
      annotate("rect", xmin=scene_starts, xmax=scene_ends, ymin=c(ymin) , ymax=c(ymax), alpha=0.3, 
               color=colors[local_scenes$ActualNumber], 
               fill=colors[local_scenes$ActualNumber])+
      geom_col(data = pulp_sentiment, aes(real_index, sentiment, fill = sentiment), show.legend = FALSE) + 
      scale_x_continuous(limits = c(0,119.5), expand = c(0, 0), breaks=local_scenes$Start/10 + (local_scenes$End - local_scenes$Start)/20,
                         labels=local_scenes$Scene) +
      scale_y_continuous(limits = c(ymin, ymax), expand = c(0, 0)) +
      scale_fill_gradient(low = "#d7191c", high = "#1a9641") +
      ggtitle("Pulp Fiction sentiment timeline") +
      labs(x = "time") +theme(title= element_text(size=18,face="bold"),
                              axis.text=element_text(size=12,face="bold"),
                              axis.title=element_text(size=12))
    
    g
  })
  
  output$sentiment = renderPlot({
    print("generating sentiment base plot")
    g<- sentiment_plot()
    print("generated")
    if(input$scenes) {
      bad_image_y = -2.8
      images_data <- data.frame(
        type=c("skull", "skull", "dance", "syringe", "lips", "skull", "skull", "skull", "skull", "skull", "skull"),
        linenumber=c(198,223,343,433, 635, 804,806,847,852,855,885),
        height=c(bad_image_y , bad_image_y , 2.5,  bad_image_y, 2.5, bad_image_y  + 0.15, bad_image_y- 0.15, 
                 bad_image_y + 0.3, bad_image_y , bad_image_y - 0.3, bad_image_y  )
      )
      
      if(input$chronology) {
        images_data$scene_index <-  get_scene_index(images_data$linenumber)
        images_data$linenumber <- images_data$linenumber + scenes$Difference[images_data$scene_index]+10
      }
      print("Loading images")
      image_width <- 1.5
      skull <- load_skull()
      syringe <- load_syringe()
      dance <- load_dance()
      lips <- load_lips()
      print("Adding images")
      for(i in 1:nrow(images_data)) {
        row <- images_data[i,]
        
        if(as.character(row$type) == 'skull')
          object <- skull
        if(as.character(row$type) == 'dance')
          object <- dance
        if(as.character(row$type) == 'syringe')
          object <- syringe
        if(as.character(row$type) == 'lips')
          object <- lips
        
        x <- row$linenumber/10
        y <- row$height
        
        g <- g + annotation_custom(object, xmin=x-image_width, xmax=x+image_width, ymin=y, ymax=y+sign(y))
      }
    }
    print("Added images")
    
    g
    
  }, height=600)
  
  
  output$fucks = renderPlot({
  
    referenceCharacter <- input$baseBar
    
    referenceFucks <- (fuck_ordered %>% filter(Character==referenceCharacter) %>% select(x))[1,1]
    fuck_ordered$Ratio <- round(100*fuck_ordered$x/referenceFucks, 1)
    fuck_ordered$RatioText <- paste(fuck_ordered$Ratio, "%", sep = '')
    
    image_y <- 65
    y_max <- 75
    
    width = 0.5
    jules <- rasterGrob(readPNG("./images/jules.png"), interpolate=TRUE)
    vincent <- rasterGrob(readPNG("./images/vincent.png"), interpolate=TRUE)
    lance <- rasterGrob(readPNG("./images/lance.png"), interpolate=TRUE)
    pumpkin <- rasterGrob(readPNG("./images/pumpkin.png"), interpolate=TRUE)
    honeybunny <- rasterGrob(readPNG("./images/honeybunny.png"), interpolate=TRUE)
    marsellus <- rasterGrob(readPNG("./images/marsellus.png"), interpolate=TRUE)
    butch <- rasterGrob(readPNG("./images/butch.png"), interpolate=TRUE)
    jimmie <- rasterGrob(readPNG("./images/jimmie.png"), interpolate=TRUE)
    wolf <- rasterGrob(readPNG("./images/wolf.png"), interpolate=TRUE)
    ggplot(data=fuck_ordered[1:9,], aes(x=Character, y=x, fill=Character)) + 
      geom_bar(stat="identity", show.legend = FALSE) + 
      geom_text(aes(label=RatioText), vjust=-1, size=7) +
      ggtitle("The most coarse characters - number of \"fucks\" per person") + 
      annotation_custom(jules, xmin=1-width, xmax=1+width, ymin=image_y, ymax=image_y+10) +
      annotation_custom(vincent, xmin=2-width, xmax=2+width, ymin=image_y, ymax=image_y+10) +
      annotation_custom(lance, xmin=3-width, xmax=3+width, ymin=image_y, ymax=image_y+10) +
      annotation_custom(pumpkin, xmin=4-width, xmax=4+width, ymin=image_y, ymax=image_y+10) +
      annotation_custom(honeybunny, xmin=5-width, xmax=5+width, ymin=image_y, ymax=image_y+10) +
      annotation_custom(marsellus, xmin=6-width, xmax=6+width, ymin=image_y, ymax=image_y+10) +
      annotation_custom(butch, xmin=7-width, xmax=7+width, ymin=image_y, ymax=image_y+10) +
      annotation_custom(jimmie, xmin=8-width, xmax=8+width, ymin=image_y, ymax=image_y+10) +
      annotation_custom(wolf, xmin=9-width, xmax=9+width, ymin=image_y, ymax=image_y+10) +
      ylim(0, y_max)+
      labs(y = "fuck words") +
      scale_y_continuous(limits = c(0, y_max), expand = c(0, 0))+
      theme(title= element_text(size=18,face="bold"),
      axis.text=element_text(size=12,face="bold"),
      axis.title=element_text(size=12))
    
    
  }, height=600)
  
})