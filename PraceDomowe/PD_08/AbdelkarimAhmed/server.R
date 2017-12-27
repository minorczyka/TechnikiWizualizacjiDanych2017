library(shiny)
if (!require("shinyjs"))
	install.packages("shinyjs")
library(shinyjs)
library(dplyr)
library(ggplot2)

shinyServer(function(input, output) {
  observe({
  	toggleElement(id = "arch", condition = input$source == "steam" && input$scope != "arch_only")
  })
	observe({
		toggleElement(id = "scope", condition = input$source == "steam")
	})
	observe({
		toggleElement(id = "scope_unity", condition = input$source == "unity")
	})
	is_arch = function() {
		input$source == "steam" && (input$arch || input$scope == "arch_only") 
	}
  output$myPlot = renderPlot({
  	if (input$source == "unity")
  		scope = input$scope_unity
  	else
  		scope = input$scope
  	data = read.csv(paste("os_", input$source ,".txt", sep=""), sep = ";")
  	data = as.data.frame(data %>% filter(Rodzina %in% input$systems))
  	if (!is_arch()) {
  		data = as.data.frame(data %>% group_by(Wersja, Rodzina) %>% summarise(Procent = sum(Procent)))
  	} 
  	else {
  		data$Architektura = relevel(data$Architektura, "x64")
  	}
  	if (scope == "arch_only") {
  		data = data %>% group_by(Architektura) %>% summarise(Procent = sum(Procent))
  		plt = ggplot(data, aes(Architektura, weight = Procent, fill = Architektura)) + guides(fill=F)
  	}
    else if (scope == "family") {
    	if (is_arch())
    		grouped = data %>% group_by(Rodzina, Architektura)
    	else
    		grouped = data %>% group_by(Rodzina)
    	data = grouped %>% summarise(Procent = sum(Procent))
    	plt = ggplot(data, aes(Rodzina, weight = Procent, fill = Rodzina)) + guides(fill=F)
    }
   	else {
   		plt = ggplot(data, aes(reorder(Wersja, as.numeric(Rodzina)), weight = Procent, fill = Rodzina))
   		plt = plt + xlab("Rodzina") 
   	}
  	plt = plt + ylab("Udział w rynku [%]") + theme(axis.text.x=element_text(angle=90,hjust=1))
  	if (is_arch() && scope != "arch_only")
  		plt = plt + geom_bar(aes(alpha = Architektura)) + scale_alpha_discrete(range = c(1, 0.5))
  	else
  		plt = plt + geom_bar()
  	
    plt
  })
  
})
