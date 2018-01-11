
library(ggplot2)
library(plotly)
library(shiny)
library(dplyr)

###{0}{opis zbiorow danych}
# - danelong.csv
#   dane zawierajace tylko te sceny, w ktorych wystepuje marla, oraz udzial postaci w scenie
#   wyliczony jako liczba pojedynczych wypowiedzi - postac dluga pod ggplot2
#   UWAGA: pokazują też zerowy udział w scenie
#
# - daneflat.csv
#   postac, w ktorej udzial poszczegolnych bohaterow w danej scenie jest w kolumnach
#   'Tyler', 'Marla' itd.


###{1}{wczytanie daneflat.csv, dopisanie emocji}

daneflat <- read.csv("./dane/daneflat.csv", h = T)

# - na razie emocje wylosowane

# daneflat$emocje <- sample(c("smutek","radosc"), size = nrow(daneflat), replace = T)

###{2}{wczytanie danelong.csv, przefiltrowanie niewystepujacych obserwacji}

danelong <- read.csv("./dane/danelong.csv", h = T)


# - filtruj bohaterow, ktorych nie ma w scenie
danelong.filtr <- filter(danelong, udzial > 0)


###{3}{podlaczenie informacji o emocjach w scenie do dlugich danych}
###{!}{WYGASZONE}

# danelong %>% 
#   left_join(y = select(daneflat, scena, emocje), by = c("scena")) -> danelong
# 
# danelong.filtr %>% 
#   left_join(y = select(daneflat, scena, emocje), by = c("scena")) -> danelong.filtr


###{4}{obiekty do poprawnego wyswietlania osi x}

labele <- unique(danelong$scena) #numery scen do wyswietlenia
breaki <- seq(1, length(labele),1) #faktyczny podzial osi

# - utworz ramke danych
slownik <- data.frame(breaki = breaki, labele = labele)

# - podlacz informacje
danelong <- danelong %>% left_join(slownik, by = c("scena" = "labele"))
danelong.filtr <- danelong.filtr %>% left_join(slownik, by = c("scena" = "labele"))

###{5}{przygotowanie emocji do wyswietlania}

# - przyporzadkuj emocje do sceny - unikalne rekordy
danebins_raw <- danelong[!duplicated(danelong[,c("scena")]), c("scena","breaki")]

# - eksport do csv, dopisanie - i import

# write.csv(x = danebins_raw, file = "daneemocjeraw.csv", row.names = F)

# - odczyt czystego zbioru

danebins <- read.csv(file = "./dane/daneemocjeraw.csv", h=T)

danelong %>%
  left_join(y = select(danebins, breaki, emocje), by = c("breaki")) -> danelong

danelong.filtr %>%
  left_join(y = select(danebins, breaki, emocje), by = c("breaki")) -> danelong.filtr


# - podlacz do danebins_raw info o labelach

# - ramka danych pod geom_rect
# danebins <- data.frame(
#   xmin = danebins_raw$breaki - 0.5,
#   xmax = danebins_raw$breaki + 0.5,
#   ymin = 0,
#   ymax = 1,
#   kol = danebins_raw$emocje
# )

###{6}{sceny - zapis scenariusza}

danesceny <- read.csv("./dane/danesceny2.txt", h=T, stringsAsFactors = FALSE)


###{7}{csvka - do zapisania wypowiedzi}

# write.csv(x = select(danelong.filtr, scena, postac), file = "daneopis.csv", 
#           row.names = FALSE, quote = FALSE)


###{7.1}{wczytanie dane z opisem wypowiedzi}

daneopis <- read.table("./dane/daneopis.csv", h=T, sep=",", encoding = "UTF-8")

###{8}{połącznie}

danelong.filtr <- danelong.filtr %>% left_join(daneopis, by = c("scena", "postac"))
daneopis <- read.table("./dane/daneopis.csv", h=T, sep=",")
