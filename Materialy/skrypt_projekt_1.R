#
# Dane online o położeniu autobusów i tramwajów
# do projektu 1
# 

library("rvest")
library("httr")
library("jsonlite")

linie <- "10,17,33"
token2 <- "35dbb2ebd27b23cfbec359dbd560adf2d4a5b27b"

res <- GET(url = paste0("https://vavel.mini.pw.edu.pl/api/vehicles/v1/full/?line=", linie),
           add_headers(Authorization = paste("Token", token2)))
jsonlite::fromJSON(as.character(res))
