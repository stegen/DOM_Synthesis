# Set up R script from James Stegen (PNNL) R script on transformations for an HPC
# Use this version to set this up as a set of parallel processes
# step3: go get the one-line CSV files, and concatenate them into a single CSV file
# Krista Longnecker, Woods Hole Oceanographic Institution, 26 October 2023

rm(list=ls(all=T))
library(dplyr)
library(tidyr)
args = commandArgs(trailingOnly=TRUE)

date()
paste("This is task", Sys.getenv('SLURM_ARRAY_TASK_ID'))

# Make sure path is set for HPC or laptop...depending on where this is getting run

############################
### Where are the files? ###
############################
#HPC - the hard coded version (lazy)
out_dir_summary <- "/vortexfs1/home/klongnecker/DOM_Synthesis/transformations_HPC/output_dir_summary_P/"
baseDir <- "/vortexfs1/home/klongnecker/DOM_Synthesis/transformations_HPC/"
  
# # #HPC - the slurm script version
# out_dir_summary <- paste0(args[1])
# baseDir <- paste0(args[2])

#laptop, local trouble shooting
#out_dir = "C:/Users/klongnecker/Documents/Dropbox/XX_DOMsynthesis_GreeceMtg/testing/"

############
# read samplesToProcess.txt - that will serve to compare that I have all the one-liners
# where did I put that? (in scripts_dir, not the best place but fine)
file_list <- paste0(baseDir,"samplesToProcess",".txt")
files <- read.table(file = file_list,sep="\t",header=TRUE)

# get the full list of files in a directory, files are all in out_dir and begin with 'Summary'
sumList <- list.files(out_dir_summary,pattern = "Summary_")

# #write the list of files...and just pluck it off the HPC, use this for troubleshooting
# write.csv(sumList,paste0("fileListDone",".csv",sep=""),quote = F,row.names = F)

# ##put in an error check here - do I have the same number of files as in the original list?
## NO - there are samples that will not be here - we set the required number of formulas to 
## be greater than two (dropped the upper limit), but we still have samples with no formulas
# nList = dim(files)[1]
# nFound = length(sumList)
# if(!nList == nFound){
#   stop("Something is incorrect: the list of one-liners does not match the original list of samples")
# }
# 

#first, get the first one-liner
one <- read.csv(list.files(path = out_dir_summary,sumList[1],full.names=TRUE),header=TRUE)
tot.trans = one[1,]

rm(one)

#start idx at 2 because used first file as base of matrix
for (idx in 2:length(sumList)) {
  #read the file and append to running list
  one <- read.csv(list.files(path = out_dir_summary,sumList[idx],full.names=TRUE),header=FALSE)
  tot.trans[idx,] = one[2,]
  rm(one)
}

#then export the result as a single CSV file, put the answer in baseDir
write.csv(tot.trans,paste0(baseDir,"Transformations_done_fullSet",".csv",sep=""),quote = F,row.names = F)
#