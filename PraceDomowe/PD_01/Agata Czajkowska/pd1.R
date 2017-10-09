## WIELKOSC MIASTA A PROCENT OSOB MIESZKAJACYCH Z RODZICAMI
setwd("E:\\MINI\\SEMESTR 9\\WIZUALIZACJA DANYCH\\PRACE DOMOWE\\PD1\\mlodziez")

city_data<-read.csv("city_type.csv",header=TRUE)
city_data[city_data$Percent==1,]$Percent<-11
View(city_data)

ggplot(city_data,aes(x=City.type,y=Percent,color=Gender))+
  geom_smooth(se=FALSE,method = "lm",color="black",linetype="dashed")+
  geom_point(size=3.5)+
  geom_smooth(se=FALSE,span=0.4)+
  geom_text(aes(label=Percent),color="black",hjust=2,vjust=1.2)+
  ggtitle("Percent of single Poles living with their paerents  depending on their home town size")+
  scale_x_continuous(breaks=c(1, 2, 3, 4, 5), 
                       labels=c("Village", "City < 20 \nthousand", 
                                "city <20,100) \nthousand", "city <100,500) \nthousand", "city >500 \nthousand"))+
  xlab("Type of the city")
 

###jobs
jobs_data<-read.csv("jobs2.csv",header=TRUE)
View(jobs_data)

ggplot(jobs_data,aes(x=factor(AgeRange,levels=c("18-24", "25-34", "35-44", " 45 and more")),
                     y=factor(Job,levels=c("Students","Employed","Unemployed","Pensioners","Unemployed for other reasons"))))+
 geom_tile(aes(fill=Percent))+ 
  scale_fill_gradientn(
                       colours=c("white","orange","darkorange")
                      )+
  geom_text(aes(label = Percent))+
  theme(axis.title.y =element_text() ,plot.title = element_text(hjust =0.5))+
  xlab("Age range")+
  ylab("Job")+
  ggtitle("Percent of single Poles living with their paerents  depending  on their belongigness to social group")
  

## financial dependence
financial_data<-read.csv("financial_dependence.csv",header=TRUE)
View(financial_data)
  ggplot(financial_data,aes(x=factor(Financial.type,levels=c("Completly independent","Partialy independent","Dependent")),
                            y=Percent,color=Financial.type))+
  geom_boxplot(aes(fill=Financial.type),alpha=0.35,width=0.5)+
  geom_point(aes(shape=Job.type),size=5,stroke=1.2)+
  geom_text(aes(label=Percent),color="black",hjust=2)+
  xlab("Financial independence type")+
  ggtitle("Financial independence of single young Poles depending on belongigness to social group")
