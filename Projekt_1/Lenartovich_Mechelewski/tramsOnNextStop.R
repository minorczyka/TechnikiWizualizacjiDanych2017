source("baseScript.R")

library(stringr)
library(dplyr)

getTramsForNextStop <- function(data, nextStopName)
{
  results <- data %>% filter(str_detect(nextStop, nextStopName))
  return(results[,c("line", "previousStop", "nextStop", "nextStopDistance", "speed")])
}
