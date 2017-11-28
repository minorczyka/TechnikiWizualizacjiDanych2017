
#setwd("E:\\MINI\\SEMESTR 9\\WIZUALIZACJA DANYCH\\PROJEKTY\\PROJEKT1")


testFunction<-function()
{
   "dziala"
}

### READ SHAPE FILE 
library(rgdal)     # R wrapper around GDAL/OGR
library(ggplot2)   # for general plotting
library(ggmap)    # for fortifying shapefiles
library(ggimage)
getShapeFile<-function()
{
shapefile <- readOGR("..\\data\\warszawa-wgs84-epsg4326\\warszawa-wgs84-epsg4326", layer="dzielnice-wgs84",verbose=FALSE)
shapefile_df <- fortify(shapefile)
shapefile_df
}

## READING DATA
library("rvest")
library("httr")
library("jsonlite")



getData <- function(lines) {
  
  token <- "35dbb2ebd27b23cfbec359dbd560adf2d4a5b27b"
  
  data <- GET(url = paste0("https://vavel.mini.pw.edu.pl/api/vehicles/v1/full/?line=", lines), add_headers(Authorization = paste("Token", token)))
  data <- as.data.frame(jsonlite::fromJSON(as.character(data)))
  data_not_stopped<-data[data$status!="STOPPED",]
  data_not_stopped$time_converted<-strptime(data_not_stopped$time, "%Y-%m-%dT%H:%M:%OS")
  data_not_stopped$time_diff<-difftime(Sys.time(),data_not_stopped$time_converted,units="mins")
  data_not_stopped<-data_not_stopped[data_not_stopped$time_diff<30,]
  data_not_stopped
}

### DATA PROCESSING

library("dplyr")
library("nlme")
library("viridis")

checkPointBelongiess<-function(pointlat,pointlon,lat,lon){
  point.in.polygon(point.x = pointlon, point.y = pointlat,lon,lat) 
}

getGroups<-function(shapefile_df,data)
{
  shapefile_df_grouppeed<-shapefile_df %>% group_by(group)
  
  point_group<-rep(0,nrow(data))
  
  for(i in 1:nrow(data))
  {
    
    point_lon<-data[i,]$lon
    point_lat<-data[i,]$lat
    result<-shapefile_df_grouppeed %>% summarise(result=checkPointBelongiess(point_lat,point_lon,lat,long))
    result_df<-data.frame(result)
    if(any(result_df$result)!=0)
    {
    point_group[i]<-result_df[result_df$result!=0,]$group
    }
  }
  point_group
}

getAreaAvgSpeed<-function(data,point_location_group,shapefile_df)
{
  speed_group_df<-data.frame(lon=data$lon, lat=data$lat, speed=data$speed, group=point_location_group)
  speed_groupped_mean_df<-data.frame(speed_group_df %>% group_by(group) %>% summarise(mean_speed=mean(speed)))
  shapefile_df_unclassed<-cbind(shapefile_df,unclassed_group=unclass(shapefile_df$group))
  shapefile_df_unclassed_speed<-left_join(shapefile_df_unclassed,speed_groupped_mean_df,by=c("unclassed_group"="group"))
  shapefile_df_unclassed_speed
}

## VISUALIZATION

plot_map<-function(plotting_data,rest_data,map_google,hospitals)
{
  ggmap(map_google)+
    geom_polygon(data = plotting_data, 
                 aes(x = long, y = lat, group = group, fill=mean_speed),
                 alpha=0.6,
                 color = 'black', size = .5)+
    geom_point(aes(x=lon,y=lat),data=rest_data)+
    ggtitle("Who will be on time in hospital?")+
    scale_fill_viridis()+
    scale_x_continuous(limits=c(20.8,21.3),expand=c(0,0))+
    geom_image(aes(image="..//data//doctor2.png",x=lon,y=lat),data=hospitals)+
    scale_y_continuous(limits =c(52.05,52.4),expand=c(0,0) )
  
  
}


  plot_trams_mean_spreed<-function()
  {
  shapefile_df<-getShapeFile()
  tram_lines<- paste(1:99, collapse = ",")
  data<-getData(tram_lines)
  point_location_group<-getGroups(shapefile_df,data)
  plottig_data<-getAreaAvgSpeed(data,point_location_group,shapefile_df)
  map_google<-get_map(location = 'Warsaw',zoom=10,crop=FALSE)
  hospitals<-read.csv("..\\data\\SzpitaleWarszawa.csv",header=TRUE)
  plot_map(plottig_data,data,map_google,hospitals)
  }
  
 
  