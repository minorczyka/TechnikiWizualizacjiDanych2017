

library("ggplot2")
library("ggrepel")

############################################
# 01: wczytanie danych z 'preprocessing.R' #
############################################

europe <- read.csv(file = "https://raw.githubusercontent.com/kkmita/WizualizacjaDanych/master/PD_01/europe.csv",
                      header=TRUE, sep=",", stringsAsFactors = FALSE)

europe$cat_pov <- factor(europe$cat_pov, levels = c("najlepiej", "dobrze",
                                                    "gorzej", "najgorzej"))
europe$cat_geo <- as.factor(europe$cat_geo)



attach(europe)


############################################
# WYKRES 1 : GDP ~ place                   #
############################################


ggplot(europe, aes(x=diff_rwage, y=diff_gdp, color=cat_geo, label=name)) +
  geom_point(size=2) +
  geom_text_repel(data=filter(europe, name %in% c("Ireland", "Luxembourg", 
              "United Kingdom", "Bulgaria", "Greece"))) +
  scale_x_continuous(limits = c(-35, 50), breaks = seq(-30, 50, 10),
                     labels=paste(seq(-30,50,10), "%", sep="")) +
  scale_y_continuous(limits = c(-35, 50), breaks = seq(-30, 50, 10),
                     labels=paste(seq(-30,50,10), "%", sep="")) +
  labs(colour="part of Europe", x="Zmiana % : płaca realna", y="Zmiana % : PKB",
       title = "Zależność między przyrostem PKB oraz płac w ujęciu realnym",
       subtitle = "pomiędzy 2009 a 20016") +
  geom_vline(color="black", alpha=0.4, xintercept=0) +
  geom_hline(color="black", alpha=0.4, yintercept=0)


#######################################################
# WYKRES 2 : PKB ~ place || facet ~ polozenie geogr.  #
#######################################################


ggplot(europe, aes(x=diff_rwage, y=diff_gdp, label=name)) +
  scale_x_continuous(limits = c(-50, 50), breaks = seq(-25, 25, 25),
                     labels=paste(seq(-25,25,25), "%", sep="")) +
  scale_y_continuous(limits = c(-50, 50), breaks = seq(-25, 50, 25),
                     labels=paste(seq(-25,50,25), "%", sep="")) +
  geom_vline(color="black", alpha=0.4, xintercept=0) +
  geom_hline(color="black", alpha=0.4, yintercept=0) +
  labs(x="Zmiana % : płaca realna", y="Zmiana % : PKB", title="Zależność PKB ~ przyrostu płac w ujęciu realnym",
        subtitle="rozbicie ze wzgl. na położenie geograficzne", caption="na czerwono wyróżniono państwa z analizowanej grupy") +
  stat_ellipse(color=alpha("black",0.3)) +
  geom_point(data=europe[,-c(7)], size=1, color="black", alpha=0.7) +
  geom_point(size=1.5, color="red") +
  facet_wrap(~cat_geo)


#############################################################
# WYKRES 3 : GDP ~ working poverty   #
#############################################################


ggplot(europe, aes(x=cat_pov, y=diff_rwage)) + 
  geom_boxplot(aes(x=cat_pov, y=diff_rwage), alpha=0.1, outlier.alpha=0) +
  geom_jitter(aes(x=cat_pov, y=diff_rwage, color=cat_geo), width=0.2, size=2) +
  geom_text_repel(aes(label=name, color=cat_geo), data=filter(europe, 
                                      name %in% c("Romania", "Greece", "Luxembourg", "Bulgaria")
                                    )) +
labs(x="grupa kwartylowa wg. at-risk of poverty", y="Zmiana % : płaca realna", 
     title="Rozkład zmian % płac realnych wg. grup kwartylowych at-risk of poverty")
 

#############################################################
# WYKRES 3 : GDP ~ working poverty || polozenie geograf.    #
#############################################################

ggplot(europe, aes(x=cat_pov, y=diff_gdp, label=name)) +
  geom_boxplot(aes(x=cat_pov, y=diff_rwage), alpha=0.1, outlier.alpha=0) +
  geom_jitter(aes(x=cat_pov, y=diff_rwage, color=cat_geo), width=0.2, size=2) +
  geom_text(data=filter(europe, name %in% c("Slovakia", "Czech Republic",
                                                "Finland", "Sweden", "Croatia")),
                  aes(label=name, color=cat_geo)) +
  labs(x="grupa kwartylowa wg. at-risk of poverty", y="Zmiana % : płaca realna", 
       title="Rozkład zmian % płac realnych wg. grup kwartylowych at-risk of poverty",
       subtitle="ze wzgl. na położenie geograficzne") +
  facet_wrap(~cat_geo)

