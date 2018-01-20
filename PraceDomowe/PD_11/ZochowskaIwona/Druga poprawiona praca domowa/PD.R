
library(dplyr)
library(ggplot2)
library(plotrix)

data <- read.csv("usa_00004.csv", header=TRUE, sep=",")
data[data == 9999999] <- NA
data <- data %>% filter(!is.na(INCTOT) & !is.na(INCEARN)) %>%
  select(YEAR, DATANUM, SERIAL, GQ, PERNUM, INCTOT, FTOTINC, INCEARN, POVERTY)
data$INCOME <- pmax(data$FTOTINC, data$INCEARN, na.rm=TRUE)

interval <- 50;
x <- seq(0, 500, interval)
data$Group = findInterval(data$POVERTY, x)
data$YEAR <- factor(data$YEAR)
data$Group <- factor(data$Group)

generateLabels <- function(set){
  lapply(set$Group, function(x){
    xn <- as.numeric(x) - 1
    if(xn == nrow(set) - 1)
      return(paste(">",paste(xn / 2)))
    paste(xn / 2,'-', xn / 2 + 0.5, sep=' ')
  })
  
}

analiza1 <- function(){
  aggragatedIncome <- as.data.frame(data %>% group_by(Group, YEAR) %>%
                                      summarise("max" = max(as.numeric(INCOME)),
                                                "min" = min(as.numeric(INCOME)),
                                                "mean" = mean(as.numeric(INCOME)),
                                                "sum" = sum(as.numeric(INCOME))))
  
  aggragatedIncome2014 <- aggragatedIncome %>% filter(YEAR==2014)
  aggragatedIncome2014$Percantage <- aggragatedIncome2014$sum / sum(aggragatedIncome2014$sum) #* 100
  
  aggragatedIncome2015 <- aggragatedIncome %>% filter(YEAR==2015)
  aggragatedIncome2015$Percantage <- aggragatedIncome2015$sum / sum(aggragatedIncome2015$sum)# * 100
  
  ratioLabel <- generateLabels(aggragatedIncome2015)
  
  dataForPlot <- rbind(aggragatedIncome2014, aggragatedIncome2015)
  
  plot <- ggplot(dataForPlot, aes(x=Group, y =Percantage, fill=YEAR)) +
    geom_bar(stat="identity", position=position_dodge()) + 
    geom_text(aes(label=round(dataForPlot$Percantage, 2)), color="black", position = position_dodge(0.9), size=3.5, vjust=1.6) + 
    scale_fill_brewer(palette="Paired") + 
    ylab("% od wszystkich zarobionych pieniedzy") + xlab("Wspolczynnik dobrobytu")  + 
    scale_x_discrete(labels=ratioLabel) + 
    guides(Group=FALSE)
  
  return(plot);
}

analiza2 <- function(){
  aggragatedIncome <- as.data.frame(data %>% group_by(Group, YEAR) %>%
                                      summarise("max" = max(as.numeric(INCOME)),
                                                "min" = min(as.numeric(INCOME)),
                                                "mean" = mean(as.numeric(INCOME)),
                                                "sum" = sum(as.numeric(INCOME))))
  
  aggragatedIncome2014 <- aggragatedIncome %>% filter(YEAR==2014)
  aggragatedIncome2014$Percantage <- aggragatedIncome2014$sum / sum(aggragatedIncome2014$sum) #* 100
  
  aggragatedIncome2015 <- aggragatedIncome %>% filter(YEAR==2015)
  aggragatedIncome2015$Percantage <- aggragatedIncome2015$sum / sum(aggragatedIncome2015$sum)# * 100
  
  ratioLabel <- generateLabels(aggragatedIncome2015)
  
  dataForPlot <- rbind(aggragatedIncome2014, aggragatedIncome2015)

  
    
  plot <- ggplot(dataForPlot, aes(x=Group, y =Percantage, fill=YEAR)) +
    geom_bar(stat="identity", position=position_dodge()) +  
    scale_fill_brewer(palette="Paired") + 
    ylab("% od wszystkich zarobionych pieniedzy") + xlab("Wspolczynnik dobrobytu")  + 
    scale_x_discrete(labels=ratioLabel) + 
    guides(Group=FALSE) + 
    coord_cartesian(ylim=c(0,0.1))
  
  return(plot);
}

analiza2()

