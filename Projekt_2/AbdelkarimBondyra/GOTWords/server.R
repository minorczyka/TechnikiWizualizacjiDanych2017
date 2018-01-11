library(dplyr)
library(wordcloud)
library(ggplot2)


data = read.table("data.txt",sep=",",header=T,quote="")
data$word = tolower(as.character(gsub("[^A-Za-z']", "", gsub("â€™", "'", data$word))))
write.csv(character(0), "history.txt", row.names = F)
write.csv("TYRION", "character.txt", row.names = F)

shinyServer(function(input, output) {
	getNextWord = function(applyPreviousInput=T) {
		renderUI({
			character = input$character
			nextword = input$nextword
			history = as.character(read.table("history.txt",header=T)[,1])
			lastWord = history[length(history)]
			if (applyPreviousInput && !is.null(input$nextword) && nchar(input$nextword) > 0 && length(history) > 0 && !(input$nextword) %in% history)
				lastWord = input$nextword
			if (length(lastWord) == 0)
				lastWord = ""
			words = get_words(data = data, charname = input$character, ordered = input$ordered, prev_words = history) 
			index = which(words$word == lastWord)
			if (length(index) > 0)
				words = words[-index,]
			finalwords = c(lastWord, as.character(words$word))
			names(finalwords) = finalwords
			names(finalwords)[-which(finalwords == lastWord)] = paste(words$word, " (", words$n, ")", sep="")
			selectInput("nextword", "Wybierz słowo:", finalwords, selected = lastWord)
		})
	}
	
	readHistory = function() {
		as.character(read.table("history.txt",header=T)[,1])
	}
	
	doPrevious = function() {
		history = readHistory()
		history = head(history, length(history) - 1)
		write.csv(as.data.frame(history), "history.txt", row.names = F)
		output$nextword = getNextWord(F)
	}
	
	doReset = function() {
		write.csv(character(0), "history.txt", row.names = F)
		output$nextword = getNextWord()
	}
	
	observeEvent(input$previous, {doPrevious()})
	observeEvent(input$ordered, {doReset()})
	observeEvent(input$reset, {doReset()})
	observeEvent(input$character, {doReset()})
  
  #R data processing
  get_words = function (data, charname, ordered, prev_words=character(0)){
    name_words = data %>% filter(name==charname)
    if (length(prev_words) > 0) {
    	if (!ordered) {
	    	good_sentences = name_words %>% distinct(sentence_id)
	    	for (i in 1:length(prev_words)) {
	    		good_sentences = name_words %>% filter(word==prev_words[i]) %>% filter(sentence_id %in% good_sentences$sentence_id) %>% distinct(sentence_id)
	    		name_words = name_words %>% filter(sentence_id %in% good_sentences$sentence_id)
	    	}
    	}
    	else {
    		good_sentences = name_words %>% distinct(sentence_id)
    		good_sentences[,"min_id"] = rep(-1, length.out = nrow(good_sentences))
    		for (i in 1:length(prev_words)) {
    			good_sentences = name_words %>% 
    				filter(word==prev_words[i]) %>% 
    				filter(sentence_id %in% good_sentences$sentence_id) %>% 
    				inner_join(good_sentences, by = "sentence_id") %>%
    				filter(order_id > min_id) %>% 
    				group_by(sentence_id, word, min_id) %>% 
    				filter(order_id == min(order_id)) %>% 
    				ungroup() %>% 
    				select(sentence_id, order_id) %>% 
    				rename(min_id = order_id)
    			name_words = name_words %>% inner_join(good_sentences, by = "sentence_id") %>% filter(order_id > min_id) %>% select(name, sentence_id, order_id, word)
    		}
    	}
    }
    topwords = name_words %>% 
    	filter(!(word %in% prev_words)) %>% 
    	group_by(word) %>% summarise(n=n(), minid=min(order_id)) %>% 
    	filter(n >= input$mincount) %>% arrange(desc(n), minid, as.character(word)) %>% 
    	select(word, n) %>%
    	as.data.frame
    return (topwords)
  }
  output$cloud <- renderPlot({
  	history = readHistory()
  	lastWord = history[length(history)]
  	if (length(lastWord) == 0)
  		lastWord = ""
  	if (!is.null(input$nextword) && nchar(input$nextword) > 0 && input$nextword != lastWord && !(input$nextword %in% history)) {
  		history[length(history) + 1] = input$nextword 
  		write.csv(as.data.frame(history), "history.txt", row.names = F)
  		lastWord = input$nextword
  	}
  	if (length(history) > 0) {
  		char = isolate(input$character)
  		ordering = isolate(input$ordered)
  	}
  	else {
  		char = input$character
  		ordering = input$ordered
  	}
  	words = get_words(data = data, charname = char, ordered = ordering, prev_words = history) 
  	if (length(words) > 0) {
  		maxwords = input$wordcount
  		if (input$graphtype == "wordcloud")
	  		return(wordcloud(words$word, words$n, scale = c(10*input$dimension[1]/2560,0.5) #maksymalny rozmiar slowa zalezny od szerokosci okna
	  																		 , random.color=F, colors=c("skyblue","dodgerblue","dodgerblue2","midnightblue"), min.freq = 0, max.words = maxwords))
  		else {
  				words = words[1:maxwords,]
  				words$word = factor(words$word, levels = words$word[order(words$n, decreasing = T)])
  				return(ggplot(data = words, aes(word, n)) + 
  							 	geom_bar(stat="identity", aes(fill=n)) +
  							 	geom_text(aes(label=n), position=position_dodge(width=0.9), vjust=-0.25, color="black") + 
  							 	scale_fill_gradient2(high="midnightblue",low="aliceblue",mid="dodgerblue2") +
  							 	ylab("Liczba wystąpień") +
  							 	theme(panel.grid.major = element_blank(), panel.grid.minor = element_blank(),
  							 				panel.background = element_blank(), axis.line = element_blank(),
  							 				axis.ticks.x = element_blank(),
  							 				axis.text.x = element_text(angle = 90, hjust = 1, vjust = 0.5, face="bold", size=20), 
  							 				axis.title.x = element_blank()))
  		}
  	}
  	else {
  		return(h1("Brak dalszych słów!"))
  	}
  })
  output$wordhistory = renderUI({
  	character = input$character
  	word = input$nextword
  	history = readHistory()
  	if (!any(history == input$nextword))
  		history = c(history, input$nextword)
  	wordHistoryText = paste(history, collapse = ifelse(input$ordered, " -> ", ", "))
  	h4(paste("Wybrane słowa:", wordHistoryText))
  })
  output$nextword = getNextWord()
})