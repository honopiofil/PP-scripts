getwd()
library(tcltk)
library(emuR)
setwd("~/Desktop/SilverWhisper1/")
tg_dir <- tclvalue(tkchooseDirectory())
setwd(tg_dir)
convert_TextGridCollection(".", "ctm_out" , "emuDB")
db <- load_emuDB('emuDB/ctm_out_emuDB/')
serve(db)
#Navigate your browser to the EMU-webApp URL: https://ips-lmu.github.io/EMU-webApp/ (should happen automatically)
# Server connection URL: ws://localhost:17890
dbDisconnect()
  