# Use this as a model for some R script to come from James to run the transformations
args = commandArgs(trailingOnly=TRUE)
suppressMessages(library(xcms))

date()
paste("This is task", Sys.getenv('SLURM_ARRAY_TASK_ID'))

usePath <- paste0(args[1])
ext <- ".mzML"
pre <- paste0(usePath,"/")

# Input dir
input_dir <- paste0(args[1])

# Output dir
output_dir<- paste0(args[2])

# Biocparallel setting
register(BPPARAM = MulticoreParam(workers=36))


## List all peak picked files and sort order by file number
#input <- mixedsort(list.files(input_dir, pattern = glob2rx(paste0("xcms1-",ionMode,"*",ext)), full.names = T),decreasing=T)

## Combine into single object
#input_l <- lapply(input, readRDS)
#xset <- input_l[[1]]
#for(i in 2:length(input_l)) {
#  set <- input_l[[i]]
#  xset <- c(xset, set)
#  print(i)
#  }
#rm(input,input_l)

## Save as R object
#save(list=c("xset"), file = paste0(input_dir,"/xset-",ionMode,".RData"))

date()
