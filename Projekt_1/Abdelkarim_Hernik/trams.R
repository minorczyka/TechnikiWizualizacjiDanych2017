doc = 'Usage: trams.R [stop line direction]

 stop - the station which is highlighted on the map
 line - the line which is shown - 10, 17 or 33
 direction - the direction of the course
example (default parameters):
 trams.R "Metro Politechnika" 10 Wyścigi
'
myargs = commandArgs(TRUE)
if (length(myargs) < 3 ||
		!(myargs[2] %in% c(10, 17, 33)) || 
		myargs[1] == "" || myargs[3] == "") {
	cat(doc)
	stop()
}

suppressMessages(library("rvest"))
suppressMessages(library("httr"))
suppressMessages(library("jsonlite"))
suppressMessages(library("ggplot2"))
suppressMessages(library("ggmap"))
suppressMessages(library("ggrepel"))
suppressMessages(library("Hmisc"))
suppressMessages(library("dplyr"))
suppressMessages(library("lubridate"))

linie <- "10,17,33"
token2 <- "35dbb2ebd27b23cfbec359dbd560adf2d4a5b27b"

res <- GET(url = paste0("https://vavel.mini.pw.edu.pl/api/vehicles/v1/full/?line=", linie),
					 add_headers(Authorization = paste("Token", token2)))
data = jsonlite::fromJSON(as.character(res))
warsaw_map = get_map(location = "warsaw", maptype="roadmap", zoom=11)

line = myargs[2]
direction = myargs[3]
mystop = myargs[1]

stops = read.csv("stops.csv")
stops = stops[stops$line == line & stops$direction == direction,1:3]
stops$name = capitalize(substring(stops$name, 6))
datamoving = data[data$nextStop != "" & data$previousStop != "" & data$line == line & data$courseDirection == direction,]
datamoving = datamoving[datamoving$nextStopDistance < 1500,] #wywalamy tramwaje z bardzo duza odlegloscia od przystanku - najprawdopodobniej anomalie, rzeczywiste wartosci nie wieksze niz ~600
#Średnia odległość między przystankami autobusowymi to 1041 metrów, jest to jednak liczba zawyżona przez linie ekspresowe (średnia odległość 699 m). - warszawa.wikia.com/wiki/Autobusy
datamoving = cbind(datamoving, ifelse(datamoving$delay>=0, "Delay: ", "Delay: -"))
names(datamoving)[length(datamoving)] = "delayhms"
datamoving$delayhms = paste(datamoving$delayhms, seconds_to_period(abs(datamoving$delay)), sep = "")
datamoving$delayhms = paste(datamoving$delayhms, paste("Speed:", datamoving$speed), sep="\n")

set.seed(1234)
deltax = 0.04
deltay = 0.02
chart = ggmap(warsaw_map) + 
	scale_x_continuous(limits = c(min(datamoving$lon) - deltax, max(datamoving$lon) + deltax), expand = c(0,0)) +
	scale_y_continuous(limits = c(min(datamoving$lat) - deltay, max(datamoving$lat) + deltay), expand = c(0,0)) +
	geom_segment(aes(x=previousStopLon, y=previousStopLat, xend=lon, yend = lat), color="dodgerblue", datamoving, size=5) +
	geom_segment(aes(x=lon, y=lat, xend=nextStopLon, yend = nextStopLat), color="dodgerblue", datamoving, size=5) +
	geom_point(aes(x=lon, y=lat), stops[stops$name != mystop,], shape=23, size = 5, fill="dodgerblue") +
	geom_point(aes(x=lon, y=lat), stops[stops$name == mystop,], shape=23, size = 5, fill="purple") +
	geom_point(aes(x=lon, y=lat, fill=delay, shape=status), datamoving, size=7) +
	scale_fill_gradient2(low="green", mid="white", high="red") +
	geom_segment(aes(x=lon, y=lat, xend=nextStopLon, yend = nextStopLat, color=speed), datamoving, arrow = arrow(length = unit(0.3, "cm"), angle=60), size=3) +
	scale_color_gradientn(colors=c("lightyellow", "gold", "goldenrod")) +
	geom_label_repel(aes(lon, lat, label=name), stops[stops$name == mystop,], color="white", fill="purple", segment.color="purple", label.r=0.5, point.padding = 0.25, segment.alpha = 1) +
	geom_label_repel(aes(lon, lat, label=name), stops[stops$name != mystop,], color="white", fill="dodgerblue", segment.color="dodgerblue", label.r=0.5, point.padding = 2.25, segment.alpha = 1) +
	geom_label_repel(aes(lon, lat, label=delayhms), datamoving, fill="white", alpha=0.7, label.r=0, label.size = 1, segment.alpha = 1, point.padding = 0.25) +
	scale_shape_manual(values=c(21,22,24,25)) +
	ggtitle(paste(format(Sys.time(), "%Y-%m-%d %H:%M:%S %Z"), "- tramwaje linii", line, "w kierunku", direction))

print(chart)
ggsave("plot.png", device = "png")