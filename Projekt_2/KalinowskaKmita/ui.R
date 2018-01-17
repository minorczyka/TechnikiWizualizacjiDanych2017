
# library(shiny)


shinyUI(fluidPage(
  
  # use Shinyjs(),
  #tags$hr2("Marla, Jack oraz Tyler - sceny z udziałem Marli w filmie Fightclub")
  
  titlePanel("Marla, Jack oraz Tyler - sceny z udziałem Marli w filmie Fightclub"),
  
  sidebarLayout(
    
    sidebarPanel(
      
      checkboxGroupInput(inputId = "postaci",
                         label = "Które postaci chcesz analizować?",
                         choices = list("jack", "marla", "other", "tyler"),
                         selected = "marla"
      ),
      
      #p(""),
      tags$hr(style="border-color: purple;"
      ),
      
      checkboxInput(inputId = "geomline",
                    label = "Czy zaznaczyć linie między punktami?",
                    value = TRUE
      ),
      
      tags$hr(style="border-color: purple;"
      ),
      
      checkboxInput(inputId = "geomtlo",
                    label = "Czy zaznaczyć tło związane z wydźwiękiem sceny?",
                    value = FALSE
      ),
      
      tags$hr(style="border-color: purple;"
      ),
      
      numericInput(inputId = "num",
                   label = "Którą scenę chcesz przeczytać w scenariuszu?",
                   min = 1,
                   max = 22,
                   value = 1
      )
      
      # sliderInput(inputId = "range",
      #             label = "które sceny chcesz analizować?",
      #             min = 1,
      #             max = 22,
      #             value = c(1,1)
      # )
    # koniec sidebarPanel  
    ),

    mainPanel(
      
      tabsetPanel(
        
        tabPanel("Wykres",
                 #p("Wykres udzialu w scenach"),
                 tags$h3("Wykres ukazujący udział poszczególnych bohaterach w scenach z Marlą"),
                 plotlyOutput("trend")
        ),
        
        tabPanel("Scenariusz - wybrana scena",
                 tags$h3("Poniżej znajduje się fragment scenariusza dot. wybranej sceny"),
                 htmlOutput("numer")
        ),
        
        tabPanel("Informacje",
                 p("Projekt zaliczeniowy nr 2 z Technik Wizualizacji Danych")
        )
      )
    )
  )
))