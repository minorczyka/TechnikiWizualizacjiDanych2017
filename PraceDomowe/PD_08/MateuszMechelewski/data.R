getData <- function() {
  data <- read.csv("data.csv", sep="|", check.names=FALSE, stringsAsFactors=FALSE)

  colnames(data)[1] <- "Województwo"

  df <- data.frame(wojewodztwo=character(0), czas=character(0), wartosc=numeric(0), stringsAsFactors=FALSE)
  count <- 1
  for(i in 1:nrow(data))
  {
    for(j in 2:ncol(data))
    {
      df[count,] <- c(data$Województwo[i], colnames(data)[j], data[i,j])
      count <- count+1
    }
  }
  df$wartosc <- as.numeric(df$wartosc)
  df[df$wojewodztwo== unique(df$wojewodztwo)[1], "wojewodztwo"] <- "Dolnośląskie"
  df[df$wojewodztwo== unique(df$wojewodztwo)[5], "wojewodztwo"] <- "Łódzkie"
  return(df)
}