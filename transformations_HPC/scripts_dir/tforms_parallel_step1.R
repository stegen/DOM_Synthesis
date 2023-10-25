# Set up R script from James Stegen (PNNL) R script on transformations for an HPC
# Use this version to set this up as a set of parallel processes
# step1 - just opens the files, but now I have to get rid of the hacks about 
#passing arguments by slurm
#KL 25 October 2023

# Make sure path is set for HPC or laptop...depending on where this is getting run
args = commandArgs(trailingOnly=TRUE)
library(dplyr)
library(tidyr)

date()
paste("This is task", Sys.getenv('SLURM_ARRAY_TASK_ID'))

#this will get used later as part of folder names, just leave for now
Sample_Name = 'DOM_Syn_Trans'

#######################
### Loading in data ###
#######################
#HPC - the hard coded version (lazy)
#in_dir <- "/proj/omics/kujawinski/data/DOMsynthesis"
#out_dir <- "/vortexfs1/home/klongnecker/DOM_Synthesis/transformations_HPC/output_dir_parallel/"
#HPC - the slurm script version
in_dir <- paste0(args[1])
out_dir <- paste0(args[2])

#laptop, locl trouble shooting
# in_dir <- "C:/Users/klongnecker/Documents/Dropbox/XX_DOMsynthesis_GreeceMtg/_data_from_2"
# out_dir = "C:/Users/klongnecker/Documents/Dropbox/XX_DOMsynthesis_GreeceMtg/testing/"

# Loading in ICR data (data here: in_dir)
data = read.csv(list.files(path = in_dir,pattern = "DOM_Synthesis_Data_Trim.csv",full.names=TRUE), row.names = 1) # Keeping data and mol-data seperate to ensure they are unaltered
mol = read.csv(list.files(path = in_dir,pattern = "DOM_Synthesis_Mol_Trim",full.names=TRUE), row.names = 1)

# Loading in transformations
trans.full =  read.csv(list.files(path = in_dir,pattern= "Transformation_Database_07-2020.csv",full.names=TRUE))
trans.full$Name = as.character(trans.full$Name)

# ############# #
#### Errors ####
# ############ #

# Checking row names consistency between molecular info and data
if(identical(x = row.names(data), y = row.names(mol)) == FALSE){
  stop("Something is incorrect: the mol. info and peak counts don't match")
}

# Checking to ensure ftmsRanalysis was run
if(length(which(mol$C13 == 1)) > 0){
  stop("Isotopic signatures weren't removed")
}

# Probably not necessary, but checking for presence/absence
if(max(data) > 1){
  print("Data was not presence/absence")
  data[data > 0] = 1
}



