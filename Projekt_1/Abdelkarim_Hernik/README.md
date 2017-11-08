#Projekt 1
###Ahmed Abdelkarim, Aleksandra Hernik

Skrypt trams.R należy wywołać podając do niego parametry stop - wyróżnioną stację, line - interesującą nas linię, oraz direction - interesujący nas kierunek tramwaju.
Przykładowe wywołanie:
Rscript trams.R "Metro Politechnika" 10 Wyścigi
Wygeneruje mapkę dla osoby zainteresowanej losami tramwajów 10 w kierunku Wyścigi i zaznaczy innym kolorem stację Metro Politechnika. Wygenerowany zostanie plik plot.png, który należy otworzyć.
Załączone zostały skrypty trams.sh i trams.bat (odpowiednio Linux i Windows, dodatkowo trams_win.sh dla Windowsa z rozszerzeniami Linuxowymi), które po uruchomieniu skryptu dodatkowo otwierają obrazek.
Jeśli system nie wykrywa Rscript, można otworzyć konsolę za pomocą RStudio (Tools -> Shell...) - wtedy w tak otwartej konsoli Rscript powinien być wykrywany.
Ewentualnie można po prostu uruchomić skrypt przez RStudio i zastąpić linie 35-37 wybranymi wartościami :)