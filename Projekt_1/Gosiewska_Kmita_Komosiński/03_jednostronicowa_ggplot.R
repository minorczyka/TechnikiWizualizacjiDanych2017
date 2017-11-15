library(ggplot2)
library(ggmap)  
library(dplyr)
library(grid)
library(gridExtra)
library(Cairo)
library(ggforce)
library(sqldf)

#setwd("C:\\Alicja\\R\\Techniki Wizualizacji\\Techniki_Wizualizacji_Projekt1\\faza2")
setwd("C:\\Users\\Kamil\\Desktop\\GITHUB\\WizualizacjaDanych\\PROJEKT_01\\24_10_01\\Techniki_Wizualizacji_Projekt1\\faza2")

load("dane/dzielnice_przystanki.rda")
load("dane/danet_new.rda")



############# WYKRESY ########################


dane_godziny <- danet_new %>%
  group_by(grupa, Hour, dzielnica) %>%
  summarize(opoznienie = mean(delay, na.rm = TRUE))

dane_godziny_wl <- filter(dane_godziny, dzielnica == "wlochy")
dane_godziny_goc <- filter(dane_godziny, dzielnica == "goclaw")

lin_wl <- ggplot(dane_godziny_wl, aes(x = Hour, y = opoznienie)) + 
  geom_line(aes(colour = grupa),size=2) +
  theme_bw() + 
  theme(legend.position="bottom") +
  scale_y_continuous(limits = c(0, 20)) +
  scale_x_continuous(limits = c(6, 21), breaks = 6:21) +
  ggtitle("Trasy z Włoch do Centrum") +
  xlab("Godzina") +
  ylab("Średnie opóźnienie [min]") + 
  scale_color_manual(values = c("do-metra-wl"="#00ba38", "grojecka"="#fc8d62", "jerozolimskie"="#F0464E", "zwirki"="#e78ac3"), 
                     name="Trasa",
                     breaks=c("do-metra-wl", "grojecka", "jerozolimskie", "zwirki"),
                     labels=c("do metra", "Grójecka", "Al. Jerozolimskie", "Żwirki i Wigury"))


lin_goc <- ggplot(dane_godziny_goc, aes(x = Hour, y = opoznienie)) + 
  geom_line(aes(colour = grupa),size=2) +
  theme_bw() + 
  theme(legend.position="bottom") +
  scale_y_continuous(limits = c(0, 20))+
  scale_x_continuous(limits = c(6, 21), breaks = 6:21) +
  ggtitle("Trasy z Gocławia do Centrum") +
  xlab("Godzina") +
  ylab("Średnie opóźnienie [min]") + 
  scale_color_manual(values = c("do-metra" = "#1B85F6", "tram-goc"="#10C1AE", "z-goclaw"="#EB25C7","z-praga"="#4000FF"), 
                     name="Trasa",
                     breaks=c("do-metra", "tram-goc", "z-goclaw", "z-praga"),
                     labels=c("do metra", "tramwaj z Gocławia", "Z Gocławia", "Z Pragi"))




########################### MAPY ####################################


######## GOCLAW

locgoc = c(21.01, 52.21, 21.123, 52.25)
mapagoctemp <- ggmap(get_map(location = locgoc, source = "stamen", maptype = "toner-lite"))


punktyg_raw <- read.csv("przystanki_goc.txt", header=T,stringsAsFactors = FALSE,
                       encoding="UTF-8")

punktyg_01 <- sqldf('select t1.*, t2.nextStopLat, t2.nextStopLon
                   from punktyg_raw as t1
                   left join danet_new as t2
                   on t1.Klucz = t2.nextStop')

punktyg_02 <- unique(punktyg_01)


punktyg_02[!duplicated(punktyg_02[,c("Nazwa","Klucz","Grupa")]),] %>%
  select(Grupa, nextStopLon, nextStopLat) -> punktyg

mapagoc <- mapagoctemp +
  geom_point(data=punktyg, aes(x=nextStopLon, y=nextStopLat, color=Grupa), 
             position=position_dodge(width=0.005), lwd = 4) +
  theme(
    axis.line = element_blank(),
    axis.text.x = element_blank(),
    axis.text.y = element_blank(),
    axis.ticks = element_blank(),
    axis.title.x = element_blank(),
    axis.title.y = element_blank(),
    legend.position ="none"
  ) +
  scale_color_manual(values = c("metro" = "#1B85F6", "tram"="#10C1AE", "goclaw"="#EB25C7","praga"="#4000FF"))+
  #geom_point(aes(x=21.093,y=52.224), lwd=40,alpha=0.1)+
  geom_point(aes(x=21.046,y=52.24), lwd=10, alpha=0.1)+
  geom_text(aes(x=21.10, y=52.224), size=9, label="Gocław")+
  geom_text(aes(x=21.046,y=52.242), size = 5, label = "Metro Stadion")+
  geom_segment(aes(x=21.0565, y=52.23893, xend=21.06945, yend=52.227), size = 2, alpha=0.15) +
  geom_segment(aes(x=21.06945, y=52.227, xend=21.09172, yend=52.227), size = 2, alpha=0.15) +
  geom_text(aes(x=21.08, y=52.229), size=4, label="nowy tramwaj")


locgoc = c(21.01, 52.21, 21.123, 52.25)
######## WLOCHY


locwl = c(20.885, 52.167, 21.06, 52.24)
# -0.073
mapawltemp <- ggmap(get_map(location = locwl, source = "stamen", maptype = "toner-lite"))


punktyw_raw <- read.csv("przystanki_wl.txt", header=T,stringsAsFactors = FALSE,
                       encoding="UTF-8")


punktyw_01 <- sqldf('select t1.*, t2.nextStopLat, t2.nextStopLon
from punktyw_raw as t1
left join danet_new as t2
on t1.Klucz = t2.nextStop')

punktyw_02 <- unique(punktyw_01)

punktyw_02[!duplicated(punktyw_02[,c("Nazwa","Klucz","Grupa")]),] %>%
  select(Grupa, nextStopLon, nextStopLat) -> punktyw



mapawl <- mapawltemp +
  geom_point(data=punktyw, aes(x=nextStopLon, y=nextStopLat, color=Grupa), 
             position=position_dodge(width=0.004), lwd = 4) +
  theme(
    axis.line = element_blank(),
    axis.text.x = element_blank(),
    axis.text.y = element_blank(),
    axis.ticks = element_blank(),
    axis.title.x = element_blank(),
    axis.title.y = element_blank(),
    legend.position ="none"
  ) +
  scale_color_manual(values = c("do metra"="#00ba38", "Grójecka"="#fc8d62", "Al. Jerozolimskie"="#F0464E", "Żwirki i Wigury"="#e78ac3")) +
  #geom_point(aes(x=20.94,y=52.19), lwd=30, alpha=0.1) +
  #annotate("text", x=20.94, y=52.19, label = "Włochy")
  geom_text(aes(x=20.93, y=52.188), label = "Włochy", size = 9)

################## UPORZADKOWANIE ##################################

title <- textGrob("Dwie sypialnie Warszawy: w którą potrzeba pilniej zainwestować?", gp=gpar(fontsize=15,font=8))

lay <- rbind(c(1,1,1),
             c(3,NA,2),
             c(5,NA,4))

viz <- grid.arrange(title, lin_goc, lin_wl ,mapagoc , mapawl,
                    layout_matrix = lay,
                    heights=unit(c(1, 3.5, 4.5), "in"),
                    widths = c(5,0.5,5))

ggsave("Gosiewska_Kmita_Komosiński_alt.pdf", viz, height = 9, width = 14.4, units = "in", device=cairo_pdf)
