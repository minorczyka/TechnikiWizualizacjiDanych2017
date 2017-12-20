dane <- read.csv("danejoin.csv", fileEncoding = "UTF-8")


library(rsconnect)


rsconnect::setAccountInfo(name='kkmita', token='9B79C7970395FD0E087B1909FEA0C140', 
                          secret='NIxWoJgkgjhY0OcLG5JtAFzqCCLbS8KdQkHdnK0L')