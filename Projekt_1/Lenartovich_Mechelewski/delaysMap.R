source("baseScript.R")

getDelaysMarkers <- function(trams) {
  colors <- sapply(trams$delay, function(delay) {
    if(delay > 200) return("red")
    if(delay > 100) return("orange")
    return("green")
  })
  
  awesomeIcons(
    icon = 'ios-close',
    iconColor = 'black',
    library = 'ion',
    markerColor = colors
  )
}

getDelaysMap <- function(data) {
  withoutDelay <- data[data$delay<=100,]
  minimalDelay <- data[data$delay>100&data$delay<=200,]
  bigDelay <- data[data$delay>200,]
  
  leaflet() %>% addTiles() %>%
    addAwesomeMarkers(~lon, ~lat, icon=getDelaysMarkers(withoutDelay), popup = ~as.character(delay), label = ~as.character(line), data=withoutDelay, group="<=100s") %>%
    addAwesomeMarkers(~lon, ~lat, icon=getDelaysMarkers(minimalDelay), popup = ~as.character(delay), label = ~as.character(line), data=minimalDelay, group="<=200s") %>%
    addAwesomeMarkers(~lon, ~lat, icon=getDelaysMarkers(bigDelay), popup = ~as.character(delay), label = ~as.character(line), data=bigDelay, group=">200s") %>%
    addLayersControl(
      overlayGroups = c("<=100s", "<=200s", ">200s"),
      options = layersControlOptions(collapsed = FALSE)
    ) %>%
    addFullscreenControl("bottomright")
}
