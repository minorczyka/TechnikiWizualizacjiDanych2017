library(shiny)
library(ggplot2)
library(shinydashboard)
library(dplyr)
library(plotly)

load(file = "sentiment.rda")

selectedPeople_1 <- sentiment %>%
  filter(part == 1) %>%
  group_by(person) %>%
  summarise(Frequency = sum(abs(sentiment))) %>%
  filter(Frequency > 0) %>%
  select(person)%>%
  unlist(use.names = FALSE)

selectedPeople_2 <- sentiment %>%
  filter(part == 2) %>%
  group_by(person) %>%
  summarise(Frequency = sum(abs(sentiment))) %>%
  filter(Frequency > 0) %>%
  select(person)%>%
  unlist(use.names = FALSE)

shinyUI(dashboardPage(skin="green",
  dashboardHeader(title = "Godfather - Wybierz najbardziej pozytywnego Mafioza", titleWidth = 600),
  dashboardSidebar(width = 300,
    sidebarMenu(id = "sidebarmenu",
      menuItem("Obie części", tabName = "dashboard", icon = icon("dashboard")),
      menuItem("Część 1", tabName = "season1", icon = icon("star-half-o")),
      menuItem("Część 2", tabName = "season2", icon = icon("star"))
    ),
    br(),
    sliderInput(
      'scenesRanger',
      'Zakres scen:',
      min = 1,
      max = 444,
      value = c(1, 444)
    ),
    br(),
    numericInput("scenesFrequency",
                 'Częstotliwość scen z filmu:',
                 min = 1,
                 max = 200,
                 step = 20,
                 value = 10),
    br(),
    radioButtons("scenesAggregation",
                 'Funkcja agregująca sceny:',
                 c("minimum" = "min", "maximum" = "max", "średnia" = "mean", "suma" = "sum"),
                 inline = FALSE,
                 selected = "mean"),
    br(),
    radioButtons("sortingDirection",
                 'Sortowanie:',
                 c("rosnąco" = "asc", "malejąco" = "desc"),
                 inline = FALSE,
                 selected = "asc")
  ),
  dashboardBody(
    tags$style(type="text/css",
               ".shiny-output-error { visibility: hidden; }",
               ".shiny-output-error:before { visibility: hidden; }"
    ),
    tags$link(rel="stylesheet", type="text/css",href="style.css"),
    tags$script(type="text/javascript", src = "busy.js"),
    div(class = "busy",  
        p("Trwa pobieranie danych..."), 
        img(src="Spinner.gif")
    ),
    tabItems(
      tabItem(tabName = "dashboard"
      ),
      tabItem(tabName = "season1",
              h2("Część 1")
      ),
        tabItem(tabName = "season2",
                h2("Część 2")
        )
      ),
    fluidRow(
      valueBoxOutput("personNumberBox"),
      valueBoxOutput("maxPositiveValue"),
      valueBoxOutput("maxNegativeValue")
    ),
    fluidRow(box(plotlyOutput("trend"), width = '100%')),
    fluidRow(
      fluidRow(
        box(
          title = "Wybierz postaci do analizy",
          br(),
          width = '90%',
          collapsible = TRUE,
          collapsed = TRUE,
          solidHeader = TRUE,
          status = "primary",
          selectInput(
            "selectedPeople1",
            label = "Postaci (część 1):",
            choices = selectedPeople_1,
            multiple = TRUE,
            width = '90%'
          ),
          br(),
          selectInput(
            "selectedPeople2",
            label = "Postaci (część 2):",
            choices = selectedPeople_2,
            multiple = TRUE,
            width = '90%'
          )
        )
      ),
      style="margin-left: 0px !important; margin-right: 0px !important;"
    )
  )
))
