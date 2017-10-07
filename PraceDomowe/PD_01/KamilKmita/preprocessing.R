
library(Hmisc)
library(eurostat)
library(dplyr)

#########################################
# 00 : komentarz						#
#########################################

# dane pochodza z bazy danych United Nations Economic Comission for Europe (UNECE)
# link do bazy danych : http://w3.unece.org/PXWeb/en
# a takze z bazy danych Eurostatu - dostep przez pakiet 'eurostat'


#########################################
# 01 : obrobka zbiorow z ILO			#
#########################################

### płace nominalne ###


wages <- read.csv(file = "https://raw.githubusercontent.com/kkmita/WizualizacjaDanych/master/PD_01/wages.csv",
                  header = TRUE, sep = ";", stringsAsFactors = FALSE)

contents(wages)

#1: sprawdzamy, czy nazwy pokrywaja sie z konwencja eurostat

eu_countries$name %in% wages$Country

#2: nalezy poprawic nazwe Republiki Czeskiej

wages[wages$Country=="Czechia",]$Country <- c("Czech Republic")

#3: pozbywamy sie zbednej zmiennej

filter(wages, Country %in% eu_countries$name) %>%
  select(-Indicator) -> wages

#4: sprawdzenie brakow w danych

notnull <- apply(wages, 1, function(x) sum(is.na(x)))
names(notnull) <- 1:length(notnull)

ind <- as.integer(names(notnull[notnull==0]))
ind_null <- as.integer(names(notnull[notnull!=0]))

countries_null <- wages[ind_null, "Country"]
print(countries_null)

#5: usuniecie obserwacji z brakami danych

wages <- filter(wages, ! Country %in% countries_null)


### indeks inflacji ###

prices <- read.csv(file = "https://raw.githubusercontent.com/kkmita/WizualizacjaDanych/master/PD_01/priceind.csv",
                   header = TRUE, sep = ";", stringsAsFactors = FALSE)

#1: pozbycie sie zbednej zmiennej + nazwa Rep. Czeskiej + braki danych

prices <- prices[,-c(1)]

prices[prices$Country=="Czechia",]$Country <- "Czech Republic"

prices <- filter(prices, Country %in% eu_countries$name & !(Country %in% countries_null))


#########################################
# 02 : zbior z placami realnymi			#
#########################################

#1: utworzenie zbioru
rwages <- wages


#2: korekta ze wzgledu na inflacje

for(i in 1:nrow(rwages)){
  for(j in 2:ncol(rwages)){
    rwages[i,j] <- (wages[i,j]) / (prices[i,j]/100)
  }
}

#3: ujednolicenie nazw zmiennych
colnames(rwages)[2:ncol(rwages)] <- paste("rwage", 2008:2016, sep="")

#4: przyrost procentowy

rwages <- mutate(rwages, diff_rwage = (rwage2016-rwage2009)/rwage2009 * 100 )



#########################################
# 03 : dane nt GDP z Eurostat			#
#########################################

#0: potrzebne metadane
# tabela z gdp : nama_10_gdp
# na_item == "B1GQ" - domestic product
# unit == "CP_MEUR" - current prices in mio euro

#1: kody panstw z analizowanego zbioru

filter(eu_countries, name %in% rwages$Country) %>%
  select(code) -> countries_codes

#2: tabela z gdp

get_eurostat(id = "nama_10_gdp", time_format = "num", stringsAsFactors = FALSE) %>%
  filter(geo %in% countries_codes$code & time >= 2008) %>%
  filter(na_item == "B1GQ" & unit == "CP_MEUR") %>%
  select(geo, time, values) %>%
  mutate(time = as.integer(time)) %>%
  as.data.frame() %>%
  arrange(time) %>%
  reshape(idvar="geo", timevar="time", direction="wide") -> euro_gdp

#3: uwzglednienie inflacji

for(i in 2:ncol(euro_gdp)){
  for(j in 1:nrow(euro_gdp)){
    euro_gdp[j,i] <- euro_gdp[j,i] / prices[j,i]
  }
}

#4: nazwy kolumn oraz utworzenie procentowej zmiany

colnames(euro_gdp)[2:ncol(euro_gdp)] <- paste("gdp", 2008:2016, sep="")

euro_gdp <- mutate(euro_gdp, diff_gdp = (gdp2016-gdp2009)/gdp2009 * 100)




#########################################################
# 03 : dane nt in-work at-risk-of-poverty z Eurostat	#
#########################################################

#1: sciagniecie danych

get_eurostat(id="tesov110", time_format = "num", stringsAsFactors = FALSE) %>%
  filter(geo %in% countries_codes$code & time == 2015) %>% #many missing values in 2016
  filter(wstatus == "EMP" & age == "Y_GE18" & sex == "T") %>%  #Employed, gt 18 y.old, both F and M
  select(geo, time, values) %>%
  mutate(time = as.integer(time)) %>%
  as.data.frame() %>%
  arrange(time) %>%
  reshape(idvar="geo", timevar="time", direction="wide") %>%
  rename(pov2015 = values.2015) -> euro_pov

#2: podzial na kategorie ze wzgledu na udzial pracujacych zagrozonych ubostwem
#	po kwartylach

quants <- quantile(euro_pov$pov2015, probs = seq(0, 1, 0.25), na.rm = FALSE,
                   names = TRUE)

euro_pov[,"cat_pov"] <- factor(cut2(euro_pov$pov2015, quants), 
                                labels=c("najlepiej", "dobrze", "gorzej", "najgorzej"))


#########################################################
# 04 : polaczenie zrodel danych							#
#########################################################


select(rwages, Country, diff_rwage) %>%
  left_join(eu_countries, by = c("Country" = "name")) %>%
  select(-Country) %>%
  rename(geo = code) -> rwages_merg

euro_gdp_merg <- select(euro_gdp, geo, diff_gdp)


left_join(rwages_merg, euro_gdp_merg, by = c("geo")) %>%
  left_join(eu_countries, by = c("geo" = "code")) %>%
  left_join(euro_pov, by = c("geo")) -> europe


#########################################################
# 05 : kategoryzacja ze wzgl. na czesc Europy			#
#########################################################

euro_category <- data.frame( name = europe$name, cat_geo = factor(nrow(europe)), 
                             stringsAsFactors = FALSE )

euro_category$cat_geo <- 
  as.factor( c("West", "West", "South", "South", "East", "West", "East", "North", "West", "West",
               "South", "East", "West", "South", "East", "East", "West", "West", "East", "South",
               "East", "East", "South", "South", "North", "West") )

europe <- left_join(europe, euro_category, by = c("name"))

#1: uszeregowanie zmiennych

varorder <- c("geo", "name", "diff_rwage", "diff_gdp", "cat_pov", "cat_geo")
europe <- europe[,varorder]


