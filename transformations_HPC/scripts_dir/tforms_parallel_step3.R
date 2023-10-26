# Set up R script from James Stegen (PNNL) R script on transformations for an HPC
# Use this version to set this up as a set of parallel processes
# step1 - just opens the files, but now I have to get rid of the hacks about 
#passing arguments by slurm; this is the final step of the parallelized version
#Go get the one-line CSV files, and concatanate them into a single CSV file
#KL 26 October 2023

# Make sure path is set for HPC or laptop...depending on where this is getting run
args = commandArgs(trailingOnly=TRUE)
library(dplyr)
library(tidyr)

date()
paste("This is task", Sys.getenv('SLURM_ARRAY_TASK_ID'))


############################
### Where are the files? ###
############################
#HPC - the hard coded version (lazy)
#in_dir <- "/proj/omics/kujawinski/data/DOMsynthesis"
#out_dir <- "/vortexfs1/home/klongnecker/DOM_Synthesis/transformations_HPC/output_dir_parallel/"
#HPC - the slurm script version
in_dir <- paste0(args[1])
out_dir <- paste0(args[2])

#laptop, local trouble shooting
# in_dir <- "C:/Users/klongnecker/Documents/Dropbox/XX_DOMsynthesis_GreeceMtg/_data_from_2"
# out_dir = "C:/Users/klongnecker/Documents/Dropbox/XX_DOMsynthesis_GreeceMtg/testing/"
