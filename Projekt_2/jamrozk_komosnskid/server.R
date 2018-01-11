library(PogromcyDanych)
library(ggplot2)
library(dplyr)
library(tidytext)
library(reshape2)
library(wordcloud)
library(ggplot2)
library(treemap)
library(stringi)
library(plotly)



shinyServer(function(input, output, session) {

  anakin <- read.csv2("anakin_sw_all.csv")
  
  anakin$quote <- as.character(anakin$quote)
  
  
  ############ 
  # 3 - CHMURA SŁOW
  output$wyk3 = renderPlot({
    
    db <- anakin[anakin$episode_nr %in% input$episode2, ]
    
    db <- db%>%
      unnest_tokens(word, quote)
    
    db <- db %>%
      anti_join(stop_words)
    

    db2 <- db[db$word!="master",]
   
    
    db3 <- db2 %>%
      inner_join(get_sentiments("bing")) %>%
      count(word, sentiment, sort = TRUE) %>%
      acast(word ~ sentiment, value.var = "n", fill = 0)
    
    db3 <- data.frame(db3)
    db3["powerful",1] <- db3["powerful", 2]
    db3["powerful", 2] <- 0
    if(is.na(db3["powerful",1])){db3["powerful",1] <-0}
    
    db3 %>% 
      dplyr::rename("light side"=positive, "dark side"=negative) %>%
      comparison.cloud(colors = c("#F8766D", "#00BFC4"),
                       max.words = 100, title.size = 2,
                       random.order = FALSE, use.r.layout=TRUE)
  })
  
  ############ 2 - EMOCJE - mozaika
  output$wyk2 = renderPlot({
    
    db <- anakin[anakin$episode_nr %in% input$episode2, ]
    
    db <- db%>%
      unnest_tokens(word, quote)
    
    db <- db %>%
      anti_join(stop_words)
    
    db2 <- db %>%
      inner_join(get_sentiments("nrc"))
    
    db3 <- db2 %>%
      group_by(sentiment) %>%
      count()
    
    db3$side <- c("dark", "light", "dark", "dark", "light", "dark", "light", "dark", "light", "light")

    db3$dbcolor<-db3$n
    db3$dbcolor[which(db3$side=="dark")]<-(-1)*db3$n[which(db3$side=="dark")]
    
    treemap(db3, index = c("side","sentiment"), vSize = "n", vColor = "dbcolor", type="value", palette="RdYlBu",mapping = c(min(db3$dbcolor), 0, max(db3$dbcolor)),title.legend="Liczba slow")
    
    
  })

    ###### 1 - PRZEWAGA MOCY 
    output$wyk1 = renderPlot({
      
      words <- anakin[anakin$episode_nr %in% input$episode2, ] %>%
        group_by(scene_nr) %>%
        unnest_tokens(word, quote)
      
      words_sentiments3 <- words %>%
        inner_join(get_sentiments("bing")) %>%
        count(scene_nr, sentiment)
      words_sentiments3$n[which(words_sentiments3$sentiment=="negative")]<-(-1)*words_sentiments3$n[which(words_sentiments3$sentiment=="negative")]
      
      #pozytywne/negatywne w całym filmie
      words_sentiments_all <- words_sentiments3 %>%
        group_by(sentiment) %>%
        count(sentiment)
      words_sentiments_all$pomocnicza<-rep("",2)
      words_sentiments_all$sentiment<-c("dark side", "light side")
      
      ggplot(words_sentiments_all, aes(x=pomocnicza, y=nn, color=sentiment, fill=sentiment))+
        geom_col(colour="black",  width = 0.3)+
        scale_fill_manual(values=c("firebrick1","deepskyblue"))+
        coord_flip()+
        labs(x="",y="liczba wyrazów")+
        theme_minimal()
    })
    
    # 4 - EMOCJE W CZASIE
    
    output$wyk4 = renderPlotly({   
      
      anakin$scene_nr_scale<-anakin$scene_nr
      anakin$scene_nr_scale[which(anakin$episode_nr==1)]<-anakin$scene_nr[which(anakin$episode_nr==1)]/(max(anakin$scene_nr[which(anakin$episode_nr==1)])+1)
      anakin$scene_nr_scale[which(anakin$episode_nr==2)]<-anakin$scene_nr[which(anakin$episode_nr==2)]/(max(anakin$scene_nr[which(anakin$episode_nr==2)])+1)
      anakin$scene_nr_scale[which(anakin$episode_nr==3)]<-anakin$scene_nr[which(anakin$episode_nr==3)]/(max(anakin$scene_nr[which(anakin$episode_nr==3)])+1)
      anakin$scene_nr_scale[which(anakin$episode_nr==4)]<-anakin$scene_nr[which(anakin$episode_nr==4)]/(max(anakin$scene_nr[which(anakin$episode_nr==4)])+1)
      anakin$scene_nr_scale[which(anakin$episode_nr==5)]<-anakin$scene_nr[which(anakin$episode_nr==5)]/(max(anakin$scene_nr[which(anakin$episode_nr==5)])+1)
      anakin$scene_nr_scale[which(anakin$episode_nr==6)]<-anakin$scene_nr[which(anakin$episode_nr==6)]/(max(anakin$scene_nr[which(anakin$episode_nr==6)])+1)
      
      anakin$episode_scene<-anakin$episode_nr + anakin$scene_nr_scale
      

      anakin<-anakin[order(anakin$episode_nr, anakin$scene_nr),]
      
      
      words <- anakin[anakin$episode_nr %in% input$episode2, ] %>%
        group_by(episode_scene) %>%
        unnest_tokens(word, quote)
      
      
      afinn <- words %>% 
        inner_join(get_sentiments("afinn")) %>% 
        summarise(sentiment = sum(score)) 
      
      afinn$side<-afinn$sentiment
      afinn$side[which(afinn$sentiment<0)]<-"dark side"
      afinn$side[which(afinn$sentiment>=0)]<-"light side"
      
      scenki<-anakin[,c("episode_scene","scene_title", "scene_nr", "episode_nr")]
      scenki2<-unique.data.frame(scenki)
      
       afinn<-inner_join(afinn,scenki2,by="episode_scene")
       
       afinn$l<-paste("scene_nr= ",afinn$scene_nr, "episode_nr= ", afinn$episode_nr, "scene_title=", afinn$scene_title)
       
      
      pl <- ggplot(afinn, aes(x=episode_scene, y=sentiment, fill=side,  label=l)) +
        geom_col()+
         scale_fill_manual(values=c("firebrick4","deepskyblue4"))+
        labs(x="część filmu.scena",y="suma score")

      pl
      
    })
    
    # 5 -  WYPOWIEDZI
    
    output$wyk5= renderTable({
      data.frame(anakin[anakin$episode_nr %in% input$episode2, c(1,2,6,4)])
    })
    
    
  
})