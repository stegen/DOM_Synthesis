# Use this as a model for some R script to come from James to run the transformations
#KL 25 October 2023
args = commandArgs(trailingOnly=TRUE)
library(dplyr)
library(tidyr)

date()
paste("This is task", Sys.getenv('SLURM_ARRAY_TASK_ID'))

# #use these rows for troubleshooting locally
# in_dir="C:/Users/klongnecker/Documents/Dropbox/XX_DOMsynthesis_GreeceMtg/_data_from_2"
# usePath <- paste0(in_dir)
# 
# #this is the version for the HPC and the slurm script
# usePath <- paste0(args[1])
# output_dir <- paste0(args[2])

#this will get used later, but I need some input on what role this serves (beyond naming folders)
Sample_Name = 'DOM_Syn_Trans'

#######################
### Loading in data ###
#######################
#HPC
#dataPath <- "/proj/omics/kujawinski/data/DOMsynthesis/"
#laptop
dataPath <- "C:/Users/klongnecker/Documents/Dropbox/XX_DOMsynthesis_GreeceMtg/_data_from_2"

# Loading in ICR data (data are in dataPath)
data = read.csv(list.files(path = dataPath,pattern = "DOM_Synthesis_Data_Trim.csv",full.names=TRUE), row.names = 1) # Keeping data and mol-data seperate to ensure they are unaltered
mol = read.csv(list.files(path = dataPath,pattern = "DOM_Synthesis_Mol_Trim",full.names=TRUE), row.names = 1)

# Loading in transformations
trans.full =  read.csv("../Transformation_Database_07-2020.csv")
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

#output_dir

#KL turn this off for the moment, will use slurm to set output_dir
# # Creating output directories
# if(!dir.exists("Transformation Peak Comparisons")){
#   dir.create("Transformation Peak Comparisons")
# }
# 
# if(!dir.exists("Transformations per Peak")){
#   dir.create("Transformations per Peak")
# }


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

#why is this not working on the HPC? put newer tidyr into yml file...still have issues
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
  # KL note: pbsapply shows Progress Bar...want to shut that off for the HPC]
  # test sample will take about two minutes
  #op <- pboptions(type = "timer") # default
  #system.time(mass.diff <- pbsapply(X = trans.full$Mass, function(x) which(Distance_Results$Dist.plus >= x & Distance_Results$Dist.minus <= x), USE.NAMES = T))
  #pboptions(op)
  #can just use sapply, easier than trying to install pbapply on the HPC
  mass.diff <- sapply(X = trans.full$Mass, function(x) which(Distance_Results$Dist.plus >= x & Distance_Results$Dist.minus <= x), USE.NAMES = T)
  
  
  # Setting names of resulting list
  names(mass.diff) = trans.full$Name
  
  # Unlisting the new list
  mass.diff = data.frame(Trans.name = rep(names(mass.diff), sapply(mass.diff, length)), Position = unlist(mass.diff)) # Transformations that don't match fall out at this step
  
  # Setting the matching transformations
  Distance_Results$Trans.name[mass.diff$Position] = as.character(mass.diff$Trans.name)
  
  Distance_Results = Distance_Results[-which(Distance_Results$Trans.name == -999),]
  head(Distance_Results)
  
  #Turn this off for the moment
  # # Creating directory if it doesn't exist, prior to writing the output file
  # if(length(grep(Sample_Name,list.dirs("Transformation Peak Comparisons", recursive = F))) == 0){
  #   dir.create(paste(output_dir,"/Transformation Peak Comparisons/", Sample_Name, sep=""))
  #   print("Directory created")
  # }
  
  #write.csv(Distance_Results,paste(output_dir,"/Transformation Peak Comparisons/",Sample_Name,"/Peak.2.Peak_",dist.unique,".csv",sep=""),quote = F,row.names = F)
  write.csv(Distance_Results,paste("/Transformation Peak Comparisons/",Sample_Name,"/Peak.2.Peak_",dist.unique,".csv",sep=""),quote = F,row.names = F)
  
  # Alternative .csv writing
  # write.csv(Distance_Results,paste("Transformation Peak Comparisons/", "Peak.2.Peak_",dist.unique,".csv",sep=""),quote = F,row.names = F)
  
  # sum up the number of transformations and update the matrix
  tot.trans = rbind(tot.trans,c(dist.unique,nrow(Distance_Results),nrow(Sample_Peak_Mat),nrow(Distance_Results)/nrow(Sample_Peak_Mat)))
  
  ##### write out current tot.trans in case crash
  # format the total transformations matrix and write it out
  tot.trans.out = as.data.frame(tot.trans)
  colnames(tot.trans.out) = c('sample','total.transformations','num.of.formulas','normalized.trans')
  tot.trans.out$sample = as.character(tot.trans.out$sample)
  tot.trans.out$total.transformations = as.numeric(as.character(tot.trans.out$total.transformations))
 # write.csv(tot.trans.out,paste(output_dir,"/",Sample_Name,"_Total_Transformations_Temp.csv", sep=""),quote = F,row.names = F)
  write.csv(tot.trans.out,paste(Sample_Name,"_Total_Transformations_Temp.csv", sep=""),quote = F,row.names = F)
  
  #####
  
  # generate transformation profile for the sample
  #trans.profile = as.data.frame(tapply(X = Distance_Results$Trans.name,INDEX = Distance_Results$Trans.name,FUN = 'length')); head(trans.profile)
  #colnames(trans.profile) = dist.unique
  #head(trans.profile)
  
  # update the profile matrix
  #profiles.of.trans = merge(x = profiles.of.trans,y = trans.profile,by.x = "Name",by.y = 0,all.x = T)
  #profiles.of.trans[is.na(profiles.of.trans[,dist.unique]),dist.unique] = 0
  #head(profiles.of.trans)
  #str(profiles.of.trans)
  
  # find the number of transformations each peak was associated with
  #peak.stack = as.data.frame(c(Distance_Results$peak.x,Distance_Results$peak.y)); head(peak.stack)
  #peak.profile = as.data.frame(tapply(X = peak.stack[,1],INDEX = peak.stack[,1],FUN = 'length' )); dim(peak.profile)
  #colnames(peak.profile) = 'num.trans.involved.in'
  #peak.profile$sample = dist.unique
  #peak.profile$peak = row.names(peak.profile)
  #head(peak.profile);
  
  # Creating directory if it doesn't exist, prior to writing the output file
  #if(length(grep(Sample_Name,list.dirs("Transformations per Peak", recursive = F))) == 0){
  #  dir.create(paste("Transformations per Peak/", Sample_Name, sep=""))
  #  print("Directory created")
  #}
  
  # Writing data to newly created directory
  #write.csv(peak.profile,paste("Transformations per Peak/",Sample_Name,"/Num.Peak.Trans_",dist.unique,".csv",sep=""),quote = F,row.names = F)
  
  # Alternative .csv writing
  # write.csv(peak.profile,paste("Transformations per Peak/", "Num.Peak.Trans_",dist.unique,".csv",sep=""),quote = F,row.names = F)
  
  print(dist.unique)
  print(date())
  
}

print(counter)

#} end #end of loop starting: for (current.sample in samples.to.process) { 

# format the total transformations matrix and write it out
tot.trans = as.data.frame(tot.trans)
colnames(tot.trans) = c('sample','total.transformations','num.of.formulas','normalized.trans')
tot.trans$sample = as.character(tot.trans$sample)
tot.trans$total.transformations = as.numeric(as.character(tot.trans$total.transformations))
str(tot.trans)

# #KL where does trans.temp come from? only have prior...think about this later
# tot.trans.merged = rbind(tot.trans,trans.temp)
# write.csv(tot.trans.merged,paste(Sample_Name,"_Total_Transformations.csv", sep=""),quote = F,row.names = F)
write.csv(tot.trans,paste(Sample_Name,"_Total_Transformations.csv", sep=""),quote = F,row.names = F)

# write out the trans profiles across samples
#write.csv(profiles.of.trans,paste(Sample_Name, "_Trans_Profiles.csv", sep=""),quote = F,row.names = F)





# Biocparallel setting
register(BPPARAM = MulticoreParam(workers=36))

data = read.csv(list.files(path = dataPath,pattern = "DOM_Synthesis_Data_Trim.csv",full.names=TRUE), row.names = 1) # Keeping data and mol-data seperate to ensure they are unaltered
mol = read.csv(list.files(path=dataPath,pattern = "DOM_Synthesis_Mol_Trim",full.names=TRUE), row.names = 1)



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
