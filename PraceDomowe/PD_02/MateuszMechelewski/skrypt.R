data <- read.csv("dane_obrobione2.csv", sep=";", check.names=FALSE, stringsAsFactors=TRUE)

ggplot(data, aes(Obywatelstwo, ProcentOdrzucen, fill=PowodOdrzucenia)) +
  geom_bar(stat = "identity", position="stack") +
  geom_text(aes(y = ProcentOdrzucen,label=ifelse(ProcentOdrzucen>0.05, paste(round(ProcentOdrzucen*100,0),"%",sep=""), "")), size = 3, position=position_stack(vjust=0.5)) +
  labs(x="", y = "", title = "Rozkład powodów odmowy wjazdu cudzoziemcom", subtitle="na granicy zewnętrznej UE w roku 2016") +
  scale_y_continuous(labels = scales::percent) +
  scale_fill_manual("Powód odmowy",values=c("#ffffcc","#a1dab4", "#41b6c4", "#225ea8"))