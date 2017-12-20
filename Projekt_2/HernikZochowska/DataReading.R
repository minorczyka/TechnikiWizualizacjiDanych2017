library("stringi")

house <- data.frame()
problems <- data.frame()
listOfEpisodes <- 1:24
str(house)


convertToLine <- function (x, nrOfEpisode, nrOfSeason)
{
  splittedLine <- stri_split_fixed(x, ":", n = 2)
  statement <- unlist(splittedLine)
  statement[1] <- gsub(" \\(continues\\)", "", statement[1])
  if (length(statement) != 2)
  { 
    print(statement)
    problems <<- rbind(problems, cbind(statement, nrOfEpisode, nrOfSeason))
    return()
  }
  if(substring(statement[2],1,1) == " ")
  {
      statement[2] <- substring(statement[2], 2)
  }
  cbind(statement[1], statement[2], nrOfEpisode, nrOfSeason)
}

processFile <- function(file)
{
  res = regmatches(file, regexec("(.*)/(.*)\\.txt", file))
  season = res[[1]][2]
  episode = res[[1]][3]
  full_name = paste0("data/", file)
  data <- readLines(full_name, encoding = "UTF-8")
  
  dataNotEmpty <- data[data[] != ""]
  statements <- dataNotEmpty[substring(dataNotEmpty[], 1, 1) != "["]
  
  lines <- lapply(statements, convertToLine, episode, season)
  dataTable <-  do.call(rbind.data.frame, lines)
  names(dataTable) <- c("Person", "Statement", "Episode", "Season")
  dataTable[,2] <- as.character(dataTable[,2])
  
  house <<- rbind(house, dataTable)
}

result <- lapply(list.files("data", recursive=TRUE), processFile)
