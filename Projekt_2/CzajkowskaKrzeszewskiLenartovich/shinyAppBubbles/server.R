
library(ggplot2)
library(png)
library(ggExtra)
library(grid)
library(scales)
library(ggthemes)
library(dplyr)
library(plotly)
library(rCharts)
library(highcharter)
library(stringi)

## note: dont change the file , rewriting causes in smaller number of emotions
data <- read.csv("data/filled_emotions.csv", header = TRUE)
timedata <- read.csv("data/chapters_secs.csv", header = TRUE)
maxSceneId <- max(data$sceneId)
fullEmotions <- read.csv("data/emotions.csv", header = TRUE, stringsAsFactors = FALSE)


shinyServer(function(input, output) {
  
  numberOfCharacters<-6
  numberOfCharactersInPage<-6
  
  chooseTbl<-reactive(prepareChooseDataFrame(data,input,numberOfCharacters))
  selectedOptions<-reactive(getSelectedOptions(input,chooseTbl) )
  selectedData<-reactive(getSelectedData(data,selectedOptions()))
  allData<-reactive(getAllData(data,input,numberOfCharacters))

  
  emotionsNames<-reactive({
    if(!input$selectAll)
      {sort(as.character(unique(selectedOptions()$tone)))}
    else 
      {sort(as.character(unique(data$tone)))}
    })
  
  output$sceneStats = renderPlotly({
      
  })
  
  output$bubbleChart <- renderChart2({

    if(input$selectAll)
    {
      data<-allData()
    }
    else
    {
      data<-selectedData()
    } 
    
    if (nrow(data) == 0) {
      # Creates almost empty plot, so no errors are thrown without data
      return(createEmptyHPlot())
    }
    
    #data<-data %>% filter(sceneId<=input$myslider)
    dataForChart <- data %>% filter(val > 0)
    
    dataForChart$time <- sapply(dataForChart$sceneId, getTimeForScene)
    
    constEmotionsNames<-emotionsNames()
    dataForChart$emotionId <- sapply(as.character(dataForChart$toneId), function(x) {which(constEmotionsNames == x)})
    h <- hPlot(emotionId ~ sceneId, group = "person", data = dataForChart, type = "bubble",
               dom = "bubbleChart", size="val")
    h$colors(c(getColorsForPeople(sort(as.character(unique(dataForChart$person)))), 'rgba(223, 83, 83, .5)', 'rgba(119, 152, 191, .5)'))

    h$set(height = 500, width= 800)
    h$yAxis(categories = c("", constEmotionsNames, " "), title = list(text = "Emotion"))
    h$chart(rightAlignYAxis = FALSE)
    h$chart(zoomType = "xy")
    h$title(text = "Leon Proffesional: So many emotions")
    h$xAxis(title = list(text = "Scene no"), min = 0, max = 85)
    h$tooltip(useHTML=TRUE,formatter = "#! function(){
                          
                              return 'Scene no: ' + this.point.x +
                              '<br>Actor: ' + this.series.name +
                              '<br>Emotion: ' + this.series.yAxis.categories[this.y]+
                              '<br>Intensity: ' + this.point.z;
                             
                                  } !#")

    h$plotOptions(bubble = list(cursor = 'pointer', point = list(events = list(click = "#! function(x) { 
                                                                                            var message = {sceneId: x.point.options.x,
                                                                                                           emotionId: x.point.options.y,
                                                                                                           person: x.point.series.name,
                                                                                                           emotions: x.point.series.yAxis.categories}
                                                                                                                                                                                         
                                                                                            console.log(message);
                                                                                            Shiny.onInputChange('myInput',message);} !#"))))
    
    h
  })
  
  getColorsForPeople <- function(peoples) {
    colors <- c("#66c2a5", "#fc8d62", "#8da0cb", "#e78ac3", "#a6d854", "#ffd92f")
    persons <- c("SCENE", "LEON", "MATHILDA", "TONY", "STANSFIELD", "BODYGUARD")
    
    res <- c()
    for (i in 1:(length(peoples))) {
      res <- c(res, colors[which(persons == peoples[i])])
      
    }
    print(res)
    return(res)
  }

  
  observeEvent(input$myInput, {
    message <- input$myInput
    
    if(nchar(message) == 0){
      sceneId = 47;
      toneId = "anger";
      person = "MATHILDA";
      message = list(sceneId=sceneId, person=person, emotions = list("", "anger", ""), emotionId = 1);
    }
  
    print(paste("message:", message))
      
    sceneId <- message$sceneId
    toneId <- message$emotions[[message$emotionId + 1]]
    person <- message$person
      
    m <- paste("scene: ", sceneId, "tone:", toneId, "person:", person)
     

      dialogs <- getContextForDialogue(sceneId, person, toneId, wholeScene = input$wholeScenes)
      #print(dialogs)
      
      result <- "";
      for(i in 1:nrow(dialogs)){
        d <- dialogs[i,]
        result <- paste(result, generateScheme(d$person, d$toneId, d$score, getSceneName(d$sceneId), d$text, person, d$isTitle))
      }
      
      #print(result)
    
    output$citations <- renderText({
      result
    })
    
    sceneId2 <- sceneId
    stats <- data %>% filter(sceneId == sceneId2) %>%
      group_by(toneId) %>%
      summarise(n = sum(val)) %>% data.frame()
    
    print(stats)
    p <- plot_ly(x = ~stats$toneId, y = ~stats$n, type = 'scatter', mode = 'lines', fill = 'tozeroy', fillcolor = 'lightblue') %>%
      layout(xaxis = list(title = 'Emotion'),
             yaxis = list(title = 'Emotion level'),
             title = "Emotion distribution in scene")
    
    output$sceneStats <- renderPlotly({
      p
    })
  })
  
  output$choosingTable = DT::renderDataTable(chooseTbl(), server = TRUE , 
                                  options=list(dom='t' ,pageLength = numberOfCharactersInPage),
                                  selection=list(target="cell",selected=matrix(c(2,2,2,4,3,3,3,5,3,6,4,3,5,3,5,7),byrow=TRUE,ncol=2)))
  output$x4 = renderPrint({
    selected<-selectedOptions()
    if(nrow(selected)>0)
      print(selected)
  })
})

generateScheme <- function(person, emotion, score, scene, text, talker, isTitle){

  titleClass <- ifelse(isTitle, " scene-description ", "")
  score <- round(score, digits = 2)
  emotion <- getEmotionShortName(emotion)
  
  if (person != "SCENE") {
    text <- gsub("\\(", "<span class='director-note'>(", text)
    text <- gsub("\\)", ")</span>", text)
  }
  
  persons <- c("LEON", "MATHILDA", "TONY", "STANSFIELD", "SCENE")
  unknownPersonName <- ifelse(any(person == persons), '', paste0('<div style="white-space: pre-wrap;">', person ,'</div>'))
  
  if(person == "SCENE"){
    mainDiv <- paste0('<div>
                        <div class="row">
                            <div class="col-md-12 rcorners-scene margin-bm-5 margin-top-5 ', titleClass,'">',
                              text,
                           '</div>
                        </div>
                      </div>')
  }else if(person == talker){
    mainDiv <- paste0('<div>
                        <div class="row">
                          <div class="col-md-3">
                          </div>
                          <div class="col-md-7 rcorners margin-5">',
                            unknownPersonName,
                            text,
                         '</div>
                          <div class="col-md-1 person margin-bm-10">
                            <img class="person-image" src="', getImageForPerson(person), '"/>',
                              paste0('<span class="emotion-mention">', ifelse(emotion != "unkn",emotion,""),'</span>'), ' ',
                              paste0('<span class="emotion-mention">', ifelse(emotion != "unkn",score,""),'</span>'),'
                          </div>
                          </div>
                        </div>')
  }else{
  mainDiv <- paste0('<div>
                      <div class="row">

                        <div class="col-md-1 person margin-bm-10">
                          <img class="person-image" src="', getImageForPerson(person), '"/>
                              <div class="emotion-mention">',
                                 paste(ifelse(emotion != "unkn",emotion,""), ifelse(emotion != "unkn",score,"")),
                              '</div>
                        </div>
                        <div class="col-md-7 rcorners margin-lf-30 margin-5">',
                            unknownPersonName,
                            text,
                        '</div>
                        <div class="col-md-2">
                        </div>
                      </div>
                    </div>')
  }
  mainDiv <- stri_replace_all(mainDiv, regex="([A-Z]{3,15}('S|'s| [0-9]){0,1})", replacement='<span class="person-mention"> $1 </span>')
  return(mainDiv)
}

getImageForPerson <- function(person){
  persons <- c("LEON", "MATHILDA", "TONY", "STANSFIELD", "SCENE")
  images <- c("leon.png", "mathilda.png", "tony.png", "stansfield.png", "scene.png")
  
  ind <-  which(persons == person)
  
  if(length(ind) == 0)
    return("scene.png")
  
  return(images[ind])
}

getEmotionShortName <- function(emotionName) {
  emotion <- c("unknown","tentative","analytical","joy","confident","sadness","fear","anger")
  emoShort <- c("unkn", "tent", "analyt", "joy", "conf", "sad", "fear", "anger")
  
  return(emoShort[which(emotion == emotionName)])
}

getCharactorsOrderByFrequency<-function()
{
  dataRaw<-read.csv("data/emotions.csv")
  dataRaw[dataRaw$person=="GIRL","person"]<-"MATHILDA"
  dataRaw %>% group_by(person) %>% summarise(freq=n()) %>% arrange(-freq) %>% data.frame()
}



prepareChooseDataFrame<-function(data,input,numberOfCharacters)
{
  charactersDf<-getCharactorsOrderByFrequency()
  charactersDf<-head(charactersDf,numberOfCharacters)
  characters<-charactersDf$person
  
  emotions<-unique(data$toneId)
  emotions<-emotions[emotions %in% input$chooseType]
  matrixEmotions<-matrix(rep(emotions,each=length(characters)),ncol=length(emotions))
  choosingDf<-data.frame(matrixEmotions)
  choosingDf<-cbind(characters,choosingDf)
  colnames(choosingDf)<-c("character",as.character(emotions))
  choosingDf
}


getSelectedOptions<-function(input,chooseTbl)
{
  s <- input$choosingTable_cells_selected 
  print("s:")
  print(paste("s:",s))
  selectedOptions<-data.frame(person=character(),tone=character(),emotionId=integer())
  if(is.null(s) | nrow(s)==0)
    return(selectedOptions)
  
  for(i in 1:nrow(s))
  {
    selectedOptionsInternal<-data.frame(person=as.character(chooseTbl()[s[i,1],1]), tone=colnames(chooseTbl())[s[i,2]], emotionId=s[i,2])
    selectedOptions<-rbind(selectedOptions,selectedOptionsInternal)
  }
  selectedOptions
}



getSelectedData<-function(data1, selectedOptions)
{
  selectedData<-data.frame(data1)
  selectedData<-selectedData[0,]
  
  if (nrow(selectedOptions) == 0) {
    return(selectedData)
  }

  for(i in 1:nrow(selectedOptions))
  {
    selectedDataInternal<-data1 %>% 
      filter(as.character(person)==as.character(selectedOptions[i,"person"]) &
               as.character(toneId)==as.character(selectedOptions[i,"tone"])) %>%   
      data.frame(stringsAsFactors =F)
    selectedData<-rbind(selectedData,selectedDataInternal)
  }
  selectedData$person_tone<-paste(selectedData$person,selectedData$toneId,sep="_")
  selectedData
}

getAllData<-function(data,input,numberOfCharacters)
{
  emotions<-unique(data$toneId)
  emotions<-emotions[emotions %in% input$chooseType]

  charactersDf<-getCharactorsOrderByFrequency()
  charactersDf<-head(charactersDf,numberOfCharacters)$person
  
  selectedData<-data %>% filter(toneId %in% emotions & person %in% charactersDf )
  selectedData$person_tone<-paste(selectedData$person,selectedData$toneId,sep="_")
  selectedData
}

# Method returns time of start for each scene in Leon Professional (sometimes approx.)
# If scene with given number doesn't exists - returns -1
# Param `inSeconds` (def. FALSE) - when TRUE return second of start of scene (unique between scenes). If false returns minute of scene start.
getTimeForScene <- function(sc, inSeconds = FALSE) {
  tt <- timedata %>% filter(scene == sc)
  if (nrow(tt) == 0) {return(-1)}
  return(ifelse(inSeconds == TRUE, tt[1,]$start, tt[1,]$mins))
}

# Just returns empty (almost) hPlot
createEmptyHPlot <- function() {
  h <- hPlot(x ~ y, data = data.frame(size = c(0), x = c(1), y = c(1)), type = "bubble", dom = "bubbleChart", size = "size")
  h$title(text = "Choose some emotions and characters to know the truth")
  return(h)
}

# Returns all dialogues of person in given scene, sorted decreasing by given emotion
# Param `byValue` declares sorting result by decreasing value. If false data is sorted by time.
getDialogueForScene <- function(sc, per, emotion, byValue = TRUE) {
  
  dd <- fullEmotions %>% filter(sceneId == sc) %>% filter(person == per) %>% filter(sentenceId == 0) %>% filter(toneId == emotion)
  if (nrow(dd) == 0) {
    dd <- fullEmotions %>% filter(sceneId == sc) %>% filter(person == per) %>% filter(toneId == emotion)
  }
  
  if (nrow(dd) == 0) {return("NOT FOUND")}
  if (byValue) {
    return(dd[order(dd$score, decreasing = TRUE),])
  }
  return(dd)
}

# Returns dialogue for whole scene or some part of it.
# sc, per, emotion - searched for data
# context = N - (if wholeScene == FALSE) return title, main message with context from -N to +N messages
# wholeScene - ignores context and returns whole scene
# indexByValue = K - show context for K-th sentence by value of emotion for given person, if not exists returns NULL
getContextForDialogue <- function(sc, per, emotion, context = 3, wholeScene = FALSE, indexByValue = 1) {
  
  allScene <- fullEmotions %>% filter (sentenceId == 0) %>% filter(sceneId == sc)
  
  i <- 1
  while( i < nrow(allScene)) {
    now <- allScene[i,]
    nex <- allScene[i+1,]
    if (now$id == nex$id & now$sentenceId == nex$sentenceId) {
        allScene <- allScene[ifelse(nex$toneId == emotion, c(-i), c(-(i+1))),]
    } else {
      i <- i + 1
    }
  }
  
  foundDialogues <- getDialogueForScene(sc, per, emotion, byValue = TRUE)
  
  print(paste(foundDialogues, sc, per, emotion))
  
  if (indexByValue > nrow(foundDialogues)) {
    return(NULL)
  }
  selected <- foundDialogues[indexByValue,]
  selectedRow <- which(allScene$id == selected$id & allScene$sentenceId == selected$sentenceId)
  
  print(selectedRow)
  if (wholeScene || length(selectedRow) == 0) {
    return(allScene)
  }
  
  allScene$isTitle <- c(TRUE, rep(FALSE, nrow(allScene) - 1))
  allScene$selected <- allScene$person == per & allScene$toneId == emotion
  allScene$mainSentence <- c(rep(FALSE, selectedRow-1), TRUE, rep(FALSE, nrow(allScene) - selectedRow))
  

  selectedFrom <- max(2, selectedRow - context)
  selectedTo <- min(nrow(allScene), selectedRow + context)
  
  return(allScene[c(1, seq(selectedFrom, selectedTo, 1)),])
}

# Returns scene name (location) from script
getSceneName <- function(sc) {
  dd <- fullEmotions %>% filter(sceneId == sc) %>% filter(person == "SCENE")
  
  return(dd[1,]$text)
}

