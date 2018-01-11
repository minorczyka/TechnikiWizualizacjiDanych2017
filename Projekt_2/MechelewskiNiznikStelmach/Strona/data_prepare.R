library(dplyr)
library(tidytext)

source("getScripts.R")

prepare_data <- function(gf_script){
  people <- gf_script %>%
    select(person) %>%
    distinct(person)

  scenes <- 1:max(gf_script$scene)

  scenes_people <- expand.grid(scenes, people$person) %>%
    rename(scene = Var1, person = Var2)
  
  words <- gf_script %>%
    unnest_tokens(word, script) %>%
    filter(!word %in% stop_words$word) %>%
    arrange(scene, person)
  
  alllll <- scenes_people %>%
    full_join(words)
  
  alllll %>%
  # words %>%
    left_join(get_sentiments("afinn"), by="word") %>%
    group_by(scene, person) %>%
    summarise(sentiment=mean(score, na.rm = TRUE)) %>%
    ungroup() %>%
    mutate(sentiment = ifelse(is.na(sentiment), 0, sentiment * 100)) %>%
    mutate(col=ifelse(sentiment>=0, "positive", "negative")) %>%
    mutate(col=ifelse(sentiment==0, "neutral", col))
}
  
sentiment_g1 <- prepare_data(godfather) %>%
  mutate(part = 1)
sentiment_g2 <- prepare_data(godfather2) %>%
  mutate(scene = scene + max(sentiment_g1$scene)) %>%
  mutate(part = 2)
sentiment <- rbind(sentiment_g1, sentiment_g2)
save(sentiment, file = "sentiment.rda")

unique(godfather$person)
unique(godfather2$person)
unique(sentiment$person)
