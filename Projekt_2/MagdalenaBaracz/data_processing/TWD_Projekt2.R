setwd("/Users/mbaracz/Documents/")
library(dplyr)
library(png)
library(plotly)
library(stringi)
library(ggplot2)
library(tidytext)
library(shiny)
library(extrafont)

font_import(pattern = "AVENGEANCE")

script <- readLines("avengers_screenplay.txt")
script <- iconv(script, "latin1", "ASCII", sub="")

script <- data.frame(script=script, stringsAsFactors = FALSE)
script$scene <- NA
script$person <- NA
script$place <- NA
script$daytime <- NA
script$emo <- NULL
script$removeline <- FALSE
script$hero <- ""

script <- filter(script, nchar(script) != 0)
script <- script[-(1:16),]
script <- script[-((nrow(script)-9):nrow(script)),]

scene_no <- 0
person <- ""
place <- ""
daytime <- ""

for(i in 1:nrow(script)) {
  # scena we wnętrzu
  if(substr(script[i, "script"], 1, 15) == "          INT. ")
  {
    scene_no <- scene_no + 1
    person <- ""
    place <- trimws(script[i, "script"])
    script[i, "removeline"] <- TRUE
  }
  
  # scena na zewnątrz
  if(substr(script[i, "script"], 1, 15) == "          EXT. ")
  {
    scene_no <- scene_no + 1 
    person <- ""
    place <- trimws(script[i, "script"])
    script[i, "removeline"] <- TRUE
  }
  
  if(substr(script[i, "script"], 1, 16) != "                ")
    script[i, "removeline"] <- TRUE
  
  if(substr(script[i, "script"], 1, 30) == "                              ")
    script[i, "removeline"] <- TRUE
  
  # oznaczenie kto wypowie kwestię z następnego wiersza
  if(substr(script[i, "script"], 1, 26) == "                          ")
  {
    person <- trimws(script[i, "script"])
    script[i, "removeline"] <- TRUE
  }
  
  if(substr(script[i, "script"], 1, 27) == "                          (")
  {
    person <- script[i-1, "person"]
    script[i, "removeline"] <- FALSE
  }
  
  if(substr(script[i, "script"], (nchar(script[i, "script"])+1)-1, nchar(script[i, "script"])) == ")")
  {
    person <- script[i-1, "person"]
    script[i, "removeline"] <- TRUE
  }

  if(substr(script[i, "script"], 1, 33) == "                          CUT TO:")
  {
    person <- ""
    script[i, "removeline"] <- FALSE
  }
  
  script[i, "hero"] <- "hero"
  script[i, "emo"] <- ""
  script[i, "scene"] <- scene_no
  script[i, "person"] <- person
  script[i, "place"] <- substring(place,5)
  script[i, "daytime"] <- tail(strsplit(script[i, "place"],split=" ")[[1]],1)
  script[i, "place"] <- substr(script[i, "place"], 1, nchar(script[i, "place"])- nchar(script[i, "daytime"]) -1)
  if(script[i, "daytime"]=="CONTINUOUS")
  {
    script[i, "daytime"] <- script[i-1, "daytime"]
  }
}

script_clean <- script %>%
  filter(removeline, scene!=0) %>%
  select(scene, person, script, place, daytime, emo, hero) %>%
  mutate(script=trimws(script))

script_clean <- script_clean %>%
  filter(!person %in% c("", "NATASHA BANNER", "TONY STEVE", "STEVE TONY"))

script_clean$person <- gsub("PEPPER", replacement = "PEPPER POTTS", script_clean$person, fixed = TRUE)
script_clean$person <- gsub("PEPPER POTTS POTTS", replacement = "PEPPER POTTS", script_clean$person, fixed = TRUE)

script_clean$person <- gsub("BARTON", replacement = "CLINT BARTON", script_clean$person, fixed = TRUE)
script_clean$person <- gsub("CLINT CLINT BARTON", replacement = "CLINT BARTON", script_clean$person, fixed = TRUE)

script_clean$person <- gsub("7 ALPHA 11", replacement = "7 ALPHA 11 PILOT", script_clean$person, fixed = TRUE)
script_clean$person <- gsub("7 ALPHA 11 PILOT PILOT", replacement = "7 ALPHA 11 PILOT", script_clean$person, fixed = TRUE)

script_clean$daytime <- gsub("(LATER)", replacement = "LATER", script_clean$daytime, fixed = TRUE)

script_clean <- script_clean %>%
  filter(!person %in% c("SELVIG", "PEPPER POTTS", "JARVIS"))


script_clean %>%
  select(scene, person) %>%
  unique() %>%
  ggplot() +
  geom_tile(aes(scene, person)) +
  theme_minimal()

script_combined <- script_clean
script_combined[script_combined$person=="NATASHA",]$hero = "alter ego"
script_combined$person <- gsub("NATASHA", replacement = "NBW", script_combined$person, fixed = TRUE)
script_combined$person <- gsub("BLACK WIDOW", replacement = "NBW", script_combined$person, fixed = TRUE)
script_combined$person <- gsub("NBW", replacement = "NATASHA/BLACK WIDOW", script_combined$person, fixed = TRUE)

script_combined[script_combined$person=="BANNER",]$hero = "alter ego"
script_combined$person <- gsub("BANNER", replacement = "BH", script_combined$person, fixed = TRUE)
script_combined$person <- gsub("HULK", replacement = "BH", script_combined$person, fixed = TRUE)
script_combined$person <- gsub("BH", replacement = "BANNER/HULK", script_combined$person, fixed = TRUE)

script_combined[script_combined$person=="STEVE",]$hero = "alter ego"
script_combined$person <- gsub("CAPTAIN AMERICA", replacement = "SCA", script_combined$person, fixed = TRUE)
script_combined$person <- gsub("STEVE", replacement = "SCA", script_combined$person, fixed = TRUE)
script_combined$person <- gsub("SCA", replacement = "STEVE/CAPTAIN AMERICA", script_combined$person, fixed = TRUE)

script_combined[script_combined$person=="TONY",]$hero = "alter ego"
script_combined$person <- gsub("IRON MAN", replacement = "TIM", script_combined$person, fixed = TRUE)
script_combined$person <- gsub("TONY", replacement = "TIM", script_combined$person, fixed = TRUE)
script_combined$person <- gsub("TIM", replacement = "TONY/IRON MAN", script_combined$person, fixed = TRUE)

script_combined[script_combined$person=="CLINT BARTON",]$hero = "alter ego"
script_combined$person <- gsub("CLINT BARTON", replacement = "CBH", script_combined$person, fixed = TRUE)
script_combined$person <- gsub("HAWKEYE", replacement = "CBH", script_combined$person, fixed = TRUE)
script_combined$person <- gsub("CBH", replacement = "CLINT BARTON/HAWKEYE", script_combined$person, fixed = TRUE)

script_combined <- script_combined %>%
  filter(!person %in% c("WAITRESS", "SENATOR BOYNTON", "POLICE SERGEANT", "YOUNG COP","SECURITY GUARD","ESCORT 606 PILOT","HELMSMAN","GALAGA PLAYER","THE OTHER",
                        "SHIELD SCIENTIST", "PILOT", "LITTLE GIRL" , "ATTENDING WOMAN" ,  "NASA SCIENTIST" , "LUCHKOV", "7 ALPHA 11 PILOT", "WEASELLY THUG", "AGENT MARIA HILL"))

################################### EMOTIONS ###################################################

########## BANNER/HULK ########## EMOTIONS
script_sentiment <- script_combined %>%
  unnest_tokens(word, script) %>%
  filter(!word %in% stop_words$word)

script_sentiment <- script_sentiment[script_sentiment$person=="BANNER/HULK",]

sent <- script_sentiment %>%
  inner_join( get_sentiments("nrc") , by="word") %>%
  group_by(scene)

most_freq_sent <- sent %>% group_by(scene) %>% summarize (emo = names(which.max(table(sentiment))))

for(i in 1:nrow(script_combined)) {
  if (script_combined[i,]$person == "BANNER/HULK") {
    script_combined[i,]$emo <- most_freq_sent[most_freq_sent$scene==script_combined[i,]$scene,]$emo
    if (is.na(script_combined[i,]$emo)) {
      script_combined[i,]$emo <- "neutral"
    }
  }
}

########## NATASHA/BLACK WIDOW ########## EMOTIONS
script_sentiment <- script_combined %>%
  unnest_tokens(word, script) %>%
  filter(!word %in% stop_words$word)

script_sentiment <- script_sentiment[script_sentiment$person=="NATASHA/BLACK WIDOW",]

sent <- script_sentiment %>%
  inner_join( get_sentiments("nrc") , by="word") %>%
  group_by(scene)

most_freq_sent <- sent %>% group_by(scene) %>% summarize (emo = names(which.max(table(sentiment))))

for(i in 1:nrow(script_combined)) {
  if (script_combined[i,]$person == "NATASHA/BLACK WIDOW") {
    if (length(most_freq_sent[most_freq_sent$scene==script_combined[i,]$scene,]$emo) == 0) {
      script_combined[i,]$emo <- "neutral"
    } else {
      script_combined[i,]$emo <- most_freq_sent[most_freq_sent$scene==script_combined[i,]$scene,]$emo
    }
  }
}

########## STEVE/CAPTAIN AMERICA ########## EMOTIONS
script_sentiment <- script_combined %>%
  unnest_tokens(word, script) %>%
  filter(!word %in% stop_words$word)

script_sentiment <- script_sentiment[script_sentiment$person=="STEVE/CAPTAIN AMERICA",]

sent <- script_sentiment %>%
  inner_join( get_sentiments("nrc") , by="word") %>%
  group_by(scene)

most_freq_sent <- sent %>% group_by(scene) %>% summarize (emo = names(which.max(table(sentiment))))

for(i in 1:nrow(script_combined)) {
  if (script_combined[i,]$person == "STEVE/CAPTAIN AMERICA") {
    if (length(most_freq_sent[most_freq_sent$scene==script_combined[i,]$scene,]$emo) == 0) {
      script_combined[i,]$emo <- "neutral"
    } else {
      script_combined[i,]$emo <- most_freq_sent[most_freq_sent$scene==script_combined[i,]$scene,]$emo
    }
  }
}

########## TONY/IRON MAN ########## EMOTIONS
script_sentiment <- script_combined %>%
  unnest_tokens(word, script) %>%
  filter(!word %in% stop_words$word)

script_sentiment <- script_sentiment[script_sentiment$person=="TONY/IRON MAN",]

sent <- script_sentiment %>%
  inner_join( get_sentiments("nrc") , by="word") %>%
  group_by(scene)

most_freq_sent <- sent %>% group_by(scene) %>% summarize (emo = names(which.max(table(sentiment))))

for(i in 1:nrow(script_combined)) {
  if (script_combined[i,]$person == "TONY/IRON MAN") {
    if (length(most_freq_sent[most_freq_sent$scene==script_combined[i,]$scene,]$emo) == 0) {
      script_combined[i,]$emo <- "neutral"
    } else {
      script_combined[i,]$emo <- most_freq_sent[most_freq_sent$scene==script_combined[i,]$scene,]$emo
    }
  }
}

########## CLINT BARTON/HAWKEYE ########## EMOTIONS
script_sentiment <- script_combined %>%
  unnest_tokens(word, script) %>%
  filter(!word %in% stop_words$word)

script_sentiment <- script_sentiment[script_sentiment$person=="CLINT BARTON/HAWKEYE",]

sent <- script_sentiment %>%
  inner_join( get_sentiments("nrc") , by="word") %>%
  group_by(scene)

most_freq_sent <- sent %>% group_by(scene) %>% summarize (emo = names(which.max(table(sentiment))))

for(i in 1:nrow(script_combined)) {
  if (script_combined[i,]$person == "CLINT BARTON/HAWKEYE") {
    if (length(most_freq_sent[most_freq_sent$scene==script_combined[i,]$scene,]$emo) == 0) {
      script_combined[i,]$emo <- "neutral"
    } else {
      script_combined[i,]$emo <- most_freq_sent[most_freq_sent$scene==script_combined[i,]$scene,]$emo
    }
  }
}

########## THOR ########## EMOTIONS
script_sentiment <- script_combined %>%
  unnest_tokens(word, script) %>%
  filter(!word %in% stop_words$word)

script_sentiment <- script_sentiment[script_sentiment$person=="THOR",]

sent <- script_sentiment %>%
  inner_join( get_sentiments("nrc") , by="word") %>%
  group_by(scene)

most_freq_sent <- sent %>% group_by(scene) %>% summarize (emo = names(which.max(table(sentiment))))

for(i in 1:nrow(script_combined)) {
  if (script_combined[i,]$person == "THOR") {
    if (length(most_freq_sent[most_freq_sent$scene==script_combined[i,]$scene,]$emo) == 0) {
      script_combined[i,]$emo <- "neutral"
    } else {
      script_combined[i,]$emo <- most_freq_sent[most_freq_sent$scene==script_combined[i,]$scene,]$emo
    }
  }
}

########## NICK FURY ########## EMOTIONS
script_sentiment <- script_combined %>%
  unnest_tokens(word, script) %>%
  filter(!word %in% stop_words$word)

script_sentiment <- script_sentiment[script_sentiment$person=="NICK FURY",]

sent <- script_sentiment %>%
  inner_join( get_sentiments("nrc") , by="word") %>%
  group_by(scene)

most_freq_sent <- sent %>% group_by(scene) %>% summarize (emo = names(which.max(table(sentiment))))

for(i in 1:nrow(script_combined)) {
  if (script_combined[i,]$person == "NICK FURY") {
    if (length(most_freq_sent[most_freq_sent$scene==script_combined[i,]$scene,]$emo) == 0) {
      script_combined[i,]$emo <- "neutral"
    } else {
      script_combined[i,]$emo <- most_freq_sent[most_freq_sent$scene==script_combined[i,]$scene,]$emo
    }
  }
}

########## LOKI ########## EMOTIONS
script_sentiment <- script_combined %>%
  unnest_tokens(word, script) %>%
  filter(!word %in% stop_words$word)

script_sentiment <- script_sentiment[script_sentiment$person=="LOKI",]

sent <- script_sentiment %>%
  inner_join( get_sentiments("nrc") , by="word") %>%
  group_by(scene)

most_freq_sent <- sent %>% group_by(scene) %>% summarize (emo = names(which.max(table(sentiment))))

for(i in 1:nrow(script_combined)) {
  if (script_combined[i,]$person == "LOKI") {
    if (length(most_freq_sent[most_freq_sent$scene==script_combined[i,]$scene,]$emo) == 0) {
      script_combined[i,]$emo <- "neutral"
    } else {
      script_combined[i,]$emo <- most_freq_sent[most_freq_sent$scene==script_combined[i,]$scene,]$emo
    }
  }
}

write.csv(script_combined, "script_combined.csv")