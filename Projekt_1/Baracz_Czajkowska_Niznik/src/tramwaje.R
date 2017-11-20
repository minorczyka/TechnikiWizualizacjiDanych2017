library("rvest")
library("httr")
library("jsonlite")
library(dplyr)
library(ggplot2)
library(viridis)
library(lubridate)
library(ggExtra)
library(tidyr) 
library(plyr)
library(png)
library(grid)
library(jpeg)

downloadData <- function(linie)
{
  token2 <- "35dbb2ebd27b23cfbec359dbd560adf2d4a5b27b"
  res <- GET(url = paste0("https://vavel.mini.pw.edu.pl/api/vehicles/v1/full/?line=", linie),
             add_headers(Authorization = paste("Token", token2)))
  return(jsonlite::fromJSON(as.character(res)))
}

fillEmptyData <- function(line_number, all_hours){
  for(i in 1:length(all_hours))
  {
    if(!all_hours[i] %in% line_number$hour)
    {
      newrow <- c(line_number$line[1], "", as.numeric(-5), as.integer(all_hours[i]), as.integer(0) ,as.integer(-5))
      line_number <- rbind(line_number, newrow)
    }
  }
  return(line_number)
}

createTramsDF <- function(data)
{  
  trams <- data[,c("line", "time", "delay")]
  trams$hour <- (hour(ymd_hms(trams$time)))
  trams$delay_col <- as.integer(trams$delay/10)
  trams$delay_minutes <- as.integer(trams$delay/60)
  trams <- trams[order(trams$hour, trams$line, decreasing = TRUE),]

  all_hours <- unique(trams[, "hour"])

  line_10 <- subset(trams, line == "10")
  line_11 <- subset(trams, line == "11")
  line_23 <- subset(trams, line == "23")
  line_25 <- subset(trams, line == "25")
  line_28 <- subset(trams, line == "28")
  line_17 <- subset(trams, line == "17")
  line_33 <- subset(trams, line == "33")
  line_31 <- subset(trams, line == "31")
  line_20 <- subset(trams, line == "20")
  line_35 <- subset(trams, line == "35")
  line_14 <- subset(trams, line == "14")
  line_27 <- subset(trams, line == "27")
  line_7 <- subset(trams, line == "7")

  line_10 <- fillEmptyData(line_10, all_hours)
  line_33 <- fillEmptyData(line_33, all_hours)
  line_31 <- fillEmptyData(line_31, all_hours)
  line_7 <- fillEmptyData(line_7, all_hours)
  line_27 <- fillEmptyData(line_27, all_hours)
  line_14 <- fillEmptyData(line_14, all_hours)
  line_35 <- fillEmptyData(line_35, all_hours)
  line_20 <- fillEmptyData(line_20, all_hours)
  line_17 <- fillEmptyData(line_17, all_hours)
  line_11 <- fillEmptyData(line_11, all_hours)
  line_23 <- fillEmptyData(line_23, all_hours)
  line_25 <- fillEmptyData(line_25, all_hours)
  line_28 <- fillEmptyData(line_28, all_hours)
  
  trams_list <- list(line_10, line_14, line_17,
                   line_20, line_27, line_31,
                   line_33, line_35, line_7,
                   line_11, line_23, line_25, line_28)

  trams <- ldply(trams_list, data.frame)
  trams$time_of_day <- 0
  trams$time_of_day[trams$time_of_day == 0] = "Trams"
  return(trams)
}

createPlot <- function(trams){
  p <-ggplot(na.omit(trams),aes(as.integer(line),y=as.integer(minutes),fill=as.integer(delay_minutes)))+
  geom_tile(color= "white",aes(fill = as.integer(delay_minutes)), size=.1 ) + 
  scale_fill_gradient(name="Delay in minutes", low = "#61c12e", high = "#c90000", space = "Lab",
                      na.value = "#61c12e", guide = "colourbar")

  p <- p + xlab("Line")
  p <- p + ylab("Hour")
 # p <-p + facet_grid(.~time_of_day,drop = TRUE, scales = "free", labeller = label_parsed)
  p <-p + scale_y_continuous(breaks = unique(as.numeric(trams$minutes)), expand = c(0,0))
  p <-p + scale_x_continuous(breaks =c(1,2,3,4,6,7,9,10, 11,13, 14,15, 17,18, 20,22,23,24,25,26, 27,28, 31, 33, 34), expand = c(0,0), limits = c(1,37))
  p <-p + theme_minimal(base_size = 8)
  p <- p + coord_fixed(ratio=1)
  p <-p + theme(legend.position = "bottom")+
    theme(plot.title=element_text(size = 14))+
    theme(axis.text.y=element_text(size=7)) +
    theme(strip.background = element_rect(colour="white"))+
    theme(plot.title=element_text(hjust=0))+
    theme(axis.ticks=element_blank())+
    theme(axis.text=element_text(size=9))+
    theme(legend.title=element_text(size=8))+
    theme(legend.text=element_text(size=6))
    return(p)
}

drawPlot <- function()
{
  linie <- "1,2,3,4,6,7,9,10,11,13,14,15,17,18,20,22,23,24,25,26,27,28,31,33,34"
  data <- downloadData(linie)
  trams <- createTramsDF(data)
  createPlot(trams)
}

##########
#Wykres nr 2

fillEmptyData_rain <- function(line_number, all_minutes){
  for(i in 1:length(all_minutes))
  {
    if(!all_minutes[i] %in% line_number$minutes)
    {
      newrow <- c(line_number$line[1], "", as.numeric(-5), as.integer(all_minutes[i]), as.integer(0), as.integer(-5), as.integer(all_minutes[i]))
      line_number <- rbind(line_number, newrow)
    }
  }
  return(line_number)
}

createTramsDF_rain <- function(data)
{  
  current_hour <- hour(Sys.time())
  trams <- data[,c("line", "time", "delay")]
  trams$hour <- (hour(ymd_hms(trams$time)))
  trams$delay_col <- as.integer(trams$delay/10)
  trams$delay_minutes <- as.integer(trams$delay/60)
  trams <- trams[order(trams$hour, trams$line, decreasing = TRUE),]
  trams$minutes <- (minute(ymd_hms(trams$time)))
  
  trams <- subset( trams , trams$hour >= current_hour-24)
  
  all_minutes <- unique(trams[, "minutes"])
  all_lines <- unique(trams[, "line"])
  
  trams_list <- data.frame()
  for(i in 1:length(all_lines))
  {
    line <- subset(trams, line == all_lines[i])
    line <- fillEmptyData_rain(line, all_minutes)
  
    trams_list <- rbind(trams_list, line)
  }
  
  trams_list$time_of_day <- 0
  trams_list$time_of_day[trams_list$time_of_day == 0] = "Trams"
  return(trams_list)
}

createPlot_rain <- function(trams_list){
  p <-ggplot(na.omit(trams_list),aes(as.integer(line),y=as.integer(minutes),fill=as.integer(delay_minutes)))+
    geom_tile(color= "white",aes(fill = as.integer(delay_minutes)), size=.1 ) + 
    scale_fill_gradient(name="Delay in minutes", low = "#61c12e", high = "#c90000", space = "Lab",
                        na.value = "#61c12e", guide = "colourbar")
  
  p <- p + xlab("Line")
  p <- p + ylab("Minute")
  p <-p + scale_y_continuous(breaks = unique(as.numeric(trams_list$minutes)), expand = c(0,0))
  p <-p + scale_x_continuous(breaks =c(1,2,3,4,6,7,9,10, 11,13, 14,15, 17,18, 20,22,23,24,25,26, 27,28, 31, 33), expand = c(0,0), limits = c(1,37))
  p <-p + theme_minimal(base_size = 8)
  p <- p + coord_fixed(ratio=1)
  p <-p + theme(legend.position = "bottom")+
    theme(plot.title=element_text(size = 14))+
    theme(axis.text.y=element_text(size=7)) +
    theme(strip.background = element_rect(colour="white"))+
    theme(plot.title=element_text(hjust=0))+
    theme(axis.ticks=element_blank())+
    theme(axis.text.x=element_text(size=7, angle = 45, hjust = 1))+
    theme(legend.title=element_text(size=8))+
    theme(legend.text=element_text(size=6))+
    ggtitle("How not get caught by rain?")
  
  img <- readPNG("raindrop2.png")
  g <- rasterGrob(img, interpolate=TRUE)
  for (i in 1:nrow(trams_list))
  {
    delay <- as.integer(trams_list[i, "delay_minutes"])
    line <- as.integer(trams_list[i, "line"])
    minute <- as.integer(trams_list[i, "minutes"])
    if(0 <  delay & delay < 15)
    {
      p <- p + annotation_custom(g, xmin=line-2, xmax=line+1,
                                 ymin=minute, ymax=minute+3)
    }
    if(delay >= 15)
    {
      p <- p + annotation_custom(g, xmin=line-2, xmax=line+3,
                                 ymin=minute, ymax=minute+5)
    }
  }
  
  
  return(p)
}

addRainDropsToPlot <- function(p, trams_list)
{
  img <- readPNG("raindrop2.png")
  g <- rasterGrob(img, interpolate=TRUE)
  for (i in 1:nrow(trams_list))
  {
    if(4 < as.integer(trams_list[i, "delay_minutes"]) & as.integer(trams_list[i, "delay_minutes"]) < 15)
    {
      line <- as.integer(trams_list[i, "line"])
      minute <- as.integer(trams_list[i, "minutes"])
      p <- p + annotation_custom(g, xmin=line, xmax=line+2,
                                 ymin=minute+1, ymax=minute+3)
    }
  }
  return(p)
}

drawPlot_rain <- function()
{
  linie <- "1,2,3,4,6,7,9,10,11,13,14,15,17,18,20,22,23,24,25,26,27,28,31,33"
  data <- downloadData(linie)
  trams_data <- createTramsDF_rain(data)
  createPlot_rain(trams_data)
}