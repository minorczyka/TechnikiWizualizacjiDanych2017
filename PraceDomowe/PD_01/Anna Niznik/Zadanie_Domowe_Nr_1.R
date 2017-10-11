drawFatInCoffee <- function(drinks_expanded){
  ggplot(drinks_expanded, aes(Total.Fat..g., color=Beverage_category)) +
  geom_histogram(binwidth = 0.5, stat="count")+
    theme(axis.text.x = element_blank())+
  xlab("Zawartoœæ t³uszczu")+
  ylab("Czêstoœæ")
}

drawSugarInCoffee <- function(drinks_expanded){
  ggplot(drinks_expanded, aes(Sugars..g., color=Beverage_category)) +
    geom_histogram(binwidth = 0.5, stat="count")+
    xlab("Zawartoœæ cukru")+
    ylab("Czêstoœæ")
}

drawCaffeineInCoffee <- function(drinks_expanded){
  ggplot(drinks_expanded, aes(Caffeine..mg., color=Beverage_category)) +
    geom_histogram(binwidth = 0.5, stat="count")+
    theme(axis.text.x = element_blank())+
    xlab("Zawartoœæ kofeiny")+
    ylab("Czêstoœæ")
}

drawCoffeesNutritionValues <- function(drinks_expanded){
  fat <- drawFatInCoffee(drinks_expanded)
  sugar <- drawSugarInCoffee(drinks_expanded)
  caffeine <- drawCaffeineInCoffee(drinks_expanded)
  
  plot_grid(fat, sugar, caffeine, 
            labels = c("Fat", "Sugar", "Caffeine"),
            ncol = 1, nrow = 3)
}

drawCaloriesVSSugars <- function(drinks_expanded){
  ggplot(drinks_expanded, aes(y = Sugars..g., x =  Calories)) + 
  geom_point() +
  geom_density_2d()+
  ylab("Zawartoœæ cukru")+
  xlab("Iloœæ kalorii")+
  theme_bw()
}

drawNutritionCoffees <- function(drinks_expanded){
  distinct_beverage_categories <- drinks_expanded %>% distinct(Beverage_category) %>% select(Beverage_category)
  drinks_expanded$Id <- distinct_beverage_categories[drinks_expanded$Beverage_category,]
  beverage_category_selected <- drinks_expanded %>% filter(Beverage_category %in% c("Classic Espresso Drinks", "Coffee", "Smoothies", "Signature Espresso Drinks", "Shaken Iced Beverages"))
  beverage_category_selected <- beverage_category_selected %>% filter(Beverage_prep %in% c("Short", "Tall", "Grande", "Venti", "2% Milk", "Soymilk"))
  beverage_category_selected <- beverage_category_selected %>% filter(Vitamin.A....DV. %in% c("0%", "10%", "15%", "20%", "25%", "30%"))

  ggplot(beverage_category_selected, aes(x=Beverage_prep, y=Calories, color=Beverage_category))+
  geom_point(aes(shape=Vitamin.A....DV.))+
  geom_smooth(se=FALSE, method="lm")+
  ylab("Iloœæ kalorii")+
  xlab("Sposób przygotowania")+
  theme_bw()
}