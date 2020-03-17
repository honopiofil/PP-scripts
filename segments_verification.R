library(stringr)
setwd("~/Desktop/SilverWhisper1/")

wav_seg <- file.choose() # indicate file containig of 3 col:  wav_name seg_start seg_length
wav_dat = readLines(wav_seg)
wav_dat = as.data.frame(do.call(rbind, strsplit(wav_dat, split=" ")), stringsAsFactors=FALSE)
names(wav_dat) = c("name", "start", "length")

wav_dat$start <- as.numeric(wav_dat$start)
wav_dat$length <- as.numeric(wav_dat$length)

checknames <- function(x) { sapply(2:nrow(x), function(r) { if((x$name[r] == x$name[r-1]) && (x$start[r] < (x$start[r-1] + x$length[r-1]))) return(x$name[r])}) }
namesvec <- unique(unlist(checknames(wav_dat)))
cat(namesvec, sep="\n")
