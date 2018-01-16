library(shiny)
library(ggplot2)
library(plotly)
library(rCharts)
library(highcharter)


shinyUI(fluidPage(
  tags$head(
    tags$head(tags$script(src="sticky-kit.js")),
    tags$head(HTML('<script type="text/javascript">
                    $(".poster-image").stick_in_parent({
                      parent: ".col-sm-4" // note: we must now manually provide the parent
                   });
                   </script>')),
    tags$body('data-spy' = "scroll", 'data-target'= ".poster-image", 'data-offset' = "15"),
    tags$style(HTML("
                    .modebar  {
                    display: none
                    }
                    
                    .poster-image{
                      display:none;
                      margin-top: 15px;
                    }

                    .person-image { 
                    width: 40px;
                    height:40px;
                    margin-top:10px;
                    }

                    .margin-tp-10{
                      margin-top:10px;
                    }

                    .margin-5{
                      margin:5px;
                    }

                    .margin-bm-5{
                      margin-bottom:5px;
                    }

                    .margin-top-5{
                      margin-top:5px;
                    }

                    .margin-top-10{
                      margin-top:10px;
                    }

                    .margin-lf-30{
                      margin-left:30px;
                    }

                    .right-alignment{
                      right:0;
                    }
                    
                    .left-alignment{
                      left:0;
                    }
    
                    .padding-left-5{
                      padding-left:5px;
                    }

                    .well{
                    margin-top: 15px;
                    }
                    
                    .personDialog{
                    background-color:gray;
                    }

                    .director-note{
                      color: gray;
                    }

                    .rcorners{
                    border-radius: 25px;
                    background-color: lightblue;
                    padding: 15px;
                    }

                    .rcorners-scene{
                    border-radius: 5px;
                    background-color: lightgray;
                    padding: 15px;
                    }

                    .scene-description{
                      font-weight: bold;
                      text-align: center;
                      background-color: gray;
                    }

                    .person-mention{
                    font-weight: bold;
                    }

                    .emotion-mention{
                    font-weight: bold;
                    text-align: center;
                    }

                    .affix {
                       top: 20px;
                       z-index: 9999 !important;
                       width: 30%;
                    }


                    .affix-top {
                       top: 20px;
                       z-index: 9999 !important;
                       width: 100%;
                    }

                    .col-sm-4 {
                    height: 100%;
                    }

                    
                  "))
    ),
  sidebarLayout(
    sidebarPanel(
      div(style = 'display: none',   selectInput(inputId="chooseType",
                                                 label="Choose emotions",
                                                 choices=c("analytical","anger","confident","fear","joy","sadness","tentative"),
                                                 multiple = TRUE,
                                                 selected=c("analytical","anger","confident","fear","joy","sadness","tentative"))),
      div(style = 'display: none', textInput(inputId="myInput", label="")),
      conditionalPanel(
            condition="input.selectAll == false",
            div(style = 'overflow-x: scroll', DT::dataTableOutput('choosingTable'))
      ),
      checkboxInput("selectAll","Select all characters"),
      checkboxInput("wholeScenes", "Show whole scenes", TRUE)
      
    ),  
    # Show ui
    mainPanel(
      showOutput("bubbleChart", "highcharts")
      #verbatimTextOutput('x4')
    )
  ),
  fluidRow(
    column(width=4, HTML('
                        <h3>What does this application do? </h3>
                        <p>
                          The application allows user to perform a deep sentiment analysis of the movie <b>Léon The Professional</b>.
                          It enables you not only to get to know the characters better or to find the crutial scenes of the movie
                          but also to get a fresh look at the dialogues. Therefore, it makes us realize that the <b>Leon</b> is not just a movie, but an outstanding masterpiece 
                          in the world of the cinema.
                        </p>
                        <br/>   

                        <h3>How to use the application?</h3>
                        <p>
                          <ul>
                            <li>First, choose the characters and emotions that you want to analize. You can do it in the upper left panel.</li>
                            <li>Using the chart in the the upper right panel you can make very specific analysis of the film including
                                comparison of the influence between the characters\' speeches within the whole movie.
                                The presented chart is interactive and allows you to choose a specific person, emotions or stage to perform better understanding of the movie.<br/></li>
                            <li>  
                                The scene selection activates the chat view at the bottom of the page. On the right side there are the speeches of the chosen hero. 
                                Left presents speeches of other characters. Scene descriptions are presented in greyish areas.
                            </li>
                            <li>In the right bottom corner there is a graph showing the distribution of emotions in the selected scene.</li>
                          </ul>
                        </p>
                         
                         <br/>
                         <div class="padding-left-5">
                           <p>MiNI 2017</p>
                           <p>Agata Czajkowska, Piotr Krzeszewski, Anton Lenartovich</p>
                         </div>
                         
                         ')),
    column(width=4,  wellPanel(
      htmlOutput("citations")
    )),
    column(width=4, plotlyOutput("sceneStats"))
  )
)
)

