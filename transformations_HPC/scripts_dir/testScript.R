# Set up R script from James Stegen (PNNL) R script on transformations for an HPC
# Use this version to set this up as a set of parallel processes
# step2: now do the transformation calculations
#KL 25 October 2023
library(dplyr)
library(tidyr)
args = commandArgs(trailingOnly=TRUE) #remember need this to use the args from the slurm script

#HPC - the slurm script version
in_dir <- paste0(args[1])
out_dir_summary <- paste0(args[2])

#laptop, local trouble shooting
# out_dir_summary = "C:/Users/klongnecker/Documents/Dropbox/XX_DOMsynthesis_GreeceMtg/testing/"

# Load metadata object
file_list <- paste0("samplesToProcess",".txt")
files <- read.table(file = file_list,sep="\t",header=TRUE)

# File to process based on array number
f<- as.numeric(paste0(args[3]))
current.sample <- files[f,]

#make a matrix and export the file...testing
forExport <- c(in_dir,out_dir,current.sample)
write.csv(forExport,paste("testing.csv",sep=""),quote = F,row.names = F)

