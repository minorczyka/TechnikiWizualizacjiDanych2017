#######################
###### Styl mapy ######
#######################
library("RJSONIO")
library("ggmap")
library("magrittr")
style <- '[
{
  "stylers": [
  { "saturation": -100 },
  { "gamma": 0.5 }
  ]
}
]'
style_list <- fromJSON(style, asText = TRUE)

create_style_string <- function(style_list) {
  style_string <- ""
  for (i in 1:length(style_list)) {
    if ("featureType" %in% names(style_list[[i]])) {
      style_string <- paste0(style_string, "feature:",
        style_list[[i]]$featureType, "|")
    }
    elements <- style_list[[i]]$stylers
    a <- lapply(elements, function(x) paste0(names(x), ":", x)) %>%
      unlist() %>%
      paste0(collapse = "|")
    style_string <- paste0(style_string, a)
    if (i < length(style_list)) {
      style_string <- paste0(style_string, "&style=")
    }
  }
  # google wants 0xff0000 not #ff0000
  style_string <- gsub("#", "0x", style_string)
  return(style_string)
}

style_string <- create_style_string(style_list)



#######################
##### Rysuje mapy #####
#######################

###############################
# @param dane_c - wynik działania funkcji dane_coord
# @param lon longitude środka mapy
# @param lat latitude środka mapy

mapa_kolor_ciagly <- function(dane_c, lon, lat) {
  ggmap(get_googlemap(center = c(lon = lon, lat = lat), zoom = 13, style = style_string)) +
    geom_segment(
      data = dane_c, 
      aes(
        x = previousStopLon, y = previousStopLat,
        xend = nextStopLon, yend = nextStopLat,
        color = Mean
      ),
      lwd = 1.5,
      arrow = arrow(ends = "last", length = unit(0.3, "cm"))
    ) +
    scale_color_gradient2(
      name = "Op\u00F3\u017Anienie", midpoint = 15, 
      low = "#ffffff", mid = "#f3624c", high = "#f03b20", 
      limits = c(-5, 54)
    ) +
    theme(
      axis.line = element_blank(),
      axis.text.x = element_blank(),
      axis.text.y = element_blank(),
      axis.ticks = element_blank(),
      axis.title.x = element_blank(),
      axis.title.y = element_blank()
    )
}



###############################
