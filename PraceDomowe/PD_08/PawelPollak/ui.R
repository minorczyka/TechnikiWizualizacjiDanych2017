# Paweł Pollak

data <- read.table("data.txt", header = TRUE)

fluidPage(
  titlePanel("Wydatki na opiekę społeczną"),
  h4("Paweł Pollak"),
  h3("Źródło danych"),
  p("Dane pochodzą ze zbiorów eurostatu. Konkretniej, zostały one przedstawione w artykule:"),
  a("Almost one-third of EU GDP spent on social protection", 
    href = "http://ec.europa.eu/eurostat/documents/2995521/8510280/3-08122017-AP-EN.pdf/d4c48fca-834b-4b08-bdec-47aaa226a343"),
  h3("Opis"),
  p("W artykule zostały zwizualizowane jedynie dane z 2015. W dodatku, w przypadku podziału wydatków na poszczególne kategorie została przedstawioa jedynie średnia dla UE. Dzięki Shiny, możliwe jest przedstawienie większej ilości danych i umożliwienie wybrania dowolnych krajów i lat."),
  p("Ciekawą sprawą jest to, że ze wszystkich Państw jedynie dane dla Polski nie są w pełni dostępne."),
  fluidRow(
    column(3, wellPanel(
      conditionalPanel(condition="input[\"tabs\"] == \"Na przestrzeni lat\"",checkboxGroupInput("years", "Lata:",
                           c("2010" = "2",
                             "2014" = "3",
                             "2015" = "4"), 
                         selected = c("3","4"))),
      checkboxGroupInput("countries", "Kraje:",
                         sort(data$Country), 
                         selected = sort(data$Country))
    )),
    column(6, tabsetPanel( id = "tabs",
    tabPanel("Na przestrzeni lat",
           plotOutput("plotYears", width = 500, height = 800),
           p("* dane dla Polski tylko z 2010 roku")),
    tabPanel("Rozkład wydatków w 2015",
             plotOutput("plotShare", width = 600, height = 700),
             p("* dane dla Polski niedostępne"))
    ))
  )
)