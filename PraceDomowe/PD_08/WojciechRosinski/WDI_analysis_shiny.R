library(ggplot2)
library(dplyr)
library(stringr)
library(reshape)


# Data: https://data.worldbank.org/data-catalog/world-development-indicators
# Oryginalne dane nie zostały załączone, ponieważ zajmują 150mb


delete.na <- function(DF, n=0) {
  DF[rowSums(is.na(DF)) <= n,]
}

clean_dataset <- function() {
  
  df <- read.csv('/home/w/Projects/TWD/Moje/W8/WDIData.csv')
  
  pl <- df %>% filter(Country.Name == "Poland")
  pl <- delete.na(pl, 10)
  
  pl_ele <- pl %>% filter(str_detect(Indicator.Name, 'Electric')) %>% 
    filter(str_detect(Indicator.Name, '%')) %>% 
    filter(!str_detect(Indicator.Name, 'and')) 
  
  colnames(pl_ele) <- gsub("X", "", colnames(pl_ele))
  pl_ele$Indicator.Name <- gsub("Electricity production from ", "", pl_ele$Indicator.Name)
  pl_ele$Indicator.Name <- gsub(" sources", "", pl_ele$Indicator.Name)
  pl_ele$Indicator.Name <- gsub("(% of total)", "", pl_ele$Indicator.Name)
  pl_ele$Indicator.Name <- gsub("[[:punct:]]", "", pl_ele$Indicator.Name)
  colnames(pl_ele)[3] <- 'Zrodlo.Energii'
  
  pl_elem <- melt(pl_ele[,-dim(pl_ele)[2]])
  pl_elem$variable <- as.numeric(as.character(pl_elem$variable))
  pl_elem$value <- as.numeric(pl_elem$value)
  pl_elem <- pl_elem %>% filter(variable > 1980)
  return(pl_elem)
}


pl_elem <- clean_dataset()
write.csv(pl_elem, file='/home/w/Projects/TWD/Moje/W8/PL_energy.csv', row.names = F)