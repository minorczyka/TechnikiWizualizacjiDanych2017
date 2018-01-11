getGodfahter2Script <- function() {
  script <- readLines("Przygotowanie scenariusza/godfather2.html")
  
  script <- script[-(1:81)]
  script <- script[-(10333:10336)]
  script <- gsub("\t", "     ", script)
  
  script <- data.frame(script=script, stringsAsFactors = FALSE)
  script$scene <- NA
  script$person <- NA
  script$removeline <- FALSE
  
  script <- filter(script, nchar(script) != 0)
  
  scene_no <- 0
  person <- ""
  
  for(i in 1:nrow(script)) {
    # scena we wnętrzu
    if(substr(script[i, "script"], 1, 5) == "INT. ")
    {
      scene_no <- scene_no + 1
      person <- ""
      script[i, "removeline"] <- TRUE
    }
    
    # scena na zewnątrz
    if(substr(script[i, "script"], 1, 5) == "EXT. ")
    {
      scene_no <- scene_no + 1 
      person <- ""
      script[i, "removeline"] <- TRUE
    }
    
    # didaskalia - zaczynają się właśnie tutaj
    if(substr(script[i, "script"], 1, 10) != "          ")
      script[i, "removeline"] <- TRUE
    
    if(substr(script[i, "script"], 1, 15) == "               ")
      script[i, "removeline"] <- TRUE
    
    # oznaczenie kto wypowie kwestię z następnego wiersza
    if(substr(script[i, "script"], 1, 20) == "                    ")
    {
      person <- trimws(script[i, "script"])
      script[i, "removeline"] <- TRUE
    }
    
    script[i, "scene"] <- scene_no
    script[i, "person"] <- person
  }
  
  script <- script %>%
    filter(!removeline, scene!=0) %>%
    select(scene, person, script) %>%
    mutate(script=trimws(script))
  
  
  script$person <- gsub(" (O.S.)", "", script$person, fixed = TRUE)
  script$person <- gsub(" (V.O.)", "", script$person, fixed = TRUE)
  
  return(script)
}