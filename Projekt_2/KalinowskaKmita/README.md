# Opis projektu

Wizualizacja interaktywna dostępna jest pod adresem:<br>
https://kkmita.shinyapps.io/projekt_02_fightclub/
<br><br>
Wizualizacja dotyczy wątku miłosnego w filmie 'Fightclub'. Pozwala na analizę relacji pomiędzy dwoma głównymi bohaterami (Jack, Tyler) filmu oraz postacią kobiecą -
Marlą. Przedstawiliśmy wszystkie sceny z udziałem Marli, a interaktywne cechy projektu pozwalają na:
* filtrowanie postaci, które analizujemy
* wybór widoku: scatterplot/wykres liniowy
* wybór tła odpowiadającego emocjom w danej scenie
* widok krótkiego opisu sceny po najechaniu na punkt danych
* możliwość odczytu wybranego fragmentu scenariusza (dot. danej sceny)

<br><br>
Opisywana historia jest ciekawym studium zmian w psychice głównego bohatera, zaś powyższa wizualizacja jest pomocnym narzędziem w przedstawianiu tego procesu. 

# Dane

Dane pochodzą ze strony imsdb.com (http://www.imsdb.com/scripts/Fight-Club.html).

# Przetworzenie danych

Surowe dane przetworzyliśmy za pomocą programu `fight.ipynb`. Część informacji (np. skrótowy opis sceny) dodaliśmy manualnie.

# Wykorzystane narzędzia

W pracy nad wizualizacją używaliśmy głównie bibliotek `shiny`, `ggplot2` oraz `plotly`.
<br><br>
Przy użyciu pakietu `plotly` weszliśmy głębiej w możliwości tego narzędzia, korzystając z możliwości modyfikacji
obiektu `gp <- ggplotly(p, tooltip = c("text"))` (przetłumaczonego obiektu ggplot2) już w składni pakietu `plotly`. (plik `server.R)


