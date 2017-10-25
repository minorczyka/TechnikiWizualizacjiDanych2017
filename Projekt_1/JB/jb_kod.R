library(ggmap)
library("rvest")
library("httr")
library("jsonlite")
library(ggplot2)


res_suwalki <- GET(url = "https://api.worldweatheronline.com/premium/v1/weather.ashx?key=be239f7b47ca427c80c185023172310&q=Suwalki&format=json&num_of_days=14&cc=no&fx24=no")
res_slubice <- GET(url = "https://api.worldweatheronline.com/premium/v1/weather.ashx?key=be239f7b47ca427c80c185023172310&q=Slubice&format=json&num_of_days=14&cc=no&fx24=no")

dsuw =jsonlite::fromJSON(as.character(res_suwalki))
dslu =jsonlite::fromJSON(as.character(res_slubice))

dw = dsuw$data$weather
dl = dslu$data$weather

dw$sunrise = unlist(lapply(dw$astronomy,function(x){x[1]}))
dw$sunset =  unlist(lapply(dw$astronomy,function(x){x[2]}))
dw$moonrise =unlist(lapply(dw$astronomy,function(x){x[3]}))
dw$moonset = unlist(lapply(dw$astronomy,function(x){x[4]}))

dl$sunrise = unlist(lapply(dl$astronomy,function(x){x[1]}))
dl$sunset =  unlist(lapply(dl$astronomy,function(x){x[2]}))
dl$moonrise =unlist(lapply(dl$astronomy,function(x){x[3]}))
dl$moonset = unlist(lapply(dl$astronomy,function(x){x[4]}))


#merge dfs

dw$city = "Suwa³ki"
dl$city = "S³ubice"

cols = c('date','city','maxtempC','mintempC','totalSnow_cm','sunHour','sunrise','sunset','moonrise','moonset')

df = rbind(dw[,cols],dl[,cols])
df$maxtempC = as.integer(df$maxtempC)
df$mintempC = as.integer(df$mintempC)
df$totalSnow_cm = as.numeric(df$totalSnow_cm)
df$sunHour = as.numeric(df$sunHour)
df$date = as.Date(df$date)

df$sunset = as.POSIXct(strptime(paste(df$date, df$sunset), "%Y-%m-%d %I:%M %p"))
df$sunrise = as.POSIXct(strptime(paste(df$date, df$sunrise), "%Y-%m-%d %I:%M %p"))
df$moonrise = as.POSIXct(strptime(paste(df$date, df$moonrise), "%Y-%m-%d %I:%M %p"))

df$moonset = as.POSIXct(strptime(paste(df$date, df$moonset), "%Y-%m-%d %I:%M %p"))

no_moonset = which(is.na(df$moonset))
if (any(no_moonset>27)){
  nxtvals = no_moonset+1
  nxtvals[which(nxtvals==29)] = 28
  df$moonset = df$moonrise[nxtvals]
} else {
  df$moonset[no_moonset] = df$moonrise[no_moonset+1]
}

dsorted = sort(df$date)
lmin = substr(dsorted[1],6,10)
l1q = substr(dsorted[7],6,10)
lmean = substr(dsorted[14],6,10)
l3q = substr(dsorted[21],6,10)
lmax = substr(dsorted[28],6,10)

datelabs = substr(df$date,6,10)

df$date = as.POSIXct(paste(df$date,"12:00:00"))


df$meantempC = (df$mintempC+df$maxtempC)/2

ymin = min(c(df$mintempC,-1))
ymax = max(df$maxtempC)

rmin = min(c(df$totalSnow_cm,0))
rmax = max(c(df$totalSnow_cm+1,5))

smin = min(c(df$sunHour,0))
smax = max(c(df$sunHour+1,2))

#xboundaries
dsorted = sort(df$date)
dmin = dsorted[1]
d1q = dsorted[7]
dmean = dsorted[14]
d3q = dsorted[21]
dmax = dsorted[28]

g1 = ggplot (df,aes(x=date,y=meantempC)) +
  scale_y_continuous(lim=c(ymin,ymax)) +
  scale_x_datetime(breaks=c(dmin,d1q,dmean,d3q,dmax), labels=c(lmin,l1q,lmean,l3q,lmax))+
  geom_ribbon(aes(x=date,ymin=mintempC,ymax=maxtempC,fill=city),alpha=0.3) +
  geom_line(aes(x=date,y=meantempC,col=city),alpha=1)+
  geom_hline(yintercept=0,linetype=2)+
  scale_color_manual(values=c("red","blue"))+
  scale_fill_manual(values=c("red","blue"))+
  guides(fill=guide_legend(title="Temperature forecast"),col=guide_legend(title="Mean temperature"))+
  ggtitle("Temperature")+
  xlab("Date") + ylab("Temperature (Celsius)")+
  theme(axis.text.x = element_text(angle = 45, hjust = 1))

g2 = ggplot(df,aes(x=date,y=city))+
  geom_segment(aes(x=moonrise,xend=moonset,y=city,yend=city,col="mooncol"), position=position_nudge(x=0,y=-0.02),size=3)+
  geom_segment(aes(x=sunrise,xend=sunset,y=city,yend=city,col="suncool"), position=position_nudge(x=0,y=0.02),size=3)+
  #geom_text(aes(x=date,y=city,label=sunHour),position=position_nudge(x=0,y=0.1))+
  #geom_vline(xintercept=df$date[1],linetype=2,size=0.5)+
  guides(col=guide_legend(title=""))+
  scale_color_manual(values=c("dodgerblue4","gold2"),labels=c("Moon present","Sun present"))+
  scale_x_datetime(breaks=df$date,labels=datelabs)+
  ggtitle("Sun and moon presence") + xlab("Date") + ylab("City")+
  theme(axis.text.x = element_text(angle = 45, hjust = 1))

g3 = ggplot(df,aes(x=date,y=totalSnow_cm,fill=city)) +
  geom_bar(stat="identity",alpha=0.5,position="dodge")+
  scale_x_datetime(breaks=df$date,labels=datelabs)+
  scale_y_continuous(lim=c(rmin,rmax),expand=c(0,0))+
  scale_fill_manual(values=c("red","blue"))+
  ggtitle("Rain forecast") + xlab("Date") + ylab("Rainfall/snowfall (cm)")+
  guides(fill=guide_legend(title="City"))+
  theme(axis.text.x = element_text(angle = 45, hjust = 1))

g4 = ggplot(df,aes(x=date,y=sunHour,fill=city)) +
  geom_bar(stat="identity",alpha=0.5,position="dodge")+
  scale_x_datetime(breaks=df$date,labels=datelabs)+
  scale_y_continuous(lim=c(smin,smax),expand=c(0,0))+
  scale_fill_manual(values=c("red","blue"))+
  ggtitle("Daily hours with sun") + xlab("Date") + ylab("Hours with sun")+
  guides(fill=guide_legend(title="City"))+
  theme(axis.text.x = element_text(angle = 45, hjust = 1))

multiplot <- function(..., plotlist=NULL, file, cols=1, layout=NULL) {
  library(grid)
  
  # Make a list from the ... arguments and plotlist
  plots <- c(list(...), plotlist)
  
  numPlots = length(plots)
  
  # If layout is NULL, then use 'cols' to determine layout
  if (is.null(layout)) {
    # Make the panel
    # ncol: Number of columns of plots
    # nrow: Number of rows needed, calculated from # of cols
    layout <- matrix(seq(1, cols * ceiling(numPlots/cols)),
                     ncol = cols, nrow = ceiling(numPlots/cols))
  }
  
  if (numPlots==1) {
    print(plots[[1]])
    
  } else {
    # Set up the page
    grid.newpage()
    pushViewport(viewport(layout = grid.layout(nrow(layout), ncol(layout))))
    
    # Make each plot, in the correct location
    for (i in 1:numPlots) {
      # Get the i,j matrix positions of the regions that contain this subplot
      matchidx <- as.data.frame(which(layout == i, arr.ind = TRUE))
      
      print(plots[[i]], vp = viewport(layout.pos.row = matchidx$row,
                                      layout.pos.col = matchidx$col))
    }
  }
}

groupplot = multiplot(g1,g2,g3,g4,cols=2)

ggsave("dupa",plot=groupplot,device="png",dpi=666)
getwd()
