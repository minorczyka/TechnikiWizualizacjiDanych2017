library(httr)

a = GET("https://genius.com/Game-of-thrones-beyond-the-wall-script-annotated",encoding="text/html")
cc = content(a,"text")

write(cc,"s7e06.txt")

pages = c("a","b")

for (i in 1:length(pages)){
  response = GET(pages[i])
  cont = content(response,"text")
  #write content to file
}