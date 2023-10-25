# identify samples not run for transformation analyses

# currently complete transformation analyses
curr.trans.done = read.csv("DOM_Syn_Trans_Total_Transformations_Temp.csv")

# read in data file with sample names and drop samples with no formula
data = read.csv(list.files(pattern = "_Data_Trim"), row.names = 1) # Keeping data and mol-data seperate to ensure they are unaltered
formula.per.sample = colSums(data)
samples.to.drop = names(formula.per.sample)[which(formula.per.sample == 0)]
data = data[,-which(colnames(data) %in% samples.to.drop)]

# drop samples already done
formula.per.sample = colSums(data)

samples.to.run = formula.per.sample[-which(names(formula.per.sample) %in% curr.trans.done$sample)]
head(samples.to.run)
length(samples.to.run)

# format and write
samples.to.run = as.data.frame(samples.to.run)
samples.to.run$sample = rownames(samples.to.run) 
colnames(samples.to.run)[which(colnames(samples.to.run) == 'samples.to.run')] = 'richness'
head(samples.to.run)

write.csv(samples.to.run,"Trans_Samples_to_Run.csv",row.names = F,quote=F)

