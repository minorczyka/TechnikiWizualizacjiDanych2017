library(dplyr)
library(networkD3)

getNumberOfEpisodes = function(df) {
  as.numeric(count(distinct(df, Episode, Season)))
}

getMainCharacters = function(df) {
  minn = getNumberOfEpisodes(df) / 2
  mainCharacters = filter(count(distinct(df, Person, Episode, Season), Person), n > minn)
  count(filter(df, Person %in% mainCharacters$Person), Person)
}

createRelationPlot = function(df) {
  mainCharacters = getMainCharacters(df)
  df = data.frame(SourceName=house$Person, TargetName=house[c(nrow(house), 1:(nrow(house)-1)), "Person"])
  df = filter(df, SourceName %in% mainCharacters$Person, TargetName %in% mainCharacters$Person)
  df = t(apply(df, 1, sort))
  df = data.frame(SourceName=df[, 1], TargetName=df[, 2])
  edgeList = count(df, SourceName, TargetName)
  colnames(edgeList) <- c("SourceName", "TargetName", "Weight")
  
  # Create a graph. Use simplyfy to ensure that there are no duplicated edges or self loops
  gD <- igraph::simplify(igraph::graph.data.frame(edgeList, directed=FALSE))
  
  # Create a node list object (actually a data frame object) that will contain information about nodes
  nodeList <- data.frame(ID = c(0:(igraph::vcount(gD) - 1)), # because networkD3 library requires IDs to start at 0
                         nName = igraph::V(gD)$name)
  
  # Map node names from the edge list to node IDs
  getNodeID <- function(x){
    which(x == igraph::V(gD)$name) - 1 # to ensure that IDs start at 0
  }
  # And add them to the edge list
  edgeList <- plyr::ddply(edgeList, .variables = c("SourceName", "TargetName", "Weight"), 
                          function (x) data.frame(SourceID = getNodeID(x$SourceName), 
                                                  TargetID = getNodeID(x$TargetName)))
  
  nodeList <- inner_join(nodeList, mainCharacters, by=c("nName" = "Person"))
  
  result <- forceNetwork(Links = edgeList, # data frame that contains info about edges
                                           Nodes = nodeList, # data frame that contains info about nodes
                                           Source = "SourceID", # ID of source node 
                                           Target = "TargetID", # ID of target node
                                           Value = "Weight", # value from the edge list (data frame) that will be used to value/weight relationship amongst nodes
                                           NodeID = "nName", # value from the node list (data frame) that contains node description we want to use (e.g., node name)
                                           Nodesize = "n",  # value from the node list (data frame) that contains value we want to use for a node size
                                           Group = 1,  # value from the node list (data frame) that contains value we want to use for node color
                                           height = 1000, # Size of the plot (vertical)
                                           width = 1800,  # Size of the plot (horizontal)
                                           fontSize = 100, # Font size
                                           linkDistance = networkD3::JS("function(d) { return 5*d.value; }"), # Function to determine distance between any two nodes, uses variables already defined in forceNetwork function (not variables from a data frame)
                                           linkWidth = networkD3::JS("function(d) { return d.value/5; }"),# Function to determine link/edge thickness, uses variables already defined in forceNetwork function (not variables from a data frame)
                                           opacity = 0.8, # opacity
                                           zoom = TRUE, # ability to zoom when click on the node
                                           opacityNoHover = 0.5) # edge colors
  result
  return(result)
}

my_plot = createRelationPlot(house) 

my_plot
networkD3::saveNetwork(my_plot, "D3_LM.html", selfcontained = TRUE)
