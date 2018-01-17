library(shiny)
library(PogromcyDanych)
library(plotly)

anakin <- read.csv2("anakin_sw_all.csv")

nr_episode <- sort(unique(anakin$episode_nr))

shinyUI(fluidPage(
  tags$audio(src = "imperial_march.mp3", type = "audio/mp3", autoplay = NA, controls = NULL),
  
  tags$head(tags$style(HTML("
                            .well {
                            background-color: #dd9999!important;
                            width: 200px;
                            }
                            "))),
  titlePanel("Anakin Skywalker vs Darth Vader - jasna czy ciemna strona mocy?"),
  sidebarLayout(
    sidebarPanel(

      br(),
      
      checkboxGroupInput("episode2", 
                         label="Wybierz część filmu", 
                         choices = c("Star Wars: Episode I - The Phantom Menace" = nr_episode[1], 
                                        "Star Wars: Episode II - Attack of the Clones" = nr_episode[2], 
                                        "Star Wars: Episode III – Revenge of the Sith" = nr_episode[3],
                                        "Star Wars: Episode IV - A New Hope" = nr_episode[4], 
                                        "Star Wars: Episode V - The Empire Strikes Back" = nr_episode[5], 
                                        "Star Wars: Episode VI - Return of the Jedi" = nr_episode[6]),
                         selected = nr_episode[1])
    
  
      ),
    mainPanel(
      img(src = "anakin.png", height = 250, width = 650),
      
      
      tabsetPanel(
      
        tabPanel("Przewaga mocy", 
                 p("Porównanie ilościowe słów pozytywnych i negatywnych"), 
                 plotOutput("wyk1")),
        tabPanel("Główne emocje", 
                 p("Po ciemnej czy jasnej stronie mocy?"), 
                 plotOutput("wyk2")),

        tabPanel("Najczęstsze słowa", 
                 p("Najczęściej używane słowa przez Anakina/Vadera"), 
                 plotOutput("wyk3"),
                 img(src = "jedi_sith_code.png", height = 500, width = 650, position="center")),
        
        tabPanel("Emocje w czasie", 
                 p("Jak wyglądały emocje w poszczególnych scenach i filmach"), 
                 plotlyOutput("wyk4")),
                
        
        tabPanel("Wypowiedzi", 
                 p("Poszczególne zdania wypowiedziane przez Anakina/Vadera"), 
                 tableOutput("wyk5"))
        
 
      )
    )
  )
  ))