library(ggplot2)
library(dplyr)
library(reshape2)
library(plotly)
library(shiny)
library(xlsx)



unemployedDf<-read.xlsx("./Data/unemployedWarsaw.xlsx",1,encoding = "UTF-8")

shinyServer(function(input, output) {
  
  dataInput<-reactive(getFilteredData(input))
  output$plot=renderPlotly({
  
         if(input$plotType=="dzielnice")
          {
           
           makeSummarisedPlot(dataInput())
          }
         else
         {
           makeBoxPlot(dataInput())
          }
              
    
    })
  output$table<-renderDataTable(dataInput(),
                                options = list(
                                  pageLength = 5,
                                    dom='tp'         )
                                )
  
})
getFilteredData<-function(input)
{
  melted_unemployedDf<-melt(unemployedDf)
  colnames(melted_unemployedDf)<-c("Dzielnica","Typ","Liczba")
  df<-melted_unemployedDf %>%filter(Dzielnica %in% input$sectorMultiple)
  
  data_series<-character()
  if("Wszyscy" %in% input$options)
  {
    data_series<-c(data_series,"All")
  }
  if("Kobiety" %in% input$options)
  {
    data_series<-c(data_series,"Women")
  }
  if("Mężczyźni" %in% input$options)
  {
    data_series<-c(data_series,"Men")
  }
  
  df<-df %>% filter(Typ %in% data_series)
  df
}

makeSummarisedPlot<-function(df)
{
 
  static_plot<-ggplot(df,aes(x=Dzielnica,y=Liczba,fill=Typ))+geom_bar(stat="identity",position = "dodge",alpha=0.7)+
    theme(axis.text.x = element_text(angle=45))+
    labs(x="",y="",fill="Typ",title="Liczba według dzielnic ")+
    scale_fill_manual(values=c("#74a9cf","#fec44f","#78c679"))
  ggplotly(static_plot)  %>% layout(margin = list(b=100,l=40))
}

makeBoxPlot<-function(df)
{
  static_boxplot<-ggplot(df,aes(x=Typ,y=Liczba,fill=Typ))+
                  geom_boxplot(alpha=0.5)+
                  geom_jitter(alpha=0.4)+
                  scale_fill_manual(values=c("#74a9cf","#fec44f","#78c679"))+
                  labs(x="",y="",fill="Typ",title="Liczba według typu ")+
                  guides(fill=FALSE)
  ggplotly(static_boxplot)  %>% layout(margin = list(b=100,l=40))
}