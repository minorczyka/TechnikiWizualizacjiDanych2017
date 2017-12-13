#testowo
library(ggplot2)
library(rsconnect)

rsconnect::setAccountInfo(name='komosinskid',
                          token='83AFCD34C5B0E148E94C492D570FCCAC',
                          secret='8Ml5mq0IAGsWS+lynhN3SmN0hWYDJV2FH77U5Ga/')

rsconnect::deployApp('D:/MATEMATYKA/MAGISTERKA/SMAD/Techniki wizualizacji danych/PD_08/pd08_komosinskid')

# setwd("D:/MATEMATYKA/MAGISTERKA/SMAD/Techniki wizualizacji danych/PD_08/pd08_komosinskid")
# db <- read.csv2("dane_pd08.csv")
# 
# db <- db[order(db$liczba_naborów, decreasing = TRUE), ]
# row.names(db) <- 1:nrow(db)
# 
# positions <- db$lokalna_grupa_dzialania
# 
# ggplot(db, aes(x=lokalna_grupa_dzialania, y=liczba_naborow)) +
#   geom_bar(stat="identity", fill="blue") +
#   geom_text(aes(y=liczba_naborow+0.5, label=liczba_naborow)) +
#   theme(axis.text.x = element_text(angle = 90, hjust = 1)) +
#   scale_x_discrete(limits = positions)
# 
# db
