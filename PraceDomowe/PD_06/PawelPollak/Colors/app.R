#
# This is a Shiny web application. You can run the application by clicking
# the 'Run App' button above.
#


library(shiny)
library(colortools)

ui <- fluidPage(
   
   # Application title
   titlePanel("Wybieranie kolorów"),
   
   h3("Paweł Pollak"),
   
   p("Interaktywna wizualizacja pozwala na przeglądanie różnych zestawów kolorów prezentowanych w formie koła. Dzięki takiemu przedstawieniu palety kolorów użytkownik może na wybranym kole kolorów dobrać odpowiednie kolory ich odcienie, które spełniają dane założenia. "),
   
   p("Jako nazwa koloru akceptowana jest nazwa (np. \"blue\") albo kod (np. \"#f5f432\") Można regulować prezentowaną liczbę kolorów w zakresie od 2 do 30."),
   
   p("Pokazana jest również wizualizacja trzech kolorów (w tym jeden wybrany), które są równomiernie rozłożone na kole (ang. \"triadic colors\"). Może to być przydatne do znalezienia kolorów, które bardzo się różnią od pewnego ustalonego koloru."),
    
   sidebarLayout(
      sidebarPanel(
        inputPanel(
          sliderInput("colors_num", label = "Liczba kolorów",
                      min = 2, max = 30, value = 12, step = 1),
          textInput("color_name", "Nazwa koloru", value = "aquamarine", width = NULL, placeholder = NULL)
        )
      ),
      
      mainPanel(
         plotOutput("wheelPlot"),
         plotOutput("triadicPlot")
      )
   )
)

server <- function(input, output) {
  
  areColors <- function(x) {
    sapply(x, function(X) {
      tryCatch(is.matrix(col2rgb(X)), 
               error = function(e) FALSE)
    })
  }

   output$wheelPlot <- renderPlot({
     validate(
       need(areColors(input$color_name), 'Podaj poprawny kolor')
     )
     
     wheel(input$color_name, num = input$colors_num, bg = "gray20", cex = 0.8)
   })
   
   output$triadicPlot <- renderPlot({
     validate(
       need(areColors(input$color_name), '')
     )
     
     triadic(input$color_name, bg = "gray20", title = FALSE)
   })
}

# Run the application 
shinyApp(ui = ui, server = server)

