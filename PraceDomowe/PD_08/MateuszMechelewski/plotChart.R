getChart <- function(df, selectedDistrict) {
  sW <- unique(df$wojewodztwo)[selectedDistrict]
  df$colours <- df$wojewodztwo == sW
  df$sizes <- ifelse(df$wojewodztwo == sW, 1, 0.1)
  df$sizes <- factor(df$sizes)
  
  labels <- character(nrow(df))
  for(i in seq(12*(selectedDistrict-1)+1, 12*selectedDistrict)) {
    labels[i] <- df$wojewodztwo[i]
  }
  
  ggplot(data = df, aes(x=czas, y=wartosc, group=wojewodztwo, colour=colours,
                        label=czas, label2=wartosc)) +
    geom_line(aes(size=sizes)) +
    geom_dl(aes(label = labels), method = list(dl.combine("last.points"), cex = 1, hjust=0.7, vjust=-0.5)) +
    theme_bw() +
    theme(legend.position="none") +
    ggtitle("Liczba wydanych po raz pierwszy praw jazdy w 2016 roku w podziale na województwa") +
    xlab("") +
    ylab("") +
    scale_color_manual(values=c("gray", "red")) +
    scale_size_manual(values=c(0.5, 1.5))
}
