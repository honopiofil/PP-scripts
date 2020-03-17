setwd("~/Desktop/SilverWhisper1/")
ctm <- file.choose()
max_length <- 1.25
max_longs_content <- 0.04

{
ctm_file <- readLines(ctm)
ctm_dat <- as.data.frame(do.call(rbind, strsplit(ctm_file, split=" ")), stringsAsFactors=FALSE)
names(ctm_dat) <- c("name", "role", "start", "length", "word")

ctm_dat$start <- as.numeric(ctm_dat$start)
ctm_dat$length <- as.numeric(ctm_dat$length)

# names <- unique(ctm_dat$name) 

ctm_dat_list <- split(ctm_dat, f = ctm_dat$name)

lenghts_list <- lapply(ctm_dat_list, function(x){
  return(list("wordno" = nrow(x),  "mean" = mean(x$length), "number" = length(which(x$length > max_length))))
})

cond <- sapply(lenghts_list, function(x) (x$number/x$wordno) > max_longs_content )
cond_list <- names(which(cond))
#cat(cond_list, sep='\n')

bad_list <- sapply(cond_list, function(cnd_name) {
  ind = which(names(lenghts_list) == cnd_name)
  lenghts_list[[ind]]$number / lenghts_list[[ind]]$wordno
})

blDF <- as.data.frame(bad_list)

blDF[order(blDF[,"bad_list"], decreasing = TRUE), , drop = FALSE]
}

