# Set up R script from James Stegen (PNNL) R script on transformations for an HPC
# Use this version to set this up as a set of parallel processes
# step2: now do the transformation calculations
#KL 25 October 2023
library(dplyr)
library(tidyr)
args = commandArgs(trailingOnly=TRUE) #remember need this to use the args from the slurm script

#HPC - the slurm script version
in_dir <- paste0(args[1])
out_dir <- paste0(args[2])
out_dir_summary <- paste0(args[3])

#laptop, local trouble shooting
# in_dir <- "C:/Users/klongnecker/Documents/Dropbox/XX_DOMsynthesis_GreeceMtg/_data_from_2"
# out_dir = "C:/Users/klongnecker/Documents/Dropbox/XX_DOMsynthesis_GreeceMtg/testing/"
# out_dir_summary = "C:/Users/klongnecker/Documents/Dropbox/XX_DOMsynthesis_GreeceMtg/testing2/"

# Loading in ICR data (data here: in_dir)
data = read.csv(list.files(path = in_dir,pattern = "DOM_Synthesis_Data_Trim.csv",full.names=TRUE), row.names = 1) # Keeping data and mol-data seperate to ensure they are unaltered
mol = read.csv(list.files(path = in_dir,pattern = "DOM_Synthesis_Mol_Trim",full.names=TRUE), row.names = 1)

# Loading in transformations
trans.full =  read.csv(list.files(path = in_dir,pattern= "Transformation_Database_07-2020.csv",full.names=TRUE))
trans.full$Name = as.character(trans.full$Name)

# Load metadata object
file_list <- paste0("samplesToProcess",".txt")
files <- read.table(file = file_list,sep="\t",header=TRUE)

# File to process based on array number
f<- as.numeric(paste0(args[4]))
current.sample <- files[f,]

###########################################
### Running through the transformations ###
###########################################

# # pull out just the sample names
#KL note - this is now in the step1 R script
# samples.to.process = colnames(data)

# error term
error.term = 0.000010

# matrix to hold total number of transformations for each sample
tot.trans = numeric()

# matrix to hold transformation profiles
#profiles.of.trans = trans.full
#head(profiles.of.trans)

#for loop started here (in asReceived code)
  #current.sample <- samples.to.process[idx] #KL added for testing one sample
  #set current sample above

  print(date())

  one.sample.matrix = cbind(as.numeric(as.character(row.names(data))), data[,which(colnames(data) == current.sample), drop = FALSE]) # "drop = FALSE" ensures that the row and column names remain associated with the data

  colnames(one.sample.matrix) = c("peak", colnames(one.sample.matrix[2]))
  # print(head(one.sample.matrix))
  
  Sample_Peak_Mat <- one.sample.matrix %>% gather("sample", "value", -1) %>% filter(value > 0) %>% select(sample, peak)
  
  #take this out...run all samples, this was because of limits on running on a laptop
  #if (nrow(Sample_Peak_Mat >= 2) & nrow(Sample_Peak_Mat) < 5000) {
  #still require 2 rows bc need two to anything
  if (nrow(Sample_Peak_Mat >= 2)) {
    
    ##
    Distance_Results <- Sample_Peak_Mat %>% left_join(Sample_Peak_Mat, by = "sample") %>% filter(peak.x > peak.y) %>% mutate(Dist = peak.x - peak.y) %>% select(sample, Dist,peak.x,peak.y)
    Distance_Results$Dist.plus = Distance_Results$Dist + error.term
    Distance_Results$Dist.minus = Distance_Results$Dist - error.term
    Distance_Results$Trans.name = -999
    head(Distance_Results)
    
    dist.unique = unique(Distance_Results[,'sample']) #unique samples
    
    date()
    
    # Finding transformations which match observed mass differences (within error)
    #KL note: use sapply, easier than trying to install pbapply on the HPC, FYI: slow step
    mass.diff <- sapply(X = trans.full$Mass, function(x) which(Distance_Results$Dist.plus >= x & Distance_Results$Dist.minus <= x), USE.NAMES = T)
    
    # Setting names of resulting list
    names(mass.diff) = trans.full$Name
    
    # Unlisting the new list
    mass.diff = data.frame(Trans.name = rep(names(mass.diff), sapply(mass.diff, length)), Position = unlist(mass.diff)) # Transformations that don't match fall out at this step
    
    # Setting the matching transformations
    Distance_Results$Trans.name[mass.diff$Position] = as.character(mass.diff$Trans.name)
    
    Distance_Results = Distance_Results[-which(Distance_Results$Trans.name == -999),]
    head(Distance_Results)
    
    #write.csv(Distance_Results,paste(output_dir,"/Transformation Peak Comparisons/",Sample_Name,"/Peak.2.Peak_",dist.unique,".csv",sep=""),quote = F,row.names = F)
    write.csv(Distance_Results,paste(out_dir,"Peak.2.Peak_",dist.unique,".csv",sep=""),quote = F,row.names = F)
    
    # sum up the number of transformations and update the matrix
    #tot.trans = rbind(tot.trans,c(dist.unique,nrow(Distance_Results),nrow(Sample_Peak_Mat),nrow(Distance_Results)/nrow(Sample_Peak_Mat)))
    #change this - export out one line and use that to assemble the details needed from each sample later
    tot.trans <- c(dist.unique,nrow(Distance_Results),nrow(Sample_Peak_Mat),nrow(Distance_Results)/nrow(Sample_Peak_Mat))
    #make this one row, with headers
    tot.trans <- t(tot.trans)
    colnames <- c("dist.unique","nDistance_Results","n_Sample_Peak_Mat","n_ratio")
    colnames(tot.trans) <- colnames 
    #now write that to a text file
    write.csv(tot.trans,paste(out_dir_summary,"Summary_",dist.unique,".csv",sep=""),quote = F,row.names = F)
    
  }
  