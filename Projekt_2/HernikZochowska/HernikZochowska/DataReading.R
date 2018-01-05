library("stringi")
library("stringr")

house <- data.frame()
problems <- data.frame()
str(house)

fixNames = function(df)
{
  df$Person = sapply(df$Person, function(x) str_replace_all(x,"[^[:graph:]]", " "))
  df$Person = sapply(df$Person, tolower)
  df$Person = sapply(df$Person, trimws)
  df$Person = gsub("forman|eric foreman", "foreman", df$Person)
  df$Person = gsub("greg house", "house", df$Person)
  df$Person = gsub("chris taub", "taub", df$Person)
  df$Person = gsub("james wilson", "wilson", df$Person)
  df$Person = gsub("lisa cuddy", "cuddy", df$Person)
  df$Person = gsub("amber volakis", "amber", df$Person)
  df$Person = gsub("lawrence kutner", "kutner", df$Person)
  df$Person = gsub("robert chase", "chase", df$Person)
  df$Person = gsub("\"thirteen\"|13", "thirteen", df$Person)
  df$Person = gsub("lawrence kutner", "kutner", df$Person)
  return(df)
}

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
  dataTable = fixNames(dataTable)
  
  house <<- rbind(house, dataTable)
}


result <- lapply(list.files("data", recursive=TRUE), processFile)
saveRDS(house, file="house.rds")

install.packages('rsconnect')


