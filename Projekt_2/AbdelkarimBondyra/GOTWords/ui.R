library(dplyr)
if (!require("shinyjs"))
	install.packages("shinyjs")
library(shinyjs)

data = read.table("data.txt",sep=",",header=T,quote="")
characters = as.character(as.data.frame(data %>% count(name, sort = T))[1:9,]$name)

shinyUI(fluidPage(
	useShinyjs(),
  headerPanel("Co mówią postaci w Grze o Tron?"),
  sidebarPanel(
  	tags$head(tags$script('var dimension = [0, 0];
                                $(document).on("shiny:connected", function(e) {
                                    dimension[0] = window.innerWidth;
                                    dimension[1] = window.innerHeight;
                                    Shiny.onInputChange("dimension", dimension);
                                });
                                $(window).resize(function(e) {
                                    dimension[0] = window.innerWidth;
                                    dimension[1] = window.innerHeight;
                                    Shiny.onInputChange("dimension", dimension);
                                });
                            ')), #wyciagniecie rozmiaru okna
  	tags$head(tags$style("#cloud{height:85vh !important;}")), #zrobienie, zeby wykres zajmowal caly ekran
  	selectInput("character", "Wybrana postać:", characters),
  	uiOutput("nextword"),
  	actionButton("previous", "Wstecz"),
  	actionButton("reset", "Reset"),
  	sliderInput("mincount", "Minimalna liczba wystąpień:", 1, 10, value=1),
  	checkboxInput("ordered", "Uwzględniaj kolejność słów"),
  	radioButtons("graphtype", "Typ wykresu:", c("chmura słów" = "wordcloud", "słupkowy" = "barplot"), selected = "wordcloud"),
  	sliderInput("wordcount", "Liczba przedstawionych słów:", 5, 60, value=30),
  	checkboxInput("help", "Pokaż instrukcję"),
  	conditionalPanel(
  	  condition = "input.help == 1",
  	  HTML("<div>Aplikacja wizualizuje słowa wypowiadane przez najważniejszych bohaterów Gry o Tron.<br/><br/>
           Wykresy pokazują najczęstsze słowa, które występują w jednej wypowiedzi wraz z wybranymi już słowami.<br/>
           Można również uwzględniać kolejność słów - wówczas pokazane słowa występują w jednej wypowiedzi zawsze po wybranych 
           już słowach.<br/><br/>
  	       <i>Wszelkie proste słowa (przedimki, zaimki) nie są rozważane w wizualizacji.</i></div>"))
  ),
  mainPanel(
  	uiOutput("wordhistory"),
  	HTML('<hr style="color: black;">'),
  	HTML('<p>Najczęściej używane słowa</p>'),
    plotOutput("cloud")
  )
))

?textInput
