library(rvest)
library(httr)
library(jsonlite)
library(ggplot2)
library(OpenStreetMap)
library(dplyr)
library(leaflet)
library(leaflet.extras)
library(stringi)

getData <- function() {
  linie <- paste(1:99, collapse = ",")
  token <- "35dbb2ebd27b23cfbec359dbd560adf2d4a5b27b"
  
  data <- GET(url = paste0("https://vavel.mini.pw.edu.pl/api/vehicles/v1/full/?line=", linie), add_headers(Authorization = paste("Token", token)))
  data <- as.data.frame(jsonlite::fromJSON(as.character(data)))
  filteredData <- filterData(data)
  return(filteredData)
}

filterData <- function(data) {
  timeMargin <- 1800
  dane <- na.omit(data)
  dane <- dane[dane$status != 'STOPPED', ]
  splited <- t(as.data.frame(strsplit(dane$time, 'T')))
  row.names(splited) <- NULL
  
  final <- paste(splited[,1], stri_sub(splited[,2], from=1, length = 8))
  final <- as.POSIXct(final, tz="Europe/London")
  final <- format(final, tz=Sys.timezone(), usetz=TRUE)
  final <- stri_sub(final,from=1, length=19)
  final <- as.POSIXlt(final, format='%Y-%m-%d %H:%M:%S')
  
  dane[final > (Sys.time() - timeMargin), ]
}
