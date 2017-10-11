library(reshape2)
library(ggplot2)

df <- read.csv2("twd_pd01.csv", fileEncoding="Windows-1250", stringsAsFactors=FALSE)
df.max <- c(3, 6, 9, 5, 3, 6, 7, 7, 4)
names(df)[3:11] <- c("dostępność", "metody logowania",
                     "f. przed logowaniem", 
                     "obs. innych rachunków",
                     "powiadomienia push", "karty płatnicze",
                     "płatności mobilne", "usługi dodatkowe",
                     "kontakt z bankiem")
df <- df[rev(order(df$Łączna.liczba.punktów)),]
df$Bank <- factor(df$Bank, levels = df$Bank)
dfm <- melt(df[,-2], id="Bank")
colnames(dfm)[2:3] <- c("Usługa", "Liczba punktów")

ggplot(dfm, aes(x=Bank, y=Usługa)) +
  geom_tile(aes(fill = `Liczba punktów`)) +
  scale_fill_continuous(high = "#08519c", low = "#c6dbef") +
  ggtitle("Ranking banków - WBK liderem") +
  xlab("Bank (od najwyżej ocenionego)")
