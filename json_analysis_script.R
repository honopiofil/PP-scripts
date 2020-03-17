# wczytanie zrzutu z MongoDB (po usunięciu wszelkich ObjectId i innych przeszkod) do bazy 
library(jsonlite)
getwd()
setwd("/home/pawel/Downloads/")
con <- file("201911a.json", open="r")

jsonlist <- list()
while (length(line <- readLines(con, n=1, warn = FALSE)) > 0) {
  jsonlist <- append(jsonlist, list(fromJSON(line)))
}
close(con)

jsonlist[[1]]

# z przegladu (oraz opisu Danijela na Slack'u) wynika ze najpierw sa el. zawierajace inf. o samych plikach wav oraz referencje do sporzadzonych dla nich transkrypcji
# - takich elementow jest 240, pozostale (od 241 do 1075) zawieraja transkrypcje, przy czym okazuje sie, ze niektore transkrypcje maja taki sam ref_id
# - patrz nizej przy wyszukiwaniu pokrywajacych sie segmentow

# przegladanie struktury pliku
jsonlist[[25]]$name
[1] "Call1_28_6736158610808710784_1_30_stream0"

> jsonlist[[25]]$transcripts
id     owner done disabled ref_idx
1 5dd7ddcef41a17c24b02b1a1       ASR TRUE     TRUE      NA
2 5df7d044ba8b1d2ff3fa11c6 external1 TRUE     TRUE       0
3 5e3404dab2c015cbbefff81e external1 TRUE     TRUE       1
4 5e37e9b8220622a6a21dc96c    maciej TRUE    FALSE       2

# wyszukiwanie konkretnego elementu zawierajacego dana transkrypcje
> a <- lapply(jsonlist, function(x) which(x$ref_id == "5df7d044ba8b1d2ff3fa11c6"))
> which(unlist(lapply(a, function(x) !identical(x, integer(0)))))
[1] 760
> b <- lapply(jsonlist, function(x) which(x$ref_id == "5e3404dab2c015cbbefff81e"))
> which(unlist(lapply(b, function(x) !identical(x, integer(0)))))
[1] 984

# weryfikacja ze odnalezione dotycza tego samego pliku wav
> jsonlist[[25]]$name
[1] "Call1_28_6736158610808710784_1_30_stream0"
> jsonlist[[760]]$name
[1] "Call1_28_6736158610808710784_1_30_stream0"
> jsonlist[[984]]$name
[1] "Call1_28_6736158610808710784_1_30_stream0"

# wyszukiwanie wszystkich elementow odnoszacych sie do konkretnego pliku wav
nl <- lapply(jsonlist, function(x) which(x$name == "Call1_28_6736158610808710784_1_30_stream0"))
which(unlist(lapply(nl, function(x) !identical(x, integer(0)))))

# przygotowanie ramki danych odnoszacej sie do jednej automatycznie przeparsowanej transkrypcji a skladajacej sie z inf. nt. segmentow i kanalow
timerange <- data.frame(start = jsonlist[[760]]$trans$start, end = jsonlist[[760]]$trans$end, ch = jsonlist[[760]]$trans$ch)





# procedura sprawdzenia czy we wszystkich transkrypcjach (juz automatycznie przeparsowanych) segmenty pokrywaja sie
trid <- sapply(1:240, function(i) jsonlist[[i]]$transcripts$id[2]) # znajdz nazwy el. zawierajacych automatyczne transkrypcje dla wszystkich 240 (liczba sprawdzona recznie) plikow wav w bazie
trind <- sapply(trid, function(i) which(unlist(lapply(lapply(jsonlist, function(x) which(x$ref_id == i)), function(t) !identical(t, integer(0)))))) # znajdz indeksy znalezionych powyzej el.
length(which(unlist(lapply(trind, function(x) length(x) > 1)))) # sprawdzenie ile jest "powtorzonych transkrypcji"
trind <- lapply(trind, function(x) x[1]) # zeby bral pierwsza z napotkanych transkrypcji dla ktorych jest takie samo ref_id (jesli jest ich wiecej)
segmDF <- lapply(trind, function(i) data.frame(start = jsonlist[[i]]$trans$start, end = jsonlist[[i]]$trans$end, ch = jsonlist[[i]]$trans$ch)) # przygotowanie listy ktorej elementami sa
													# ramki danych zawierajace el. jak w powyzszym timerange

# funkcja sprawdzajaca pokrywanie sie segmentow (w ramach poszczegolnych kanalow) oraz czy poczatek segmentu nie jest wieksza liczba niz koniec
checkorder <- function(x) { sapply(2:nrow(x), function(r) ((x$ch[r] == x$ch[r-1]) && (x$start[r] < x$end[r-1])) || (x$start[r] > x$end[r]) )  } 

# wyszukanie i wyswietlenie tych dla ktorych powyzsza funkcja znajdzie problematyczne pliki
orderres <- sapply(segmDF, function(x) which(checkorder(x)))
which(unlist(lapply(orderres, function(x) !identical(x, integer(0)))))
