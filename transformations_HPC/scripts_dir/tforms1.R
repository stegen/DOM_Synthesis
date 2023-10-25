# Set up R script from James Stegen (PNNL) R script on transformations for an HPC
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
#HPC - the hard coded version
in_dir <- "/proj/omics/kujawinski/data/DOMsynthesis"
out_dir <- "/vortexfs1/home/klongnecker/DOM_Synthesis/transformations_HPC/output_dir/"
#HPC - the slurm script version
#in_dir <- paste0(args[1])
#out_dir <- paste0(args[2])

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

###########################################
### Running through the transformations ###
###########################################

# pull out just the sample names
samples.to.process = colnames(data)

# error term
error.term = 0.000010

# matrix to hold total number of transformations for each sample
tot.trans = numeric()

# matrix to hold transformation profiles
#profiles.of.trans = trans.full
#head(profiles.of.trans)

counter = 0

#as received
#for (current.sample in samples.to.process) {

#from James (testing), this sample will work: Behnke2022_2020February20NegESI_Fen_OiL_0724_i.corems
idx <- 2

#KL changed syntax a little because my brain operates this way
#for (i in 1:length(samples.to.process)) {
  
  current.sample <- samples.to.process[idx] #KL added for testing one sample

counter = counter + 1

print(date())

one.sample.matrix = cbind(as.numeric(as.character(row.names(data))), data[,which(colnames(data) == current.sample), drop = FALSE]) # "drop = FALSE" ensures that the row and column names remain associated with the data
colnames(one.sample.matrix) = c("peak", colnames(one.sample.matrix[2]))
# print(head(one.sample.matrix))

Sample_Peak_Mat <- one.sample.matrix %>% gather("sample", "value", -1) %>% filter(value > 0) %>% select(sample, peak)

if (nrow(Sample_Peak_Mat >= 2) & nrow(Sample_Peak_Mat) < 5000) {
  
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
  
  # Alternative .csv writing
  # write.csv(Distance_Results,paste("Transformation Peak Comparisons/", "Peak.2.Peak_",dist.unique,".csv",sep=""),quote = F,row.names = F)
  
  # sum up the number of transformations and update the matrix
  tot.trans = rbind(tot.trans,c(dist.unique,nrow(Distance_Results),nrow(Sample_Peak_Mat),nrow(Distance_Results)/nrow(Sample_Peak_Mat)))
  
  ##### write out current tot.trans in case crash
  #KL turn this off for now
 #  # format the total transformations matrix and write it out
 #  tot.trans.out = as.data.frame(tot.trans)
 #  colnames(tot.trans.out) = c('sample','total.transformations','num.of.formulas','normalized.trans')
 #  tot.trans.out$sample = as.character(tot.trans.out$sample)
 #  tot.trans.out$total.transformations = as.numeric(as.character(tot.trans.out$total.transformations))
 # # write.csv(tot.trans.out,paste(output_dir,"/",Sample_Name,"_Total_Transformations_Temp.csv", sep=""),quote = F,row.names = F)
 #  write.csv(tot.trans.out,paste(Sample_Name,"_Total_Transformations_Temp.csv", sep=""),quote = F,row.names = F)
 #  
  #####
  
  #pulled text that was commented out - in tforms2.R for now
  print(dist.unique)
  print(date())
  
}

print(counter)

#} end #close the loop starting: for (current.sample in samples.to.process) { 


