########
# pd02 Dariusz Komosinski
library(scales)
library(dplyr)
library(archivist)
library(gridExtra)
library(rworldmap)
library(ggthemes)
library(latticeExtra)
library(lattice)
library(ggplot2)

library(ggplot2)

setwd("D:/MATEMATYKA/MAGISTERKA/SMAD/Techniki wizualizacji danych/pd02")
db<-read.csv2("pd02-ceny mieszkan.csv")

ggplot(db, aes(x = reorder(miasto, -srednia.cena), y = srednia.cena, label=srednia.cena)) +
  geom_bar(aes(fill=metraz.mkw.), stat = 'identity', position=position_dodge()) +
  geom_text(aes(group=metraz.mkw.), position = position_dodge(0.9), vjust=1.5, size=3) +
  scale_fill_brewer(palette=3) +
  theme_minimal() +
  geom_point(stat = "summary", fun.y="mean", shape=35)+
  theme(axis.text.x = element_text(angle = 90, hjust = 1))+
  labs(x="miasto",
       title="Ceny wynajmu mieszkan w Polsce - pazdziernik 2017",
       subtitle="Miasta uporzadkowano wzgledem sredniej ceny zaznaczonej kropka")



         
