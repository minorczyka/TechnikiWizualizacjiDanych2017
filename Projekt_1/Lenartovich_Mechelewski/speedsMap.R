source("baseScript.R")

getMarkers <- function(trams) {
  colors <- sapply(trams$speed, function(speed) {
    if(is.na(speed)) return("red")
    if(speed > 10) return("green")
    if(speed > 5) return("orange")
    return("red")
  })
  
  awesomeIcons(
    icon = 'ios-close',
    iconColor = 'black',
    library = 'ion',
    markerColor = colors
  )
}

getSpeedsMap <- function(data) {
  slowTrams <- data[data$speed<=5,]
  normalTrams <- data[data$speed>5&data$speed<=10,]
  speedTrams <- data[data$speed>10,]
  
  leaflet() %>% addTiles() %>%
    addAwesomeMarkers(~lon, ~lat, icon=getMarkers(slowTrams), popup = ~as.character(speed), label = ~as.character(line), data=slowTrams, group="<=5m/s") %>%
    addAwesomeMarkers(~lon, ~lat, icon=getMarkers(normalTrams), popup = ~as.character(speed), label = ~as.character(line), data=normalTrams, group="<=10m/s") %>%
    addAwesomeMarkers(~lon, ~lat, icon=getMarkers(speedTrams), popup = ~as.character(speed), label = ~as.character(line), data=speedTrams, group=">10m/s") %>%
    addLayersControl(
      overlayGroups = c("<=5m/s", "<=10m/s", ">10m/s"),
      options = layersControlOptions(collapsed = FALSE)
    ) %>%
    addFullscreenControl("bottomright")
}