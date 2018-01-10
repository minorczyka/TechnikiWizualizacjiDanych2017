setwd("C:/Users/Matt/Desktop/Wizualizacja/New folder")

words<-scan("LotR-sub-1.txt", sep=",", what="character", quote = "")


words_count<-(table(words))


key_words<-c("FRODO", "SAM", "GANDALF", "ARAGORN", "BOROMIR", "GIMLI", "LEGOLAS", "MERRY", "PIPPIN", "BILBO", "RING", 
     "MORDOR", "ELVES", "RIVENDELL", "MORIA", "SAURON", "SARUMAN", "ELROND", "DARKNESS")

count<-rep(0, length(key_words))
names(count)<-key_words


for(i in 1:length(words))
{
  for(j in 1:length(key_words))
  {
    if(words[i]==key_words[j])
    {
      count[j]<-count[j]+1
    }
  }
}

if (!require("pacman")) install.packages("pacman")
pacman::p_load(jpeg, png, ggplot2, grid, neuropsychology)

imgage <- jpeg::readJPEG("ring.jpg")

count<-sort(count, decreasing = TRUE)

fr<-data.frame(names(count), count)


fr$names.count. <-factor(fr$names.count., 
                       levels = names(count))


p <-ggplot(fr, aes(names.count., count))
p + ggtitle("Key words count") + annotation_custom(rasterGrob(imgage, 
                               width = unit(1,"npc"), 
                               height = unit(1,"npc")), 
                    -Inf, Inf, -Inf, Inf) +geom_bar(stat = "identity", fill = "#FFFFFF", alpha = 0.5, width=0.5, position = position_dodge(width=0.5)) + geom_text(aes(label=names.count.), size=3, vjust=-0.5,colour="#FFFFFF") +
  theme(axis.title.x=element_blank(),
        axis.text.x=element_blank(),
        axis.ticks.x=element_blank())

