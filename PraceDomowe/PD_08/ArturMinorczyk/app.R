library(shiny)
library(dplyr)
library(ggplot2)
library(RColorBrewer)


gold <- read.csv("LBMA-GOLD.csv") %>% 
  select(date = Date, price = USD..PM.) %>% 
  mutate(date = as.Date(date), name = "gold")
silver <- read.csv("LBMA-SILVER.csv") %>% 
  select(date = Date, price = USD) %>% 
  mutate(date = as.Date(date), name = "silver")
platinum <- read.csv("LPPM-PLAT.csv") %>% 
  select(date = Date, price = USD.PM) %>% 
  mutate(date = as.Date(date), name = "platinum")
palladium <- read.csv("LPPM-PALL.csv") %>% 
  select(date = Date, price = USD.PM) %>% 
  mutate(date = as.Date(date), name = "palladium")
iridium <- read.csv("JOHNMATT-IRID.csv") %>%
  select(date = Date, price = New.York.9.30) %>%
  mutate(date = as.Date(date), name = "iridium")
rhodium <- read.csv("JOHNMATT-RHOD.csv") %>%
  select(date = Date, price = New.York.9.30) %>%
  mutate(date = as.Date(date), name = "rhodium")
ruthenium <- read.csv("JOHNMATT-RUTH.csv") %>% 
  select(date = Date, price = New.York.9.30) %>% 
  mutate(date = as.Date(date), name = "ruthenium")

df <- rbind(gold, silver, platinum, palladium, iridium, rhodium, ruthenium)

min_date <- df$date %>% min
max_date <- df$date %>% max

names <- c("Złoto" = "gold", 
           "Srebro" = "silver", 
           "Platyna" = "platinum", 
           "Pallad" = "palladium", 
           "Iryd" = "iridium",
           "Rod" = "rhodium",
           "Ruten" = "ruthenium")

ui <- fluidPage(
  titlePanel("Ceny metali szlachetnych oraz metali rzadkich"),
  h4("Praca domowa 8"),
  h4("Artur Minorczyk"),
  p("Wykres przedstawia ceny metali szlachetnych oraz metali rzadkich na przestrzeni ostatnich kilkudziesięciu lat."),
  
  sidebarLayout(
    sidebarPanel(
      dateRangeInput("dates", "Okres czasu:", min = min_date, max = max_date, start = "1992-07-01", end = max_date, startview = "decade", language = "pl"),
      selectInput("names", "Metale:", names, selected = names, multiple = TRUE),
      checkboxInput("smooth", "Wygładzanie"),
      conditionalPanel(condition = "input.smooth == true", 
                       selectInput("smoothMethod", "Metoda:", c("auto", "lm", "loess"))
      )
    ),
    mainPanel(
      plotOutput("plot", height = "600px")
    )
  ),
  
  p("Dane pochodzą z portalu Quandl: ", br(),
    a("https://www.quandl.com/markets/gold"), br(),
    a("https://www.quandl.com/markets/silver"), br(),
    a("https://www.quandl.com/markets/platinum"), br(),
    a("https://www.quandl.com/markets/palladium"), br(),
    a("https://www.quandl.com/markets/rare-metals"), br()
  )
)

server <- function(input, output) {
  filtered <- reactive({
    df %>% 
      filter(name %in% input$names, date >= input$dates[1], date <= input$dates[2]) %>%
      mutate(name = factor(name, levels = unique(df$name)))
  })
  
  output$plot <- renderPlot({
    plt <- ggplot(filtered(), aes(date, price, color = name)) +
      xlab("Data") +
      ylab("Cena [USD/oc]") +
      expand_limits(y = 0) +
      scale_color_manual(name = "Metale", values = brewer.pal(7, name = "Dark2"),
                         breaks = names, labels = names %>% names, drop = FALSE)
    if (input$smooth) {
      plt + geom_line(alpha = 0.3) +
        geom_smooth(method = input$smoothMethod)
    } else {
      plt + geom_line()
    }
  })
}

shinyApp(ui = ui, server = server)
