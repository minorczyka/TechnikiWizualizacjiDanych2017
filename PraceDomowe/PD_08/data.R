getData <- function(){
data <- read.csv("temperatures.csv", sep=",", check.names=FALSE, stringsAsFactors=FALSE)
return(data)
}

