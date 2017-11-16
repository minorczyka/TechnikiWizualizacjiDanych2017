library(rvest)
library(httr)
library(dplyr)
library(jsonlite)
library(ggplot2)
library(ggmap)
library(ggrepel)
library(maps)
library(mapdata)


multiplot <- function(..., plotlist=NULL, cols) {
  require(grid)
  
  # Make a list from the ... arguments and plotlist
  plots <- c(list(...), plotlist)
  
  numPlots = length(plots)
  
  # Make the panel
  plotCols = cols                          # Number of columns of plots
  plotRows = ceiling(numPlots/plotCols) # Number of rows needed, calculated from # of cols
  
  # Set up the page
  grid.newpage()
  pushViewport(viewport(layout = grid.layout(plotRows, plotCols)))
  vplayout <- function(x, y)
    viewport(layout.pos.row = x, layout.pos.col = y)
  
  # Make each plot, in the correct location
  for (i in 1:numPlots) {
    curRow = ceiling(i/plotCols)
    curCol = (i-1) %% plotCols + 1
    print(plots[[i]], vp = vplayout(curRow, curCol ))
  }
}


linie <- "17,33,41,502,411,525"
token2 <- "35dbb2ebd27b23cfbec359dbd560adf2d4a5b27b"

res_short <- GET(url = paste0("https://vavel.mini.pw.edu.pl/api/vehicles/v1/short/?line=", linie),
           add_headers(Authorization = paste("Token", token2)))

res <- GET(url = paste0("https://vavel.mini.pw.edu.pl/api/vehicles/v1/full/?line=", linie),
           add_headers(Authorization = paste("Token", token2)))

res <- content(res, as="text")
res <- jsonlite::fromJSON(as.character(res))
res <- res %>% filter(delayAtStop != "")

res$lon <- round(res$lon, 2)
res$lat <- round(res$lat, 2)
res$coords <- paste0((res$lon)," - ",(res$lat))

res_delayed <- res %>% filter(delay >= 100) 


qmap <- qmplot(lon, lat, data = res_delayed, maptype = "toner-lite", color=line, size=delay) +
  geom_label_repel(aes(label = speed), size=4, nudge_x= 0.001, nudge_y = 0.001)
qmap

#coords_map <- qmplot(lon, lat, data = res, maptype = "toner-lite", shape=line, size=delay, color=speed) +
#  facet_wrap(~ line)
#coords_map

#coords_map <- qmplot(lon, lat, data = res, maptype = "toner-lite", shape=line, size=delay, color=speed) +
#  geom_text(aes(label = coords), check_overlap = TRUE, size=4, nudge_x= 0.01)

#delay_map <- qmplot(lon, lat, data = res, maptype = "toner-lite", shape=line, size=delay, color=speed)
#multiplot(coords_map, delay_map, cols = 2)
