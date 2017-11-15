library("rvest")
library("httr")
library("jsonlite")
library("ggplot2")
library("stringi")
library("ggthemes")
library("ggmap")
library("sqldf")
library("grid")
library("gridExtra")
# Chcemy przedstawić opóźnienia linii które dojeżdżają do Politechniki
# Stwierdziłyśmy, że interesujący będzie podział Warszawy na dzielnice, a w naszym 
# przypadku skumulowane dzielnice przedstawiające kierunki. Tym samym możemy sprawdzić, 
# czy któryś z kierunków ma przewagę konkurencyjną w dowożeniu pasażerów bez opóźnień.

#setwd("C:\\Users\\Majka\\Documents\\MINI\\techniki")
#setwd("C:/Users/Karola/Documents/Materiały/Magisterka/Techniki Wizualizacji Danych/Projekt1")

# Zaczynamy od zdefiniowania, które linie są interesujące dla naszego zagadnienia

linie <- "167,174,182,187,188,523,10,14,15,131,501,519,522,700,143,411,502,514,520,525,151,118,17,33,159,181,4,18,35"
token2 <- "35dbb2ebd27b23cfbec359dbd560adf2d4a5b27b"

# wyciagamy pełne dane
res_full <- GET(url = paste0("https://vavel.mini.pw.edu.pl/api/vehicles/v1/full/?line=", linie),
           add_headers(Authorization = paste("Token", token2)))
dane_full<-jsonlite::fromJSON(as.character(res_full))
dane_full<-do.call(cbind.data.frame, dane_full)

# dodajemy nowe zmienne 

# dzielnica - mówi nam, do jakiej grupy dzielnic zaliczamy daną linię
# Ponieważ wiele studentów jadąc na PW korzysta z takich przystankóW jak pl. Konstytucji,
# Metro Politechnika, GUS, Nowowiejska, czy Koszykowa, postanowiłyśmy także je uwzględnić.

# w tym celu obrysowałyśmy wszystkie te przystanki prostokątem zawierającym tylko je 
# i żadnego innego przystanku. 
# Ponadto, chcemy śledzić tylko te autobusy, które nie przejechały jeszcze tego obszaru 
# w tym celu potrzebujemy współrzędnych wierzchołka oraz informacji którędy wjeżdża/ wyjeżdza 
# dany autobus/tramwaj

# kierunek - koduje, skąd dana linia wieżdża do obszaru PW

kierunek<-rep("x",nrow(dane_full))
dzielnica<-rep("dzielnica_0",nrow(dane_full))

for(i in 1:nrow(dane_full)){
  if (dane_full$line[i]=='167' & dane_full$courseDirection[i]=='Siekierki-Sanktuarium') {
    dzielnica[i]='Bemowo, Wola, Ochota, Ursus, Włochy'
    kierunek[i]="L"
  }
  if (dane_full$line[i]=='174' & dane_full$courseDirection[i]=='Bokserska') {
    dzielnica[i]='Śródmieście'
    kierunek[i]="G"
  }
  if (dane_full$line[i]=='182' & dane_full$courseDirection[i]=='Witolin') {
    dzielnica[i]='Bemowo, Wola, Ochota, Ursus, Włochy'
    kierunek[i]="L"
  }
  if (dane_full$line[i]=='187' & dane_full$courseDirection[i]=='Ursus-Niedźwiadek') {
    dzielnica[i]='Mokotów, Ursynów, Wilanów'
    kierunek[i]="P"
  }
  if (dane_full$line[i]=='188' & dane_full$courseDirection[i]=='Gocławek Wschodni') {
    dzielnica[i]='Bemowo, Wola, Ochota, Ursus, Włochy'
    kierunek[i]="P"
  }
  if (dane_full$line[i]=='523' & dane_full$courseDirection[i]=='Stare Bemowo') {
    dzielnica[i]='Wawer, Wesoła, Rembertów, Praga Pd.'
    kierunek[i]="P"
  }
  if (dane_full$line[i]=='10' & dane_full$courseDirection[i]=='os.Górczewska'){
    
   dzielnica[i]='Mokotów, Ursynów, Wilanów'
   kierunek[i]="P"
  }
  if (dane_full$line[i]=='14' & dane_full$courseDirection[i]=='Banacha'){
   dzielnica[i]='Mokotów, Ursynów, Wilanów'
   kierunek[i]="P"
  }
  if (dane_full$line[i]=='15' & dane_full$courseDirection[i]=='Marymont-Potok') {
    dzielnica[i]='Bemowo, Wola, Ochota, Ursus, Włochy'
    kierunek[i]="L"
  }
    if (dane_full$line[i]=='131' & dane_full$courseDirection[i]=='Dw.Centralny') {
      dzielnica[i]='Mokotów, Ursynów, Wilanów'
      kierunek[i]="D"
    }
  if (dane_full$line[i]=='501' & dane_full$courseDirection[i]=='Dw.Centralny') {
    dzielnica[i]='Mokotów, Ursynów, Wilanów'
    kierunek[i]="D"}
  if (dane_full$line[i]=='519' & dane_full$courseDirection[i]=='Dw.Centralny') {
    dzielnica[i]='Mokotów, Ursynów, Wilanów'
    kierunek[i]="D"}
  if (dane_full$line[i]=='522' & dane_full$courseDirection[i]=='Branickiego') {
    dzielnica[i]='Śródmieście'
    kierunek[i]="G"}
    if (dane_full$line[i]=='700' & dane_full$courseDirection[i]=='Dw.Centralny') {
      dzielnica[i]='Mokotów, Ursynów, Wilanów'
      kierunek[i]="D"}
  if (dane_full$line[i]=='143' & dane_full$courseDirection[i]=='GUS') {
    dzielnica[i]='Wawer, Wesoła, Rembertów, Praga Pd.'
    kierunek[i]="P"}
  if (dane_full$line[i]=='411' & dane_full$courseDirection[i]=='Stara Miłosna') {
    dzielnica[i]='Śródmieście'
    kierunek[i]="X"}
  if (dane_full$line[i]=='502' & dane_full$courseDirection[i]=='Stara Miłosna') {
    dzielnica[i]='Śródmieście'
    kierunek[i]="x"}
  if (dane_full$line[i]=='514' & dane_full$courseDirection[i]=='Wola Grzybowska') {
    dzielnica[i]='Śródmieście'
    kierunek[i]="x"}
  if (dane_full$line[i]=='520' & dane_full$courseDirection[i]=='Marysin') {
    dzielnica[i]='Bemowo, Wola, Ochota, Ursus, Włochy'
    kierunek[i]="G"}
  if (dane_full$line[i]=='525' & dane_full$courseDirection[i]=='Dw.Centralny') {
    dzielnica[i]='Wawer, Wesoła, Rembertów, Praga Pd.'
    kierunek[i]="P"}
  if (dane_full$line[i]=='151' & dane_full$courseDirection[i]=='Rechniewskiego') {
    dzielnica[i]='Śródmieście'
  kierunek[i]="x"}
  if (dane_full$line[i]=='118' & dane_full$courseDirection[i]=='Metro Politechnika') {
    dzielnica[i]='Białołęka, Bielany, Żoliborz, Targówek, Praga Pn.'
  kierunek[i]="G"}
  if (dane_full$line[i]=='17' & dane_full$courseDirection[i]=='Tarchomin Kościelny') {
    dzielnica[i]='Mokotów, Ursynów, Wilanów'
  kierunek[i]="D"}
  if (dane_full$line[i]=='33' & dane_full$courseDirection[i]=='Kielecka') {
    dzielnica[i]='Białołęka, Bielany, Żoliborz, Targówek, Praga Pn.'
  kierunek[i]="G"}
  if (dane_full$line[i]=='159' & dane_full$courseDirection[i]=='CH Blue City') {
    dzielnica[i]='Mokotów, Ursynów, Wilanów'
  kierunek[i]="G"}
  if (dane_full$line[i]=='4' & dane_full$courseDirection[i]=='Wyścigi') {
    dzielnica[i]='Białołęka, Bielany, Żoliborz, Targówek, Praga Pn.'
  kierunek[i]="G"}
  if (dane_full$line[i]=='18' & dane_full$courseDirection[i]=='Woronicza') {
    dzielnica[i]='Białołęka, Bielany, Żoliborz, Targówek, Praga Pn.'
  kierunek[i]="G"}
  if (dane_full$line[i]=='35' & dane_full$courseDirection[i]=='Nowe Bemowo') {
    dzielnica[i]='Mokotów, Ursynów, Wilanów'
  kierunek[i]="P"}
  
  if (dane_full$line[i]=='167' & dane_full$courseDirection[i]=='Znana') {
    dzielnica[i]='Mokotów, Ursynów, Wilanów'
  kierunek[i]="D"}
  if (dane_full$line[i]=='174' & dane_full$courseDirection[i]=='Rondo ONZ') {
    dzielnica[i]='Mokotów, Ursynów, Wilanów'
  kierunek[i]="D"}
  if (dane_full$line[i]=='182' & dane_full$courseDirection[i]=='Dw.Zachodni') {
    dzielnica[i]='Wawer, Wesoła, Rembertów, Praga Pd.'
  kierunek[i]="P"}
  if (dane_full$line[i]=='187' & dane_full$courseDirection[i]=='Stegny') {
    dzielnica[i]='Bemowo, Wola, Ochota, Ursus, Włochy'
  kierunek[i]="L"}
  if (dane_full$line[i]=='188' & dane_full$courseDirection[i]=='Lotnisko Chopina') {
    dzielnica[i]='Wawer, Wesoła, Rembertów, Praga Pd.'
  kierunek[i]="L"}
  if (dane_full$line[i]=='523' & dane_full$courseDirection[i]=='PKP Olszynka Grochowska') {
    dzielnica[i]='Bemowo, Wola, Ochota, Ursus, Włochy'
  kierunek[i]="L"}
  if (dane_full$line[i]=='10' & dane_full$courseDirection[i]=='Wyścigi') {
    dzielnica[i]='Bemowo, Wola, Ochota, Ursus, Włochy'
  kierunek[i]="G"}
  if (dane_full$line[i]=='14' & dane_full$courseDirection[i]=='Metro Wilanowska') {
    dzielnica[i]='Bemowo, Wola, Ochota, Ursus, Włochy'
  kierunek[i]="L"}
  if (dane_full$line[i]=='15' & dane_full$courseDirection[i]=='P+R Al.Krakowska') {
    dzielnica[i]='Białołęka, Bielany, Żoliborz, Targówek, Praga Pn.'
  kierunek[i]="P"}
  if (dane_full$line[i]=='131' & dane_full$courseDirection[i]=='Sadyba') {
    dzielnica[i]='Śródmieście'
  kierunek[i]="G"}
  if (dane_full$line[i]=='501' & dane_full$courseDirection[i]=='Stegny') {
    dzielnica[i]='Śródmieście'
  kierunek[i]="G"}
  if (dane_full$line[i]=='519' & dane_full$courseDirection[i]=='Powsin-Park Kultury') {
    dzielnica[i]='Śródmieście'
  kierunek[i]="G"}
  if (dane_full$line[i]=='522' & dane_full$courseDirection[i]=='Dw.Centralny') {
    dzielnica[i]='Mokotów, Ursynów, Wilanów'
  kierunek[i]="D"}
  if (dane_full$line[i]=='700' & dane_full$courseDirection[i]=='Pańska') {
    dzielnica[i]='Śródmieście'
  kierunek[i]="G"}
  if (dane_full$line[i]=='143' & dane_full$courseDirection[i]=='Rembertów-Kolonia') {
    dzielnica[i]='Śródmieście'
  kierunek[i]="X"}
  if (dane_full$line[i]=='411' & dane_full$courseDirection[i]=='Metro Politechnika') {
    dzielnica[i]='Wawer, Wesoła, Rembertów, Praga Pd.'
  kierunek[i]="P"}
  if (dane_full$line[i]=='502' & dane_full$courseDirection[i]=='Metro Politechnika') {
    dzielnica[i]='Wawer, Wesoła, Rembertów, Praga Pd.'
  kierunek[i]="P"}
  if (dane_full$line[i]=='514' & dane_full$courseDirection[i]=='Metro Politechnika') {
    dzielnica[i]='Wawer, Wesoła, Rembertów, Praga Pd.'
  kierunek[i]="P"}
  if (dane_full$line[i]=='520' & dane_full$courseDirection[i]=='Płocka-Szpital') {
    dzielnica[i]='Wawer, Wesoła, Rembertów, Praga Pd.'
  kierunek[i]="P"}
  if (dane_full$line[i]=='525' & dane_full$courseDirection[i]=='Międzylesie') {
    dzielnica[i]='Śródmieście'
  kierunek[i]="G"}
  if (dane_full$line[i]=='151' & dane_full$courseDirection[i]=='Nowowiejska') {
    dzielnica[i]='Wawer, Wesoła, Rembertów, Praga Pd.'
  kierunek[i]="P"}
  if (dane_full$line[i]=='118' & dane_full$courseDirection[i]=='Bródno-Podgrodzie') {
    dzielnica[i]='Śródmieście'
  kierunek[i]="X"}
  if (dane_full$line[i]=='17' & dane_full$courseDirection[i]=='Woronicza') {
    dzielnica[i]='Białołęka, Bielany, Żoliborz, Targówek, Praga Pn.'
  kierunek[i]="G"}
  if (dane_full$line[i]=='33' & dane_full$courseDirection[i]=='Metro Młociny') {
    dzielnica[i]='Mokotów, Ursynów, Wilanów'
  kierunek[i]="D"}
  if (dane_full$line[i]=='159' & dane_full$courseDirection[i]=='EC Siekierki') {
    dzielnica[i]='Bemowo, Wola, Ochota, Ursus, Włochy'
  kierunek[i]="L"}
  if (dane_full$line[i]=='4' & dane_full$courseDirection[i]=='Żerań Wschodni') {
    dzielnica[i]='Mokotów, Ursynów, Wilanów'
  kierunek[i]="P"}
  if (dane_full$line[i]=='18' & dane_full$courseDirection[i]=='Ratuszowa-ZOO') {
    dzielnica[i]='Mokotów, Ursynów, Wilanów'
  kierunek[i]="P"}
  if (dane_full$line[i]=='35' & dane_full$courseDirection[i]=='Wyścigi') {
    dzielnica[i]='Białołęka, Bielany, Żoliborz, Targówek, Praga Pn.'
  kierunek[i]="G"}
}

# 'doklejamy' potrzebne nam informacje do pierwotnej ramki danych
dane<-cbind(dane_full, dzielnica,kierunek)

# wybieramy tylko te kursy, które jeszcze nie minęły okolic PW

kier_L<- dane[which(dane$kierunek=="L"),]
nieprzjechly_z_kier_L<- kier_L[-which(kier_L$lon>21.029877),]
kier_P<- dane[which(dane$kierunek=="P"),]
nieprzjechly_z_kier_P<- kier_P[-which(kier_P$lon<21.0137),]
kier_G<- dane[which(dane$kierunek=="G"),]
nieprzjechly_z_kier_G<- kier_G[-which(kier_G$lat<52.20889),]
kier_D<- dane[which(dane$kierunek=="D"),]
nieprzjechly_z_kier_D<- kier_D[-which(kier_D$lat>52.22713),]

# ramka danych
dane_przed_przyjazdem<-rbind(nieprzjechly_z_kier_D,nieprzjechly_z_kier_G,nieprzjechly_z_kier_P,nieprzjechly_z_kier_L)

# wybieramy tylko interesujące nas zmienne 
# colnames(dane_przed_przyjazdem)
dane_wykres <- dane_przed_przyjazdem[,c(2,4,5,9,29,36,37)]
dane_wykres$delay <- round(dane_wykres$delay/60,0)
# "line" "delay" "dzielnica" "timetableStatus" kierunek" i jeszcze wspł. GPS do mapki

# liczę średnią dla linii w dzielnicy
d <- aggregate(dane_wykres$delay,by=list(dane_wykres$dzielnica,dane_wykres$line),FUN="mean",data=dane_wykres)
colnames(d) <- c("dzielnica","line","delay")
d$line <- as.factor(d$line)
tram <- c(10,14,15,17,35,18,4,33)
d$typ <- ifelse(d$line %in% tram,"tramwaj",ifelse(d$line %in% c(523,501,519,522,700,411,502,514,520,525),"autobus pospieszny", "autobus zwykły"))
d$delay <- round(d$delay,0)

godzina <- Sys.time() #dokładna godzina, w której pobieramy dane

#teraz wyliczamy średnią dla każdej linii w każdej dzielnicy z ostatnich
# 7 dni:

wzor <- paste0("^ZTM_",format(Sys.Date()-7,"%Y_%m_%d"))

# lista_plikow <- list.files("C:\\Users\\Kinga\\Desktop\\proj1", pattern="ZTM_")
# lista_plikow_adresy <- list.files("C:\\Users\\Kinga\\Desktop\\proj1", pattern="ZTM_",full.names = TRUE)
lista_plikow <- list.files("C:\\Users\\Karola\\Desktop\\proj1", pattern="ZTM_")
lista_plikow_adresy <- list.files("C:\\Users\\Karola\\Desktop\\proj1", pattern="ZTM_",full.names = TRUE)

do_sr <- which(stri_detect_regex(lista_plikow,wzor))
do_sr <- do_sr[1]:length(lista_plikow)
lista_plikow_adresy <- lista_plikow_adresy[do_sr] #adresy plików nas interesujacych
# - potrzebne do wczytania
do_sr <- lista_plikow[do_sr] #interesująca nas lista plików 7 dni wstecz

# teraz musimy wyciągnąc interesującą nas godzine wraz z indeksami plików, które
# chcemy wczytać:
godz_plik <- which(substr(do_sr,start=16,stop=17)==substr(godzina,start=12,stop=13))

# tworzymy ramkę danych ze średnimi:
plik2 <- data.frame()
for(i in 1:length(godz_plik))
{
  plik <- read.csv(lista_plikow_adresy[godz_plik[i]],header=T)
  plik2 <- rbind(plik,plik2)
}

#plik2 - ramka danych, zawierająca obserwacje z 7 dni wstecz dla ustalonej godziny
plik2_wykres <- plik2[,c(3,10,37)]
#colnames(plik2) #3,10,30,37,38 - to są te same kolumny, co dla dane_przed_przyjazdem, 
#przesunięcie, bo mamy "X" w tej ramce danych

# wyliczamy średnią dla każdej linii w każdej dzielnicy - dla 7 ostatnich dni
# dla wybranej przez nas godziny - czyli chwili, w której pobieramy dane
p <- aggregate(plik2_wykres$delay,by=list(plik2_wykres$dzielnica,plik2_wykres$line),FUN="mean",data=plik2_wykres)
colnames(p) <- c("dzielnica","line","delay")
p$line <- as.factor(p$line)
p$delay <- round(p$delay/60,0)
tram <- c(10,14,15,17,35,18,4,33)
p$typ <- ifelse(p$line %in% tram,"tramwaj",ifelse(p$line %in% c(523,501,519,522,700,411,502,514,520,525),"autobus pospieszny", "autobus zwykły"))

# może zdarzyć się tak, że mamy np. weekend i niektóre kursy nie jeżdżą
# albo coś innego. musimy zatem dopasować ramkę danych p do ramki danych d - 
# tak, aby móc p nanieść na wykres z d - chodzi o liczbę wierszy generalnie:
# nrow(p) #48
# nrow(d) #43
# np. w danej chiwli nie ma 159 w d, a w p jest

dane_wykres_srednia_teraz<-sqldf("SELECT dw.line, dw.delay, dw.dzielnica, d.delay as delay_sr_teraz, d.typ FROM dane_wykres dw
            LEFT JOIN d ON dw.dzielnica=d.dzielnica and dw.line=d.line")

dane_wykres_tydzien<-sqldf("SELECT d.*, p.delay as delay_sr_tydzien  FROM dane_wykres_srednia_teraz d
            LEFT JOIN p ON d.dzielnica=p.dzielnica and d.line=p.line")

#wyrzucamy z wykresu kursy, które są spóźnione ponad godzinę - aby poprawić czytelność 
wyrzuc <- which(dane_wykres_tydzien$delay>60)
if(length(wyrzuc>0))
{
  dane_wykres_tydzien <- dane_wykres_tydzien[-wyrzuc,]
}

slupki <- ggplot(dane_wykres_tydzien,aes(x=line,y=delay_sr_teraz,fill=typ))+
  geom_col(aes(x=line,y=delay_sr_teraz))+
  geom_point(aes(x=line,y=delay))+
  geom_jitter()+
  scale_fill_manual(values=c("skyblue","#dfc27d","#f1b6da"))+
  facet_wrap(~dzielnica,scales="free",nrow=length(unique(dane_wykres_tydzien$dzielnica)))+
  labs(x="Linie",y="Opóźnienie (min.)")+
  theme_economist_white(base_size=10,gray_bg=FALSE)+
  geom_errorbar(aes(ymin=delay_sr_tydzien,ymax=delay_sr_tydzien),size=1,col="#5e3c99")

### teraz rysujemy mapkę:

pospieszna<-c(523,501,519,522,411,502,514,520,525)
dane_wykres$opóźnieniek <- ifelse(dane_wykres$line %in% tram,"T","A")
dane_wykres$opóźnieniek2 <- ifelse(dane_wykres$line %in% pospieszna,"P",dane_wykres$opóźnieniek)

#pobieram mapę
k<-get_map(location = c(lon = 21, lat = 52.22),zoom=12, maptype = "toner-lite")
# wszystkie nazwy toner- . . .  są  czarno białe ale lit chyba najlepsze
dane_wykres$typ_pojazdu<-ifelse(dane_wykres$opóźnieniek2=="T","tramwaj","autobus")
dane_wykres$typ_pojazdu<-ifelse(dane_wykres$opóźnieniek2=="P","linia pospieszna",dane_wykres$typ_pojazdu)
legend_title <- "opóźnienie w min"

dane_wykres$opkate<-ifelse(dane_wykres$delay>0,"do 5 min","przed czasem")
dane_wykres$opkate<-ifelse(dane_wykres$delay>5,"5-10 min",dane_wykres$opkate)
dane_wykres$opkate<-ifelse(dane_wykres$delay>10,"10-20 min",dane_wykres$opkate)
dane_wykres$opkate<-ifelse(dane_wykres$delay>20,"powyżej 20 min",dane_wykres$opkate)

cols <- c("powyżej 20 min" = "#d73027", "10-20 min" = "red", "5-10 min" = "orange", "do 5 min" = "yellow","przed czasem" = "#a6d96a")


mapa <- ggmap(k)+
  geom_point(aes(x = lon, y = lat,fill=opkate),
             data = dane_wykres,size=4,colour="black",pch=22)+
  geom_text(data = dane_wykres, aes(x = lon, y = lat, label = opóźnieniek2), 
            size = 3, vjust = 0.4, hjust = 0.3,color="black")+
  scale_fill_manual(name="opóźnienia",values=cols)+
  ggtitle("Jak bardzo spóźnisz się na PW, mieszkajac w podanych dzielnicach \n Warszawy?",subtitle=paste0("stan na: ",godzina)) + 
  theme(plot.title = element_text(lineheight=.8, face="bold"))+
  theme(axis.line=element_blank(),
        axis.text.x=element_blank(),
        axis.text.y=element_blank(),
        axis.ticks=element_blank(),
        axis.title.x=element_blank(),
        axis.title.y=element_blank(),
        panel.background=element_blank(),
        panel.border=element_blank(),
        panel.grid.major=element_blank(),
        panel.grid.minor=element_blank(),
        plot.background=element_blank())


grid.arrange(grobs=list(mapa, slupki), ncol = 2, main = tytul)

