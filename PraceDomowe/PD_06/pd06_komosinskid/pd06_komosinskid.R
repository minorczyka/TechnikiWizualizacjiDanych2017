# pd06
#mapa kolorow
library(ggplot2)
library(plotly)
library(shiny)

v <- seq(from=0, to=255, by=51)
db <- expand.grid(v,v,v)
names(db) <- c("r", "g", "b")
db$kolor <- rgb(db$r,db$g,db$b, maxColorValue = 255)

p <- plot_ly(data=db, x=~r, y=~g, z=~b, text=~kolor, marker=list(color=~kolor))
p

