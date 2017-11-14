source("baseScript.R")

library(stringr)
library(dplyr)

getTramsForNextStop <- function(data, nextStopName)
{
  results <- data %>% filter(str_detect(nextStop, nextStopName))
  results <- (results[,c("line", "previousStop", "nextStop", "nextStopDistance", "speed")])
  results$nextStopDistance <- round(results$nextStopDistance, 0)
  results$speed <- round(results$speed, 2)
  colnames(results) <- c("Linia", "Poprzedni przystanek", "Nastepny przystanek", "Dystans do nastepnego przystanku (m)", "Aktualna predkosc (m/s)")
  return(results)
}