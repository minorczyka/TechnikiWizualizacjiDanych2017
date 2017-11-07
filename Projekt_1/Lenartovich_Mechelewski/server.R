library(shiny)
library(DT)
library(leaflet)

source("delaysMap.R")
source("speedsMap.R")
source("districtsMap.R")
source("tramsOnNextStop.R")

getDateTimeNow <- function() {
  final <- as.POSIXlt(Sys.time(), tz="Europe/Warsaw", format='%d.%m.%Y %H:%M:%S')
  final <- stri_sub(final,from=1, length=19)
  final
}

function(input, output, session) {
  withProgress(message = 'Pobieranie danych', value = 0, {
    n <- 5
    data <- getData()
    incProgress(2/n, detail = "Renderowanie")
    output$delaysMap <- renderLeaflet(getDelaysMap(data))
    incProgress(1/n, detail = "Renderowanie")
    output$speedsMap <- renderLeaflet(getSpeedsMap(data))
    incProgress(1/n, detail = "Renderowanie")
    output$districtsMap <- renderLeaflet(getDistrictsMap(data))
    incProgress(1/n, detail = "Renderowanie")
    output$stopTrams <- DT::renderDataTable({ getTramsForNextStop(data, input$nextStop) })
    output$currentTime <- renderText(paste("Aktualny stan na ", getDateTimeNow(), ".", sep=""))
  })
}