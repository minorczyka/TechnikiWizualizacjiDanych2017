
# This is the user-interface definition of a Shiny web application.
# You can find out more about building applications with Shiny here:
#
# http://shiny.rstudio.com
#

library(shiny)
library(plotly)
library(shinycssloaders)

options(spinner.color="#e3e3e3")
parts <- read.csv("pc_parts.csv")[,-2]

shinyUI(fluidPage(

  # Application title
  titlePanel("Oblicz cenę komputera"),

  # Sidebar with a slider input for number of bins
  sidebarLayout(
    sidebarPanel(
      selectInput("cpu", 
                  label = "Wybierz procesor",
                  choices = parts[parts$Type=="CPU",1]),
      selectInput("gpu", 
                  label = "Wybierz kartę graficzną",
                  choices = parts[parts$Type=="GPU",1]),
      selectInput("ram", 
                  label = "Wybierz RAM",
                  choices = parts[parts$Type=="RAM",1]),
      selectInput("storage", 
                  label = "Wybierz pamięć",
                  choices = parts[parts$Type=="Storage",1]),
      checkboxInput("sum",
                    label="Pokaż sumę")
      
    ),

    # Show a plot of the generated distribution
    mainPanel(
      plotlyOutput("partPlot") %>% withSpinner(),
      htmlOutput("summary")
    )
  ),
  verticalLayout(
    h1("Źródło danych"),
    p("Dane dotyczące ceny części komputerowych pochodzą ze strony", 
      a(href="https://pricespy.co.uk", "pricespy"), 
      ". Strona oferuje historie ceny oraz popularności dla każdego sprzętu", 
      a(href="https://pricespy.co.uk/product.php?pu=3780489","(przykłady wykres dla karty graficznej GeForce GTX 1060)"),
      ". Wybrane zostały tylko przykładowe podzespoły. Dla każdego z porównywanych sprzętów zapisany został numer Id, a dane pobierane są w czasie rzeczywistym ze strony pricespy. Poniżej przedstawiona jest tabela z linkami do danych oraz wykresów dla każdej części."
      ),
    dataTableOutput("source") %>% withSpinner()
  )
))
