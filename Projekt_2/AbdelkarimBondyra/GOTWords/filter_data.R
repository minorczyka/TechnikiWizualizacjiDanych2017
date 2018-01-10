#filter out pronouns and prepositions
#lists of unwanted words:
badwords = read.table("badwords.txt",col.names=F)
data = read.table("data-all.txt",sep=",",header=T,quote="")

badwords = tolower(badwords$FALSE.)
lower_words = tolower(data$word)

badinds = which(lower_words %in% badwords)

data2 = data[-badinds,]
data2$word = lower_words[-badinds]

write.table(data2, "data.txt",sep=",",quote=F)