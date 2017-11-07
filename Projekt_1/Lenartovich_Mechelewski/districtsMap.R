library(geojsonio)

source("baseScript.R")

getDistrictsMap <- function(data) {
  points <- data.frame(pointNum=1:nrow(data), Long=data$lon, Lat=data$lat)
  districts <- geojson_read("graniceDzielnic.geojson", what = "sp", encoding="UTF-8")
  
  for (column in colnames(districts@data)) {
    if (is.factor(districts@data[ , column])) {
      char <- as.character(districts@data[ , column])
      Encoding(char) <- 'UTF-8'
      districts@data[ , column] <- as.factor(char)
    }
  }
  
  sp::coordinates(points) <- ~Long+Lat
  sp::proj4string(points) <- sp::proj4string(districts)
  
  pointsInDristricts <- rgeos::gWithin(points, districts, byid = TRUE)
  districtsValues <- apply(pointsInDristricts, 1, function(row) sum(row))
  districtsValues <- as.numeric(districtsValues)
  pal <- colorNumeric("Blues", domain=0:max(districtsValues))
  
  leaflet(districts) %>%
    addTiles() %>% addProviderTiles("Esri.WorldGrayCanvas") %>%
    addPolygons(stroke = TRUE, smoothFactor = 0.3, fillOpacity = 0.4, fillColor = ~pal(districtsValues), weight=2, color="black",
                label = ~paste0(districts$nazwa_dzielnicy, " ", "Liczba tramwajow", ": ", districtsValues)) %>%
    addLegend(pal = pal, values = ~districtsValues, opacity = 1.0, title="") %>%
    addFullscreenControl("bottomright")
}