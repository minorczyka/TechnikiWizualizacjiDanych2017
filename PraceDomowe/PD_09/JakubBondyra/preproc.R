#zrodlo danych: http://ec.europa.eu/eurostat/data/database
#w folderze Tables by themes/Transport/Railway transport
#wszystkie 3 pliki tsv

#operacje przeksztalcajace ramki danych

t1 = read.table("ttr00003.tsv",header=T,sep="\t")#total length of railway lines
t2 = read.table("ttr00015.tsv",na.strings=":",header=T,sep="\t")#rail transport (passengers)
t3 = read.table("ttr00006.tsv",header=T,sep="\t")#rail transport (goods)

t1$xcountry = sapply(t1$unit.tra_infr.n_tracks.geo.time, function(r){
  x = strsplit(as.character(r),',')[[1]]
  x[length(x)]
})

t1$unit.tra_infr.n_tracks.geo.time = NULL

for (i in colnames(t1)){
  if (i!="xcountry"){
    t1[,i] = as.numeric(as.character(t1[,i]))
  }
}

t2$xcountry = sapply(t2$unit.tra_cov.geo.time, function(r){
  x = strsplit(as.character(r),',')[[1]]
  x[length(x)]
})

t2$unit.tra_cov.geo.time = NULL

for (i in colnames(t2)){
  if (i!="xcountry"){
    t2[,i] = as.numeric(as.character(t2[,i]))
  }
}

t3$xcountry = sapply(t3$tra_cov.unit.geo.time, function(r){
  x = strsplit(as.character(r),',')[[1]]
  x[length(x)]
})

t3$tra_cov.unit.geo.time = NULL

for (i in colnames(t3)){
  if (i!="xcountry"){
    t3[,i] = as.numeric(as.character(t3[,i]))
  }
}

colnames(t1) = sapply(colnames(t1), function(x)substring(x,2))
colnames(t2) = sapply(colnames(t2), function(x)substring(x,2))
colnames(t3) = sapply(colnames(t3), function(x)substring(x,2))
  
goodnames = intersect(intersect(t1$country,t2$country),t3$country)

t1 = t1[which(t1$country %in% goodnames),]   
t2 = t2[which(t2$country %in% goodnames),]    
t3 = t3[which(t3$country %in% goodnames),]  

t3 = t3[1:30,]

library(reshape2)

t1m = melt(t1,id="country")
t2m = melt(t2,id="country")
t3m = melt(t3,id="country")

yrs = intersect(intersect(t1m$variable,t2m$variable),t3m$variable)

t1m=t1m[which(t1m$variable %in% yrs),]
t2m=t2m[which(t2m$variable %in% yrs),]
t3m=t3m[which(t3m$variable %in% yrs),]

all(t1m$country==t2m$country)
all(t2m$country==t3m$country)
all(as.character(t2m$variable)==as.character(t1m$variable))
all(as.character(t2m$variable)==as.character(t3m$variable))

finaldf = data.frame(country=t1m$country, year=t1m$variable, railway_length=t1m$value,
                     passengers=t2m$value, goods=t3m$value)
sapply(finaldf,class)

write.table(finaldf,"finaldf.tsv",sep="\t", na=":", row.names=F) 
#finaldf to source dla workbooka tableau
