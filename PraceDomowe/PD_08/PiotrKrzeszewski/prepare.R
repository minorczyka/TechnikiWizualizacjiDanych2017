# prepare.R


# Data sources:

# https://coinmarketcap.com/currencies/bitcoin/historical-data/
# https://coinmarketcap.com/currencies/litecoin/historical-data/
# https://coinmarketcap.com/currencies/ethereum/historical-data/
# https://coinmarketcap.com/currencies/bitconnect/historical-data/


currencies <- read.csv("ccs.csv", header = TRUE, stringsAsFactors = FALSE)
currencies$Currency <- factor(currencies$Currency)
currencies$Date <- as.Date(currencies$Date, "%b %d %Y")
save(currencies, file="currencies.rda")

shiny::runApp(".")


rsconnect::setAccountInfo(name='franiis', 
                          token='<secret>', 
                          secret='<secret>')

library(rsconnect)
rsconnect::deployApp('.')
