### Determing carbon transformations ###
rm(list=ls(all=T))
library(dplyr)
library(tidyr)
library(pbapply)

options(digits=10) # Sig figs in mass resolution data

Sample_Name = 'DOM_Syn_Trans'

#######################
### Loading in data ###
#######################

# if running in pieces, reload the previous output
reload.trans.temp = T
if (reload.trans.temp == T) {
  
  trans.temp = read.csv("DOM_Syn_Trans_Total_Transformations_Temp.csv")
  
}


# Loading in ICR data

reload.files = T

if (reload.files == T) {
  
  data = read.csv(list.files(pattern = "_Data_Trim"), row.names = 1) # Keeping data and mol-data seperate to ensure they are unaltered
  formula.per.sample = colSums(data)
  samples.to.drop = names(formula.per.sample)[which(formula.per.sample == 0)]
  data = data[,-which(colnames(data) %in% samples.to.drop)]
  
  mol = read.csv(list.files(pattern = "_Mol_Trim"), row.names = 1)

  data[1:5,1:5]
  mol[1:5,1:5]

}

# Loading in transformations
trans.full =  read.csv("Transformation_Database_07-2020.csv")
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

# Creating output directories
if(!dir.exists("Transformation Peak Comparisons")){
  dir.create("Transformation Peak Comparisons")
}

if(!dir.exists("Transformations per Peak")){
  dir.create("Transformations per Peak")
}


###########################################
### Running through the transformations ###
###########################################

# pull out just the sample names
sample.to.restart = 'SO245_masslistsSO245.SPE002_028_01_1367.corems'
samples.to.process = colnames(data)[which(colnames(data) == sample.to.restart):ncol(data)]

# error term
error.term = 0.000010

# matrix to hold total number of transformations for each sample
tot.trans = numeric()

# matrix to hold transformation profiles
#profiles.of.trans = trans.full
#head(profiles.of.trans)

counter = 0

for (current.sample in samples.to.process) {
  
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
    op <- pboptions(type = "timer") # default
    system.time(mass.diff <- pbsapply(X = trans.full$Mass, function(x) which(Distance_Results$Dist.plus >= x & Distance_Results$Dist.minus <= x), USE.NAMES = T))
    pboptions(op)
    
    # Setting names of resulting list
    names(mass.diff) = trans.full$Name
  
    # Unlisting the new list
    mass.diff = data.frame(Trans.name = rep(names(mass.diff), sapply(mass.diff, length)), Position = unlist(mass.diff)) # Transformations that don't match fall out at this step
  
    # Setting the matching transformations
    Distance_Results$Trans.name[mass.diff$Position] = as.character(mass.diff$Trans.name)
  
    Distance_Results = Distance_Results[-which(Distance_Results$Trans.name == -999),]
    head(Distance_Results)
  
    # Creating directory if it doesn't exist, prior to writing the output file
    if(length(grep(Sample_Name,list.dirs("Transformation Peak Comparisons", recursive = F))) == 0){
      dir.create(paste("Transformation Peak Comparisons/", Sample_Name, sep=""))
      print("Directory created")
    }

    write.csv(Distance_Results,paste("Transformation Peak Comparisons/",Sample_Name,"/Peak.2.Peak_",dist.unique,".csv",sep=""),quote = F,row.names = F)

    # Alternative .csv writing
    # write.csv(Distance_Results,paste("Transformation Peak Comparisons/", "Peak.2.Peak_",dist.unique,".csv",sep=""),quote = F,row.names = F)
  
    # sum up the number of transformations and update the matrix
    #tot.trans = rbind(tot.trans,c(dist.unique,nrow(Distance_Results),nrow(Sample_Peak_Mat),nrow(Distance_Results)/nrow(Sample_Peak_Mat)))
    tot.trans = c(dist.unique,nrow(Distance_Results),nrow(Sample_Peak_Mat),nrow(Distance_Results)/nrow(Sample_Peak_Mat))
    
    
    ##### write out current tot.trans in case crash
    # format the total transformations matrix and write it out
    tot.trans.out = as.data.frame(t(as.data.frame(tot.trans)))
    colnames(tot.trans.out) = c('sample','total.transformations','num.of.formulas','normalized.trans')
    tot.trans.out$sample = as.character(tot.trans.out$sample)
    tot.trans.out$total.transformations = as.numeric(as.character(tot.trans.out$total.transformations))
    #write.csv(tot.trans.out,paste(Sample_Name,"_Total_Transformations_Temp2.csv", sep=""),quote = F,row.names = F)
    write.table(tot.trans.out,paste(Sample_Name,"_Total_Transformations_Temp.csv", sep=""),sep=",",col.names=F,quote = F,row.names = F,append = T)
    
    
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
  
}

# format the total transformations matrix and write it out
#tot.trans = as.data.frame(tot.trans)
#colnames(tot.trans) = c('sample','total.transformations','num.of.formulas','normalized.trans')
#tot.trans$sample = as.character(tot.trans$sample)
#tot.trans$total.transformations = as.numeric(as.character(tot.trans$total.transformations))
#str(tot.trans)

#tot.trans.merged = rbind(tot.trans,trans.temp)

#write.csv(tot.trans.merged,paste(Sample_Name,"_Total_Transformations.csv", sep=""),quote = F,row.names = F)

# write out the trans profiles across samples
#write.csv(profiles.of.trans,paste(Sample_Name, "_Trans_Profiles.csv", sep=""),quote = F,row.names = F)


