house = readRDS("house.rds")
source("GraphCreation.R")
library(shiny)
library(shinyjs)
library(ggplot2)
library(tm)
library(ggplot2)
library(wordcloud)
library(RWeka)
library(reshape2)
library(SnowballC)

seasons = unique(house$Season)


season <- 1
person <- "cameron"

createCloud <- function(season, person)
{
  dirName <- paste0("./processedData/", season, "/", person)
  if(!file.exists(dirName))
  {
    par(mar = c(0,0,0,0))
    plot(c(0, 1), c(0, 1), ann = F, bty = 'n', type = 'n', xaxt = 'n', yaxt = 'n')
    text(x = 0.5, y = 0.5, paste("This character was not present in that season"), 
         cex = 1.6, col = "black")
    print(dirName)
    return()
    
  }
  houseDir <- DirSource(dirName , encoding = "UTF-8")
  
  # word cloud
  pal <- brewer.pal(8,"Blues")
  pal <- pal[-(1:3)]
  set.seed(1234)
  corpus.ngrams <- VCorpus(houseDir)
  
  
  
  corpus.ngrams <- tm_map(corpus.ngrams,removeWords,c(stopwords(), "get","can","gonna", "\"\","))
  
  tdm.unigram <- TermDocumentMatrix(corpus.ngrams, control = list(stopwords = TRUE,
                                                                  removePunctuation = TRUE, 
                                                                  removeNumbers = TRUE, 
                                                                  removeSparseTerms=TRUE 
  ))
  freq <-  head(sort(rowSums(as.matrix(tdm.unigram)), decreasing = T),25)
  freq <- freq[names(freq) != "\"\"," ]
  freq <- freq[names(freq) != "\"," ]
  freq <- freq[names(freq) != "\"" ]
  word.cloud <- wordcloud(words=names(freq),scale=c(8,2),freq=freq,random.order=F, colors=pal)
  
}


sezony <- c(1,2,3,4,5,6,7, 8)
bohaterowie <- data.frame()
addToBohaterowie <- function(x)
{
  path <- paste0("./processedData/", x,"/People.txt")
  seasonBohaterowie <- read.table(path, stringsAsFactors = F)
  tempBohaterowie <- rbind(seasonBohaterowie, bohaterowie)
  tempBohaterowie <- unique (tempBohaterowie)
  bohaterowie <<- tempBohaterowie
}
lapply(sezony, addToBohaterowie)
names(bohaterowie) <- "bohater"
ui <- shinyUI(fluidPage(
    useShinyjs(),
    titlePanel("Rozmowy bohaterów serialu \"House\""),
    sidebarLayout(
      sidebarPanel(
        selectizeInput("seasons", "Wybierz sezon", seasons, selected = "1", multiple = FALSE,
                       options = NULL),
        
          selectInput(inputId = "wybranyBohater", 
                      label = "Wybierz postać",
                      choices = bohaterowie,
                      selected = "cameron")
        
       
      ),
      mainPanel(
        tabsetPanel( id = "panel",
          tabPanel("Kto z kim rozmawia?", forceNetworkOutput("force", height = 900)),
          tabPanel("Kto o czym mówi?", plotOutput("trend",width = "70%", height = "750px"))
        )
         
    )
    
  
    )
  )
)

server <- shinyServer(function(input, output) {


  
  
  output$force <- renderForceNetwork({
    if (length(input$seasons) > 0) {
    df = filter(house, Season %in% input$seasons)
    return(createRelationPlot(df))
    }
  })
  
  output$trend = renderPlot({
    createCloud(input$seasons,input$wybranyBohater)                     #(input$wybranySezon , input$wybranyBohater)
  })
  
})

shinyApp(ui, server)
