library(shiny)
if (!require("shinyjs"))
	install.packages("shinyjs")
library(shinyjs)

shinyUI(fluidPage(
	useShinyjs(),
  titlePanel("Udział systemów operacyjnych wśród graczy"),
  
  sidebarLayout(
    sidebarPanel(
    	tags$head(tags$style("#myPlot{height:90vh !important;}")),
    	selectInput("scope", "Szczegółowość:", c("Tylko architektura" = "arch_only", "Rodzina systemu" = "family", "Wersja systemu" = "version"), selected = "family"),
    	selectInput("scope_unity", "Szczegółowość:", c("Rodzina systemu" = "family", "Wersja systemu" = "version"), selected = "family"),
    	selectInput("source", "Źródło danych:", c("Steam Hardware Survey" = "steam", "Unity Standalone Hardware Stats" = "unity"), selected = "steam"),
    	checkboxInput(inputId = "arch",
			 							label = "Podział x86/x64",
			 							value = T),
    	checkboxGroupInput("systems", "Systemy:", choices = c("Windows", "Linux", "MacOS"), selected = c("Windows", "Linux", "MacOS")),
    	h5(strong("Źródła danych:")), 
		 	a(h6("Steam Hardware Survey"), href="http://store.steampowered.com/hwsurvey"),
			a(h6("Unity Standalone Hardware Stats"), href="https://hwstats.unity3d.com/pc/os.html")
    ),
    
    mainPanel(
       plotOutput("myPlot")
    )
  )
))
