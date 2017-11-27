library("rvest")
library("httr")
library("jsonlite")
library(wordcloud2)
library(tm)
library(gridExtra)

linie <- "1,2,3,4,6,7,9,10,11,13,14,15,17,18,20,22,23,24,25,26,27,28,31,33,35"
token2 <- "35dbb2ebd27b23cfbec359dbd560adf2d4a5b27b"

res <- GET(url = paste0("https://vavel.mini.pw.edu.pl/api/vehicles/v1/full/?line=", linie),
           add_headers(Authorization = paste("Token", token2)))

table <- jsonlite::fromJSON(as.character(res))

GetOccurence <- function(word, table) {
  occurence <- as.data.frame(table)
  occurence <- occurence[grep(word, occurence[,1]), ]
  return(length(occurence))
}

# Plot Delay At Stop
plotDelayAtStop <- function() {
  delayAtStop <- data.frame(letter=data.frame(levels(as.factor(table$delayAtStop))), occurance=apply(data.frame(levels(as.factor(table$delayAtStop))), 1, function(x) GetOccurence(x, table$delayAtStop)))
  delayAtStop = delayAtStop[-1,]
  delayAtStop$levels.as.factor.table.delayAtStop.. <- sub(".*-", "", delayAtStop$levels.as.factor.table.delayAtStop..)
  wordcloud2(data = head(delayAtStop, 700), shape="square", size=0.7)
}

# Plot Course Direction
plotCourseDirection <- function() {
  courseDirection <- data.frame(letter=data.frame(levels(as.factor(table$courseDirection))), occurance=apply(data.frame(levels(as.factor(table$courseDirection))), 1, function(x) GetOccurence(x, table$courseDirection)))
  courseDirection = courseDirection[-1,]
  wordcloud2(data = head(courseDirection, 700), shape="square", size=0.7)
}
plotProportions <- function() {
  
kobe_theme <- function() {
  theme(
    axis.text = element_text(colour = "#E7A922", family = "Arial"),
    plot.title = element_text(colour = "#552683", face = "bold", size = 18, vjust = 1, family = "Arial"),
    axis.title = element_text(colour = "#552683", face = "bold", size = 13, family = "Arial"),
    panel.grid.major.x = element_line(colour = "#E7A922"),
    panel.grid.minor.x = element_blank(),
    panel.grid.major.y = element_blank(),
    panel.grid.minor.y = element_blank(),
    strip.text = element_text(family = "Arial", colour = "white"),
    strip.background = element_rect(fill = "#E7A922"),
    axis.ticks = element_line(colour = "#E7A922")
  )
}
# Proportion of Status
 
statuses <- data.frame(levels(as.factor(table$status)))
names(statuses)[1] <- "Status"
status <- data.frame(letter=statuses, occurance=apply(data.frame(levels(as.factor(table$status))), 1, function(x) GetOccurence(x, table$status)))
status <- status[order(status$occurance), ]
status$occurance <- status$occurance*100/sum(status$occurance)
status.ymax = cumsum(status$occurance)
status.ymin = c(0, head(status$occurance, n=-1))
plotStatus <- ggplot(status, aes(fill=status$Status, ymax=status.ymax, ymin=status.ymin , xmax=1, xmin=3)) +
  geom_rect() +
  coord_polar(theta="y") +
  xlim(c(1, 3)) +
  labs(title="Proportion of Status") + 
  kobe_theme() + 
  labs(fill='Status') 

# Proportion of Timetable Status

timetable_statuses <- data.frame(levels(as.factor(table$timetableStatus)))
names(timetable_statuses)[1] <- "Status"
timetable_status <- data.frame(letter=timetable_statuses, occurance=apply(data.frame(levels(as.factor(table$timetableStatus))), 1, function(x) GetOccurence(x, table$timetableStatus)))
timetable_status <- timetable_status[order(timetable_status$occurance), ]
timetable_status$occurance <- timetable_status$occurance*100/sum(timetable_status$occurance)
timetable_status.ymax = cumsum(timetable_status$occurance)
timetable_status.ymin = c(0, head(timetable_status$occurance, n=-1))
plotTimetableStatus <- ggplot(timetable_status, aes(fill=timetable_status$Status, ymax=timetable_status.ymax, ymin=timetable_status.ymin , xmax=1, xmin=3)) +
  geom_rect() +
  coord_polar(theta="y") +
  xlim(c(1, 3)) +
  labs(title="Proportion of Timetable Status") + 
  kobe_theme() + 
  labs(fill='Timetable Status') 


# Proportion of trams on way to depot trams

onWayToDepots <- data.frame(levels(as.factor(table$onWayToDepot)))
names(onWayToDepots)[1] <- "onWayToDepots"
onWayToDepot <- data.frame(letter=onWayToDepots, occurance=apply(data.frame(levels(as.factor(table$onWayToDepot))), 1, function(x) GetOccurence(x, table$onWayToDepot)))
onWayToDepot <- onWayToDepot[order(onWayToDepot$occurance), ]
onWayToDepot$occurance <- onWayToDepot$occurance*100/sum(onWayToDepot$occurance)
onWayToDepot.ymax = cumsum(onWayToDepot$occurance)
onWayToDepot.ymin = c(0, head(onWayToDepot$occurance, n=-1))
plotOnWayToDepot <- ggplot(onWayToDepot, aes(fill=onWayToDepot$onWayToDepots, ymax=onWayToDepot.ymax, ymin=onWayToDepot.ymin , xmax=0, xmin=1)) +
  geom_rect() +
  coord_polar(theta="y") +
  xlim(c(0, 1)) +
  labs(title="Proportion of trams 
on way to depot trams") + 
  kobe_theme() + 
  labs(fill='On Way To Depot') 

# Proportion of on way to depot trams

overlapsWithNextBrigadeStopLineBrigades <- data.frame(levels(as.factor(table$overlapsWithNextBrigadeStopLineBrigade)))
names(overlapsWithNextBrigadeStopLineBrigades)[1] <- "overlapsWithNextBrigadeStopLineBrigades"
overlapsWithNextBrigadeStopLineBrigade <- data.frame(letter=overlapsWithNextBrigadeStopLineBrigades, occurance=apply(data.frame(levels(as.factor(table$overlapsWithNextBrigadeStopLineBrigade))), 1, function(x) GetOccurence(x, table$overlapsWithNextBrigadeStopLineBrigade)))
overlapsWithNextBrigadeStopLineBrigade <- overlapsWithNextBrigadeStopLineBrigade[order(overlapsWithNextBrigadeStopLineBrigade$occurance), ]
overlapsWithNextBrigadeStopLineBrigade$occurance <- overlapsWithNextBrigadeStopLineBrigade$occurance*100/sum(overlapsWithNextBrigadeStopLineBrigade$occurance)
overlapsWithNextBrigadeStopLineBrigade.ymax = cumsum(overlapsWithNextBrigadeStopLineBrigade$occurance)
overlapsWithNextBrigadeStopLineBrigade.ymin = c(0, head(overlapsWithNextBrigadeStopLineBrigade$occurance, n=-1))
plotOverlapsWithNextBrigadeStopLineBrigade <- ggplot(overlapsWithNextBrigadeStopLineBrigade, aes(fill=overlapsWithNextBrigadeStopLineBrigade$overlapsWithNextBrigadeStopLineBrigades, ymax=overlapsWithNextBrigadeStopLineBrigade.ymax, ymin=overlapsWithNextBrigadeStopLineBrigade.ymin , xmax=0, xmin=1)) +
  geom_rect() +
  coord_polar(theta="y") +
  xlim(c(0, 1)) +
  labs(title="Proportion of overlaps With 
Next Brigade Stop Line Brigade") + 
  kobe_theme() + 
  labs(fill='Overlaps With 
Next Brigade 
Stop Line 
Brigade') 

grid.arrange(plotStatus, plotTimetableStatus, plotOnWayToDepot, plotOverlapsWithNextBrigadeStopLineBrigade, ncol=2, nrow=2)
}