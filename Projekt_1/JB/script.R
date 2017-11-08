library(ggmap)
library(ggplot2)
library(rgdal)
library(jsonlite)
library(dplyr)
library(httr)
library(gridExtra)

df = fromJSON("dzielnice.geojson")

map = get_googlemap(center = "Warsaw", zoom=10, style = 'feature:all|element:labels|visibility:off')
#dlugosci punktow, nazwy dzielnic
df.lengths = data.frame(name=df$features$properties$name,count=unlist(lapply(df$features$geometry$coordinates,function(x){dim(x)[3]})))
df.lengths = df.lengths[-1,]
#ramka danych
mpts = matrix(nrow=0,ncol=2)
for (i in 2:length(df$features$geometry$coordinates)){
  mpts = rbind(mpts,df$features$geometry$coordinates[[i]][1,1,,])
}
group_col = unname(unlist(apply(df.lengths, 1, function (x){rep(x[1],x[2])})))

pts = data.frame(group=group_col,lat=mpts[,2],lon=mpts[,1])
pts$lat = as.numeric(pts$lat)
pts$lon = as.numeric(pts$lon)

#wyznaczanie srednich w dzielnicach
ms = pts %>% group_by(group) %>% summarise(mlon=((max(lon)+min(lon))/2),mlat=((max(lat)+min(lat))/2))
dms = apply(ms,1,function(x){
  url1 = paste(paste(paste(paste("https://api.worldweatheronline.com/premium/v1/weather.ashx?key=be239f7b47ca427c80c185023172310&q=",x[3],sep=""),",",sep=""),x[2],sep=""),"&format=json&num_of_days=0",sep="")
  res = GET(url=url1)
  jsonlite::fromJSON(as.character(res))
})

ldms= lapply(dms,function(x){
  c(x$data$current_condition$FeelsLikeC,x$data$current_condition$precipMM,x$data$current_condition$windspeedKmph,
    x$data$current_condition$winddir16Point)
})

tmpd = matrix(ncol=4,nrow=0)
for (i in (1:length(ldms))){
  tmpd = rbind(tmpd,ldms[[i]])
}

weatherdata = data.frame(tmpd,ms$group)
colnames(weatherdata) = c("Temperature","Precipitation","Windspeed","Winddir","group")

pts = dplyr::inner_join(pts,weatherdata,by="group")
pts$Precipitation = as.numeric(pts$Precipitation)

lbldata = data.frame(temp=weatherdata$Temperature,wind=weatherdata$Windspeed,dir=weatherdata$Winddir,
                     group=weatherdata$group,lon=ms$mlon,lat=ms$mlat)

lbldata=filter(lbldata,group %in% c("Śródmieście"))



token2 <- "35dbb2ebd27b23cfbec359dbd560adf2d4a5b27b"
linie = paste0(c(1:40,100:199,500:540),collapse=",")
tramres <- GET(url = paste0("https://vavel.mini.pw.edu.pl/api/vehicles/v1/short/?line=", linie),
                   add_headers(Authorization = paste("Token", token2)))
trams = jsonlite::fromJSON(as.character(tramres))
#outliers
trams = filter(trams,delay<1000)
trams[trams$delay<0,which(colnames(trams)=="delay")] = 0
trams[trams$delay>=240,which(colnames(trams)=="delay")] = 240
rmin = 0
rmax = max(pts$Precipitation,2.0)

#wizualizacja pasuje do viewportu pdf 11x13 cali opcja landscape
#w celu ladnego plotowania radze pozmieniac czcionki i limity x,y
ggmap(map) + geom_polygon(aes(x=lon,y=lat,group=group,col=Precipitation),size=2,data=pts,alpha=0.2,fill=NA)+
  geom_text(hjust=0,aes(x=21.14,y=52.354,label=paste0(temp,"°C, wiatr ",wind," km/h, kierunek ",dir,"\nStan na ",dms[[1]]$data$weather$date," ",dms[[1]]$data$current_condition$observation_time, " GMT")),
            data=lbldata,size=7)+
  stat_summary_2d(data=trams,aes(x=lon,y=lat,z=delay),fun=function(x)mean(x),alpha=0.4,bins=80)+
  #stat_density2d(data=trams,aes(x = lon, y = lat, fill = ..level.., alpha=delay), 
  #               size = 0.01, bins = 16, geom = "polygon") +
  #scale_fill_gradient(low="skyblue", high="darkblue") +
  scale_alpha(range = c(0,0.3), guide=FALSE) +
  scale_color_distiller(limits=c(rmin,rmax),palette="PuBuGn",direction=1,
                        guide=guide_legend(title="Opady (mm)       "))+
  scale_fill_distiller(limits=c(0,240),palette="PuRd",direction=1,guide=guide_legend(title="Opoznienia (min)"),
                       breaks=c(0,60,120,180,240),
                       labels=c("0","1","2","3","4+"))+
  scale_x_continuous(limits = c(20.83, 21.37), expand = c(0, 0)) +
  scale_y_continuous(limits = c(52.09, 52.38), expand = c(0, 0)) +
  xlab("") + ylab("") + ggtitle("Obecne warunki w Warszawie")  +
  theme(legend.position = c(0.91, 0.4), legend.text=element_text(size=16),
        plot.title = element_text(size=26),
        axis.title.x=element_blank(),
        axis.text.x=element_blank(),
        axis.ticks.x=element_blank(),
        axis.title.y=element_blank(),
        axis.text.y=element_blank(),
        axis.ticks.y=element_blank())


