library(ggplot2)
library(ggmap)  
library(dplyr)
library(grid)
library(gridExtra)
library(Cairo)
source("99_funkcje_pomocnicze.R")
load("dane_wizualizacja.rda")


map_goc <- mapa_kolor_ciagly(dane_coord_rano_goc, lon = 21.045462, lat = 52.230440)
map_wl <- mapa_kolor_ciagly(dane_coord_rano_wl, lon = 20.983546, lat = 52.202131)


dane_godziny_wl <- filter(dane_godziny, dzielnica == "wlochy")
dane_godziny_goc <- filter(dane_godziny, dzielnica == "goclaw")

lin_wl<- ggplot(dane_godziny_wl, aes(x = Hour, y = opoznienie)) + 
  geom_line(aes(colour = grupa),size=2) +
  theme_bw() + 
  theme(legend.position="bottom") +
  scale_y_continuous(limits = c(0, 24)) +
  scale_x_continuous(breaks = 5:15) +
  ggtitle("Włochy") +
  xlab("Godzina") +
  ylab("Średnie Opóźnienie w minutach") + 
  scale_color_manual(values = c("#66c2a5", "#fc8d62", "#8da0cb", "#e78ac3"), 
                                name="Trasa",
                                breaks=c("do-metra-wl", "grojecka", "jerozolimskie", "zwirki"),
                                labels=c("do metra", "Grójecka", "Al. Jerozolimskie", "Żwirki i Wigury"))
  

lin_goc <- ggplot(dane_godziny_goc, aes(x = Hour, y = opoznienie)) + 
  geom_line(aes(colour = grupa),size=2) +
  theme_bw() + 
  theme(legend.position="bottom") +
  scale_y_continuous(limits = c(0, 24))+
  scale_x_continuous(breaks = 5:15) +
  ggtitle("Gocław") +
  xlab("Godzina") +
  ylab("Średnie Opóźnienie w minutach") + 
  scale_color_manual(values = c("#66c2a5", "#fc8d62", "#8da0cb", "#e78ac3"), 
                     name="Trasa",
                     breaks=c("do-metra", "tram-goc", "z-goclaw", "z-praga"),
                     labels=c("do metra", "tramwaj z Gocławia", "Z Gocławia", "Z Pragi"))

title <- textGrob("Gocław czy Włochy? Gdzie zamieszkać, żeby rano pospać dłużej?", gp=gpar(fontsize=15,font=8))

lay <- rbind(c(1,1),
             c(2,3),
             c(4,5))

viz <- grid.arrange(title, lin_goc, lin_wl ,map_goc, map_wl,  
             layout_matrix = lay,
             heights=unit(c(1,4,4), "in"))

ggsave("Gosiewska_Kmita_Komosinski.pdf", viz, height = 9, width = 14.4, units = "in", device=cairo_pdf)


