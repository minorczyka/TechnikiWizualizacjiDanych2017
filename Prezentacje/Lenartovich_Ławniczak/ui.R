library(shiny)
library(ggplot2)
library(plotly)

shinyUI(fluidPage(
  tags$head(
    tags$style(HTML("
                    .modebar  {
                    display: none
                    }

                    img { 
                      max-width: 100%;
                      width: 100%;
                      height:auto;
                    }

                    .well{
                      margin-top: 45px;
                    }
                    "))
    ),
  
  titlePanel("Wykresy świecowe"),
  fluidRow(
    column(
      12, tags$div("Poniżej przedstawiony jest wykres świecowy dla WIG20 - indeksu giełdowego łączącego 20 największych spółek
            akcyjnych notowanych na warszawskiej Giełdzie Papierów Wartościowych.")
    )
  ),
  sidebarLayout(
    sidebarPanel(
      dateRangeInput("daterange", "Choose range:",
                     start = "2014-01-01",
                     end   = "2014-02-01",
                     min = "2013-12-02",
                     max = "2014-11-28"),
      checkboxInput("showSelectedMonth", strong("Show only selected month"), value = FALSE)
    ),
    mainPanel(
      plotlyOutput("trend")
    )
  ),
  br(),
  tags$h2("Opis struktury świecy"),
  br(),
  fluidRow(
    column(5,
           img(src='candlestick.png', align="right")),
    column(7,
           tags$div( "Wykresy świecowe (albo świece japońskie) dają najwięcej informacji o sytuacji na rynku i ruchu ceny.
           Są bardziej przejrzyste od wykresu liniowego i zawierają dla nas więcej istotnych informacji.",
                     "Świeca jest graficzną interpretacją tego co dzieje się z ceną. Świeca pokazuje nam:",
                     tags$ul(
                       tags$li("cenę otwarcia (", strong("open"), ")"), 
                       tags$li("cenę zamknięcia (", strong("close"), ")"), 
                       tags$li("cenę maksymalną w danym zakresie (", strong("high"), ")"),
                       tags$li("cenę minimalną w danym zakresie (", strong("low"), ")")
                     ),
                     "Zakres pomiędzy ceną otwarcia i zamknięcia tworzy", strong("korpus"),". Dzięki kolorowaniu świec od razu widać jaka jest 
           sytuacja w danej chwili.",
                     "W zależności od tego czy cena otwarcia jest powyżej czy poniżej ceny zamknięcia tworzą nam się dwa rodzaje świec:",
                     tags$ol(
                       tags$li("świeca rosnąca (", strong("bullish candle"), ")"),
                       tags$li("świeca opadająca (", strong("bearish candle"), ")")
                     ),
                     "Świeca zamykająca się powyżej otwarcia jest zazwyczaj jasna a zamykająca się poniżej jest czarna.",
                     "Wykresy świecowe co pewien czas układają się w specyficzne formacje, które mogą być pomocne w podjęciu decyzji o kupnie lub sprzedaży.")
        )
  ),
  br(),
  tags$h2("Wzorce"),
  br(),
  fluidRow(
    column(3, img(src='hammer.png', align="right")),
    column(3, tags$div(
      tags$h3("Młot (hammer)"),
      "Formacja, która jest utworzona na końcu spadku, długi knot pokazuje nam, 
      że sprzedawcy najpierw pchnęli cenę w dół, ale potem zaś wypchnęli cenę z powrotem do góry. 
      Jeśli zobaczysz formację Hammer, powinien nastąpić wzrost ceny."
    )),
    column(3, img(src='hangingman.png', align="right")),
    column(3, tags$div(
      tags$h3("Wisielec (Hanging man)"),
      "Wzór odwrotny do patternu Młot, cena odbija się po wzrostu. Trzeba zaczekać na kolejną świecę, 
      która powinna potwierdzić spadek ceny"
    ))
  ),
  fluidRow(
    column(3, img(src='shootingstarandinvertedhammer.png', align="middle")),
    column(3, tags$div(
      tags$h3("Spadająca gwiazda (Shooting star) i Odwrócony młot (Inverted Hammer) "),
      "Shooting star - Powstaje po wzroście, spodziewany jest spadek cen.",
      br(),
      "Inverted Hammer - powstaje podczas spadku, spodziewany jest wzrost ceny."
    )),
    column(3, img(src='threesoldiers.jpg', align="right")),
    column(3, tags$div(
      tags$h3("Trzech żołnierzy (Three soldiers)"),
      "Najczęściej spotykana jest kiedy rynek przed jej wystąpieniem był stabilny 
      albo też pojawiła się na nim korekta. Na tym konkretnym przykładzie widać, 
      że otwarcia kolejnych świec wypadają poniżej zamknięć poprzednich,
      natomiast jeśli są na tym samym poziomie, świadczy to o dodatkowej sile rynku."
    ))
  ),
  fluidRow(
    column(3, img(src='trojkahossy.jpg', align="middle")),
    column(3, tags$div(
      tags$h3("Trójka hossy"),
      "Formacja kontynuacji trendu wzrostowego. W trendzie powstaje długa biała świeca, 
      po której następuje osłabienie i powstają dwie lub więcej małych świec (najlepiej jeśli są czarne)
      mieszczących się w korpusie pierwszej świecy. Spadek nie był na tyle silny, 
      by przebić minimum pierwszej świecy i następuje ponowny wzrost. 
      Powstaje kolejna (długa biała) świeca, zamykająca się powyżej świecy pierwszej. 
      Potwierdzeniem formacji są transakcje powyżej korpusu drugiej białej świecy."
    )),
    column(3, img(src='trojkabessy.jpg', align="right")),
    column(3, tags$div(
      tags$h3("Trójka bessy"),
      "Formacja kontynuacji trendu spadkowego. W trendzie powstaje długa czarna świeca.
       Po niej następuje osłabienie spadku i powstają dwie lub więcej małych świec (najlepiej jeśli są białe),
       mieszczące się w korpusie pierwszej świecy. Wzrost nie jest na tyle silny by przebić maksimum pierwszej
       świecy i następuje ponowny spadek. Powstaje kolejna (długa czarna) świeca zamykająca się poniżej świecy pierwszej. 
       Potwierdzeniem formacji są transakcje poniżej korpusu drugiej czarnej świecy."
    ))
  )
  )
)


