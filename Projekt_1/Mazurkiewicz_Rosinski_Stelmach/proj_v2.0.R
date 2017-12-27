library(rvest)
library(httr)
library(jsonlite)
library(ggplot2)
library(ggmap)
library(maps)
library(mapdata)
library(dplyr)
library(cowplot)

GetAllVehicles <- function()
{
  tram <- data.frame(line = factor(c(1,2,3,4,6,7,9,10,11,13,14,15,17,18,20,22,23,24,25,26,27,28,31,33,35)))
  bus <- data.frame(line = factor(c(102,103,104,105,107,108,109,110,111,112,114,115,116,117,118,119,120,121,
                                    122,123,124,125,126,127,128,129,131,132,133,134,135,136,138,139,140,141,
                                    142,143,145,146,147,148,149,151,152,153,154,155,156,157,158,159,160,161,
                                    162,163,164,165,166,167,168,169,170,171,172,173,174,175,176,177,178,179,
                                    180,181,182,183,184,185,186,187,188,189,190,191,192,193,194,195,196,197,
                                    198,199,201,202,203,204,205,206,207,208,209,211,212,213,214,217,218,219,
                                    221,222,225,227,240,245,256,262,300,303,304,305,306,311,314,317,318,320,
                                    323,326,331,332,334,338,340,345,365,379,397,401,402,409,411,412,414,500,
                                    501,502,503,504,507,509,511,512,514,516,517,518,519,520,521,522,523,525,
                                    527)))
  machine <- rep("bus", length(bus$line))
  bus <- cbind(bus, machine)
  machine <- rep("tram", length(tram$line))
  tram <- cbind(tram, machine)
  lines <- rbind(tram, bus)
  
  token2 <- "35dbb2ebd27b23cfbec359dbd560adf2d4a5b27b"
  linie <- "1,2,3,4,6,7,9,10,11,13,14,15,17,18,20,22,23,24,25,26,27,28,31,33,35,102,103,104,105,107,108,109,110,111,112,114,115,116,117,118,119,120,121,122,123,124,125,126,127,128,129,131,132,133,134,135,136,138,139,140,141,142,143,145,146,147,148,149,151,152,153,154,155,156,157,158,159,160,161,162,163,164,165,166,167,168,169,170,171,172,173,174,175,176,177,178,179,180,181,182,183,184,185,186,187,188,189,190,191,192,193,194,195,196,197,198,199,201,202,203,204,205,206,207,208,209,211,212,213,214,217,218,219,221,222,225,227,240,245,256,262,300,303,304,305,306,311,314,317,318,320,323,326,331,332,334,338,340,345,365,379,397,401,402,409,411,412,414,500,501,502,503,504,507,509,511,512,514,516,517,518,519,520,521,522,523,525,527"
  res <- GET(url = paste0("https://vavel.mini.pw.edu.pl/api/vehicles/v1/full/?line=", linie),
             add_headers(Authorization = paste("Token", token2)))
  res <- content(res, as="text")
  res <- jsonlite::fromJSON(as.character(res))
  
  res <- res %>%
    mutate(time = as.POSIXct(time,format="%Y-%m-%dT%H:%M:%S")) %>%
    filter(difftime(Sys.time(), time, units="hours") < 1) %>%
    mutate(delay = delay/60) %>%
    filter(delay <= 15, delay >= -5, line != "NA") %>%
    inner_join(lines) %>%
    mutate(opozniony = ifelse(delay >= 1.5, 'Opoznienie', 'Punktualnie'))
  
  return(res)
}

PlotMyPlot <- function(bars, mapp, box, height, width){
  if(3 * height > width){
    box <- box + theme_gray()
    bars <- bars + theme_gray()
    col1 <- plot_grid(box, bars, ncol = 1)
    p<-plot_grid(mapp, col1, ncol=2)
    title <- ggdraw() + draw_label(paste("Wola - którędy uciec przed remontowym kataklizmem", paste("Dane pobrano: ", Sys.time()), sep = '\n'), fontface='bold')
    plot_grid(title, p, ncol=1, rel_heights=c(0.1, 1))
  }
  else {
    box <- box + theme_gray()
    bars <- bars + theme_gray()
    row2 <- plot_grid(box, bars, labels=c('A', 'B'))
    row1 <- plot_grid(mapp, labels=c('C'))
    plot_grid(row1, row2, ncol=1)
  }
}

FindLinesOrder <- function(lines_all, lines_delayed){
  vehicle_no <- lines_all %>%
    group_by(line) %>%
    count() %>%
    arrange( desc(n)) %>%
    select(line)
  
  delayed_no <- lines_delayed %>%
    group_by(line) %>%
    count() %>%
    arrange( desc(n)) %>%
    select(line)
  
  orderd <- rbind(delayed_no, vehicle_no) %>%
    distinct(line)
  
  return(orderd$line)
}

#przygotowanie danych
all_vehicles <- GetAllVehicles()
lines <- c('10', '11', '13', '23', '24', '109', '154', '171', '190')

lines_all <- all_vehicles%>%
  filter(line %in% lines)
lines_delayed <- lines_all %>%
  filter(opozniony == "Opoznienie")

ordered <- FindLinesOrder(lines_all, lines_delayed)

lines_all$line <- factor(lines_all$line, levels = ordered)

map_spread <- lines_all %>%
  summarise(max(lon), min(lon), max(lat), min(lat))
height <- map_spread$`max(lon)` - map_spread$`min(lon)`
width <- map_spread$`max(lat)` - map_spread$`min(lat)`

all_vehicles <- all_vehicles %>%
  filter((lon > map_spread$`min(lon)`) | (lon < map_spread$`max(lon)`) | (lat > map_spread$`min(lat)`) | (lat < map_spread$`max(lat)`))


#wykresy
box <- ggplot(lines_all, aes(x = line, y = delay, color = line)) +
  geom_boxplot(fill = "gray", outlier.shape = NA) +
  geom_jitter(position = position_jitter(width = 0.4)) +
  geom_rug(color = "black") +
  facet_wrap(~machine, ncol = 2, scales = "free_x") +
  xlab('Linia') +
  ylab('Opoznienie[min]') +
  ggtitle('Rozklad opoznien')

bars <- ggplot(lines_all, aes(x = line)) +
  geom_bar(aes(fill = opozniony)) +
  scale_fill_brewer(palette = 'Set1') +
  xlab('Linia') +
  ylab('Ilosc pojazdow') +
  ggtitle('Jaki odsetek pojazdow jest opoznionych?')

mapp <- qmplot(data = lines_all, lon, lat, zoom = 13) +
  stat_density2d(data = all_vehicles, aes(x=lon, y=lat, fill=..level..), alpha = 0.1, geom = "polygon", show.legend = FALSE) +
  geom_point(data = lines_delayed, aes(x=lon, y=lat, size = delay, color = line)) +
  scale_fill_gradient(name = paste("zagęszczenie","pojazdów", sep = '\n'), low = "gray", high = "brown")+
  scale_size_continuous(name = "opóżnienie") + 
  scale_color_discrete(name = "linie") + 
  ggtitle('Gdzie sa opoznienia?')

PlotMyPlot(bars, mapp, box, height, width)
