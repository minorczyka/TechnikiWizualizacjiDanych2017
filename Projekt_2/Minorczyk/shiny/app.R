library(shiny)
library(ggvis)
library(dplyr)
library(tibble)
library(ggplot2)

characters_palette <- c("#81AED8", "#F816BB", "#E0A155", "#62B5DA", "#FFBB42", "#73CF73", "#EC6D6E", "#C8AADF", "#C39D93", "#F2B5E2", "#DFDF66",
                        "#55E0E8", "#5BCEB5", "#EDA416", "#B4B1DA", "#F46FC2", "#A9D360", "#F3D516", "#D3B55F", "#A9A9A9", "#FEE0B0", "#AC86CC",
                        "#FFFFCB", "#D99F6E", "#F25A5D", "#95D892", "#CA96D1", "#FFBB00", "#FFFF7B", "#A9E2D2", "#FDC4A6", "#D3ED9B", "#FFED77",
                        "#DADADA", "#F7E684", "#CDB4A2", "#CEE6F5", "#C1EAB8", "#DCCC63", "#F9E8A1", "#8CCAC8", "#F29E9D", "#ECB1C9", "#FDE0EA")

df <- readRDS("data.rds") %>%
  mutate(name = as.factor(name),
         episode_overall = (season - 1) * 10 + episode) %>%
  rownames_to_column("id")
character_names <- df$name %>%
  unique %>% 
  sort

ui <- fluidPage(
  titlePanel("Game of Thrones - character occurences"),
  fluidRow(
    column(3,
           wellPanel(
             selectInput("type", "Type", c("All episodes", "Seasons summary")),
             sliderInput("seasons", "Seasons", 1, 6, value = c(1, 6)),
             selectInput("characters", "Characters", character_names, multiple = TRUE),
             checkboxInput("highlight_character", "Highlight character"),
             conditionalPanel("input.highlight_character", selectInput("selected_character", "Highlighted character", character_names)),
             tags$label("Groups"), tags$br(),
             actionButton("select_all", "All"),
             actionButton("select_starks", "Starks"),
             actionButton("select_lannisters", "Lannisters"),
             actionButton("select_barathons", "Baratheon"),
             actionButton("select_north", "Night Watch and Wildlings"),
             actionButton("select_sea", "The Dragon Queen"),
             checkboxGroupInput("occurence_type", "Occurence type:", c("Dialog", "Reference"), c("Dialog", "Reference"))
           )
    ),
    column(9,
           ggvisOutput("chart")
    )
  ),
  conditionalPanel("false", selectInput("selected_character", "", c("none", character_names %>% as.character)))
)

server <- function(input, output, session) {
  
  observeEvent(input$select_all, {
    updateSelectInput(session, "characters", selected = list())
  })
  
  observeEvent(input$select_starks, {
    selected <- Filter(function(x) grepl("Stark", x), character_names)
    updateSelectInput(session, "characters", selected = selected)
  })
  
  observeEvent(input$select_lannisters, {
    selected <- Filter(function(x) grepl("Lannister", x), character_names)
    updateSelectInput(session, "characters", selected = selected)
  })
  
  observeEvent(input$select_barathons, {
    selected <- Filter(function(x) grepl("Baratheon", x), character_names)
    updateSelectInput(session, "characters", selected = selected)
  })
  
  observeEvent(input$select_north, {
    selected <- Filter(function(x) x %in% c("Jon Snow", "Samwell Tarly", "Jeor Mormont", "Tormund Giantsbane", "Gilly", "Ygritte"), character_names)
    updateSelectInput(session, "characters", selected = selected)
  })
  
  observeEvent(input$select_sea, {
    selected <- Filter(function(x) x %in% c("Daenerys Targaryen", "Jorah Mormont", "Viserys Targaryen", "Khal Drogo", "Daario Naharis", "Missandei"), character_names)
    updateSelectInput(session, "characters", selected = selected)
  })
  
  filtered <- reactive({
    min_season <- input$seasons[1]
    max_season <- input$seasons[2]
    characters <- if(input$characters %>% length == 0) character_names else input$characters
    
    df %>%
      filter(season >= min_season, season <= max_season, name %in% characters) %>%
      mutate(selected = if (input$highlight_character) (name == input$selected_character) else TRUE,
             value = switch(input$occurence_type %>% paste(collapse = ""),
                            "Dialog" = dialog_counts,
                            "Reference" = counts - dialog_counts,
                            "DialogReference" = counts, 0)) %>%
      filter(value > 0)
  })
  
  filtered_selected <- reactive({
    filtered() %>% filter(selected)
  })
  
  seasons_summary <- reactive({
    min_season <- input$seasons[1]
    max_season <- input$seasons[2]
    characters <- if(input$characters %>% length == 0) character_names else input$characters
    
    df %>%
      filter(season >= min_season, season <= max_season, name %in% characters) %>%
      group_by(season, name) %>%
      summarise(counts = sum(counts), dialog_counts = sum(dialog_counts)) %>%
      add_bars(input$occurence_type) %>%
      as.data.frame %>%
      rownames_to_column("id") %>%
      mutate(selected = if (input$highlight_character) (name == input$selected_character) else TRUE)
  })
  
  seasons_summary_selected <- reactive({
    seasons_summary() %>% filter(selected)
  })
  
  tooltip <- function(x) {
    if (x %>% length == 5) {
      val <- filtered() %>% filter(id == x$id)
      paste0("<b>", val$name, "</b><br>S", val$season, "E", val$episode, ": ", val$value)
    } else {
      vals <- isolate(seasons_summary())
      val <- vals %>% filter(id == x$id)
      paste0("<b>", val$name, "</b><br>Season ", val$season, ": ", val$counts)
    } 
  }
  
  add_bars <- function(df, occurence_type) {
    outer_margin <- 0.15
    inner_margin_perc <- 0
    
    characters <- df$name %>% unique
    n <- characters %>% length
    width <- (1 - outer_margin) / (n + (n - 1) * inner_margin_perc)
    inner_margin <- width * inner_margin_perc
    
    df %>% 
      mutate(char_index = which(name %in% characters),
             x1 = season - 0.5 + outer_margin / 2 + (char_index - 1) * (width + inner_margin),
             x2 = x1 + width,
             y1 = switch(occurence_type %>% paste(collapse = ""),
                         "Dialog" = dialog_counts,
                         "Reference" = counts - dialog_counts,
                         "DialogReference" = counts, 0),
             y2 = 0) %>%
      select(-char_index)
  }

  # Niestety działa zbyt wolno na serwerze
  # on_mouse_over <- function(data, location, session) {
  #   updateSelectInput(session, "selected_character", selected = data$name)
  # }
  # 
  # on_mouse_out <- function(session) {
  #   updateSelectInput(session, "selected_character", selected = "none")
  # }
  
  chart <- reactive({
    chart_type <- input$type
    
    p <- if (chart_type == "All episodes") {
      filtered %>%
        ggvis(~episode_overall, ~value) %>%
        layer_points(fill = ~name, shape = ~as.factor(season), 
                     opacity := 0.2, size := 60, key := ~id) %>%
        layer_points(fill = ~name, shape = ~as.factor(season), 
                     size := ifelse(input$highlight_character, 120, 60), key := ~id, 
                     data = filtered_selected) %>%
        add_axis("x", title = "Episode overall") %>%
        add_axis("y", title = "Occurrences") %>%
        hide_legend("shape")
    } else {
      seasons_summary %>%
        ggvis(~x1, ~y1, x2 = ~x2, y2 = ~y2) %>%
        layer_rects(fill = ~name, opacity := 0.2, key := ~id) %>%
        layer_rects(fill = ~name, key := ~id, data = seasons_summary_selected) %>%
        add_axis("y", title = "Occurrences") %>%
        add_axis('x', title = "Season", orient = c('bottom'), format = 'd')
    }
    p %>% 
      scale_nominal("fill", range = characters_palette) %>%
      add_tooltip(tooltip, "hover") %>%
      hide_legend("fill") %>%
      set_options(width = "auto", height = 600)
  })
  
  chart %>% bind_shiny("chart")
}

shinyApp(ui = ui, server = server)
