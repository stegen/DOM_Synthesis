#nothing here for now - could become the downstream analysis of the transformations
#pulled from James' original script

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
