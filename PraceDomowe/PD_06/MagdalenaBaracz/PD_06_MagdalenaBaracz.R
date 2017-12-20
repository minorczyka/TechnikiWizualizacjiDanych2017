library(plotly)

n<-200
no_col <- seq(1,n)
amount <- rep(1,n)
col <- rainbow(n)
df <- data.frame(no_col,amount,col)
p <- plot_ly(df, values = ~amount, type = 'pie' , marker =list(colors=~col),
             hoverinfo = 'text', text = ~col, textinfo = "none") %>%
  layout(title = 'Interactive rainbow color palette',
         xaxis = list(showgrid = FALSE, zeroline = FALSE, showticklabels = FALSE),
         yaxis = list(showgrid = FALSE, zeroline = FALSE, showticklabels = FALSE))
p
htmlwidgets::saveWidget(p, "rainbow_palette.html")
