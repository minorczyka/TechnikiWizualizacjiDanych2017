#install.packages("googleVis")
library(googleVis)

Cities <- c("Detroit","Kansas City", "Fort Collins","Denver","Rapid City","Saint Louis","New Orlean",
            "Lincoln",
            "Lubbock", "Casper", "Salt Lake City", "La Junta","Dalhart","Lousville","Pampa",
            "Nashville","North Platte","Huron",
            "Menphis","Lamar","Bozeman", "Miles City","Cody","Sioux Falls","Sheridan"
            ,"West Yellowstone","Graybull","Billings"," Minneapolis","Salina","Logan","Idaho Falls","Lander",
            "Farson", "Bannack", "Okaton", "Bucklin", "Sioux City", "Worthington",
            "Glendo", "Scottsbluff", "Kansas City", "Peoria",
            "Pine Bluff", "Vicksburg", "Conway", "Fair Grove", "Diamond City",
            "Tuscaloosa","Meridian", "Warsaw", "Fort Wayne", "Mankato", "Sioux City",
            "Keytesville", "Orrick", "Mound Station", "Oberlin","Fleming",
            "Poplar Bluff", "Terre Haute")

Population_thousands<-c(672,481,164,682,74,315,391,
              273,
              252,59,193,6,8,253,17,
              684,24,59,
              652,4,45,9,10,174,18,
              1,2,110,414,47,51,60,8,
              2,84,34,0.8,83,1.1,
              0.2,15,481,114,
              44,23,0.8,1.4,0.7,
              99,39,15,264,42,83,
              0.4,0.8,0.2,8,15,
             17,61)
size<-rep(1,length(Cities))
CityPopularity <- data.frame(City = Cities, "Population_thousands" = Population_thousands,size=size)


plot(gvisGeoChart(CityPopularity, locationvar = "City", colorvar = "Population_thousands", sizevar = "size",
             options = list(region = "US", displayMode = "markers", resolution = "metros", 
                            enableRegionInteractivity = TRUE,
                            colors="['#00aa00','#004400']"))
)

