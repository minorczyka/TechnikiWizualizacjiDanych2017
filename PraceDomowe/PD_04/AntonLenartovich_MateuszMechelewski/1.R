dane <- read.csv("CompleteDataset.csv", header=TRUE, sep=",", encoding = "UTF-8")
View(dane)

colnames <- c("Name", "Overall", "Acceleration", "Ball control", "Balance", "Dribbling", "Shot power", "Jumping", "Free kick accuracy")
colsToTransform <- c("Acceleration", "Aggression", "Agility", "Balance", "Ball.control", "Composure", "Crossing", "Curve", "Dribbling", "Finishing", "Free.kick.accuracy",
                     "GK.diving", "GK.handling", "GK.kicking", "GK.positioning", "GK.reflexes", "Heading.accuracy", "Interceptions", "Jumping", "Long.passing", "Long.shots",
                     "Marking", "Penalties", "Positioning", "Reactions", "Short.passing", "Shot.power", "Sliding.tackle", "Standing.tackle","Sprint.speed", "Stamina", "Strength", "Vision", "Volleys")

clubs <- c("FC Barcelona", "FC Bayern Munich", "Legia Warszawa", "Chelsea", 'CSKA Moscow')
colnames <- c("Name", "Overall", "Acceleration", "Ball control", "Balance", "Dribbling", "Shot power", "Jumping", "Free kick accuracy", "Strength", "Sprint speed")
origColnames <- c("Name", "Overall", "Acceleration", "Ball.control", "Balance", "Dribbling", "Shot.power", "Jumping", "Free.kick.accuracy", "Strength", "Sprint.speed")

for(i in 1:length(colsToTransform)){
  dane[,colsToTransform[i]] <-as.numeric(substr(dane[,colsToTransform[i]],1,3))
}


library(d3radarR)
library(dplyr) 
library(sqldf)
library(ggplot2)
library(reshape2)
library(ggthemes)
library(gridExtra)

meanGrouped <- as.data.frame(dane %>% 
                               group_by(Club) %>% 
                               summarise(overall = mean(Overall)/100,
                                         accelaration = mean(Acceleration, na.rm = TRUE) / 100,
                                         ballcontrol = mean(Ball.control, na.rm = TRUE) /100,
                                         balance = mean(Balance, na.rm=TRUE) / 100,
                                         dribbling = mean(Dribbling, na.rm=TRUE) / 100,
                                         shotpower = mean(Shot.power, na.rm=TRUE) / 100,
                                         jumping = mean(Jumping, na.rm=TRUE) / 100,
                                         freekickaccuracy = mean(Free.kick.accuracy, na.rm=TRUE)/100,
                                         strength = mean(Strength, na.rm=TRUE) / 100,
                                         sprintspeed = mean(Sprint.speed, na.rm=TRUE) / 100) %>% 
                               arrange(desc(overall)) %>%
                               filter(Club %in% clubs))

colnames(meanGrouped) <- colnames

pom <- function(values){
  valuesList <- list(0);
  for(i in 1:length(values)){
    valuesList[[i+1]] <- list(axis=names(values[i]), value=values[[i]])
  }
  valuesList[[1]] <- NULL
  return(valuesList)
} 

result <- apply(meanGrouped, 1, FUN = function(row) {
  list(key=row[[1]], values=pom(row[-1]))
})

radar1 <- d3radar(result)



leadersGrouped <-  sqldf('select * from dane 
                         where ID in 
                         (select ID from dane
                         group by Club
                         order by max(Overall) DESC)
                         and Club in ("FC Barcelona", "FC Bayern Munich", "Legia Warszawa", "Chelsea", "CSKA Moscow")') %>%
  select(c(origColnames, "Photo"))

colnames(leadersGrouped) <-colnames

for(i in 2:ncol(leadersGrouped)){
  leadersGrouped[,i] <- leadersGrouped[,i] / 100
}


result2 <- apply(leadersGrouped, 1, FUN = function(row) {
  list(key=row[[1]], values=pom(row[-1]))
})
radar2 <- d3radar(result2)




leadersGrouped2 <- leadersGrouped
for(i in 2:ncol(leadersGrouped2)){
  leadersGrouped2[,i] <- leadersGrouped2[,i] * 100
}
leadersGrouped2 <- melt(leadersGrouped, id.vars = "Name")
leadersGrouped2$variable <- factor(leadersGrouped2$variable)
leadersGrouped2$Name <- factor(leadersGrouped2$Name, levels=leadersGrouped$Name[order(leadersGrouped$Overall)])

ggplot(leadersGrouped2, aes(x = variable, y = value, fill = Name)) + 
  geom_bar(stat = "identity", position = position_dodge()) +
  scale_fill_brewer(palette="Set1") +
  xlab("") + 
  ylab("") + 
  theme_gdocs()+
  theme(axis.text.x = element_text(angle=35, hjust=1))

ggplot(leadersGrouped2) +
  geom_tile(aes(x = variable, y = Name, fill = value)) +
  scale_fill_distiller(palette="Spectral") + 
  geom_text(aes(x=variable, y= Name, label=value))+
  xlab("") +
  ylab("")

