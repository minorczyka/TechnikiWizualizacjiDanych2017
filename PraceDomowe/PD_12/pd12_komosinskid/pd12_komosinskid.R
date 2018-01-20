#pd 12 poprawa pracy domowej
library(ggplot2)
library(dplyr)
library(ggthemes)
library(cowplot)
library(plotly)

setwd("D:\\MATEMATYKA\\MAGISTERKA\\SMAD\\Techniki wizualizacji danych\\PD_12\\pd12_komosinskid")

drinks_expanded <- as.data.frame(read.csv("starbucks_drinkMenu_expanded.csv", header = TRUE, fileEncoding = "UTF-8", dec=".", stringsAsFactors = FALSE))
drinks_nutrition <- as.data.frame(read.csv("starbucks-menu-nutrition-drinks.csv", header = TRUE, fileEncoding = "UTF-8"))

drinks_expanded$Total.Fat..g. <- as.numeric(drinks_expanded$Total.Fat..g.)


g1 <- ggplot(drinks_expanded, aes(x=Beverage_category, y=Total.Fat..g.)) +
  geom_boxplot() +
  #geom_dotplot(aes(fill=Beverage_prep), binaxis = "y", stackdir="center", dotsize = 0.5)+
  theme(axis.text.x = element_text(angle = 45, hjust = 1))+
  ylab("Zawartość tłuszczu")
ggplotly(g1)

g2 <- ggplot(drinks_expanded, aes(x=Beverage_category, y=Sugars..g.)) +
  geom_boxplot() +
  #geom_dotplot(aes(fill=Beverage_prep), binaxis = "y", stackdir="center", dotsize = 0.5)+
  theme(axis.text.x = element_text(angle = 45, hjust = 1))+
  ylab("Zawartość cukru")
ggplotly(g2)

`%nin%` = Negate(`%in%`)
drinks_expanded2 <- drinks_expanded %>%
  filter(Caffeine..mg. %nin% c("varies", "Varies"))
drinks_expanded2$Caffeine..mg. <- as.numeric(drinks_expanded2$Caffeine..mg.)

g3 <- ggplot(drinks_expanded2, aes(x=Beverage_category, y=Caffeine..mg.)) +
  geom_boxplot() +
  #geom_dotplot(aes(fill=Beverage_prep), binaxis = "y", stackdir="center", dotsize = 0.5)+
  theme(axis.text.x = element_text(angle = 45, hjust = 1))+
  ylab("Zawartość kofeiny")
ggplotly(g3)

plot_grid(g1, g2, g3, 
          labels = c("Fat", "Sugar", "Caffeine"),
          ncol = 1, nrow = 3)


#####################################
distinct_beverage_categories <- drinks_expanded %>% distinct(Beverage_category) %>% select(Beverage_category)
drinks_expanded$Id <- distinct_beverage_categories[drinks_expanded$Beverage_category,]
beverage_category_selected <- drinks_expanded %>% filter(Beverage_category %in% c("Classic Espresso Drinks", "Coffee", "Smoothies", "Signature Espresso Drinks", "Shaken Iced Beverages"))
beverage_category_selected <- beverage_category_selected %>% filter(Beverage_prep %in% c("Short", "Tall", "Grande", "Venti", "2% Milk", "Soymilk"))
beverage_category_selected <- beverage_category_selected %>% filter(Vitamin.A....DV. %in% c("0%", "10%", "15%", "20%", "25%", "30%"))

g <- ggplot(beverage_category_selected, aes(x=Beverage_prep, y=Calories))+
  geom_dotplot(aes(color=Beverage_category, fill=Beverage_category), binwidth = 20, binaxis = "y", stackdir = "center", dotsize = 1)
g

##############
g <- ggplot(drinks_expanded, aes(y = Sugars..g., x =  Calories)) + 
  geom_point() +
  geom_smooth(method=lm, se=FALSE) +
  ylab("Zawartość cukru")+
  xlab("Ilość kalorii")+
  theme_bw()
ggplotly(g)
