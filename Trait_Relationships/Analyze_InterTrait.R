# analyzing inter-trait relationships with sample-level data points and with molecule-specific data points

# read in data file with sample names and drop samples with no formula
data = read.csv(list.files(pattern = "_Data_Trim"), row.names = 1) # Keeping data and mol-data seperate to ensure they are unaltered
formula.per.sample = colSums(data)
samples.to.drop = names(formula.per.sample)[which(formula.per.sample < 500)]
data = data[,-which(colnames(data) %in% samples.to.drop)]
data[1:5,1:5]

# read in mol file with thermodynamic properties
mol = read.csv(list.files(pattern = "_Mol_Trim_Lambda"), row.names = 1)
rownames(mol) = mol$X
mol[1:5,1:5]

# check
identical(rownames(mol),rownames(data))


# read in sample-level median values
sample.level.thermo = read.csv("Trait_Relationships/DOM_Syn_Sample_Level_Themro.csv")
head(sample.level.thermo)

# merge traits with number of formula
formula.per.sample = as.data.frame(formula.per.sample)
sample.level.thermo = merge(sample.level.thermo,formula.per.sample,by.x='sample',by.y = 0)
head(sample.level.thermo)
dim(sample.level.thermo)

# meta
meta = read.csv("AH_metadata_merge.csv")
head(meta)

# merge meta and traits
meta.traits = merge(meta,sample.level.thermo,by.x = 'coreMSname',by.y = 'sample')
dim(meta.traits)

# drop samples with fewer than 500 formula
meta.traits = meta.traits[,-which(meta.traits$formula.per.sample < 500)]
dim(meta.traits)

# overall plot of lambda vs. each gibbs
plot(meta.traits$median_lambda ~ meta.traits$median_delGcox)
plot(meta.traits$median_lambda ~ meta.traits$median_delGd)

# plots within each dataset

regression.stats = numeric()

pdf("Trait_Relationships/Sample_Level_Trait_Relat.pdf",width=10)

for (i in unique(meta.traits$global_dataset)) {
  
  dat.temp = meta.traits[which(meta.traits$global_dataset == i),]
  
  par(pty="s",mfrow=c(1,2))
  mod.to.plot = dat.temp$median_lambda ~ dat.temp$median_delGcox
  plot(mod.to.plot,ylab="lambda",xlab="Gibbs per C",main=unique(dat.temp$type))
  mod.out = summary(lm(mod.to.plot))
  mtext(paste0(" R2 = ",round(mod.out$r.squared,digits = 3)),line = -1,adj = 0,side = 3)
  mtext(paste0(" p = ",round(mod.out$coefficients[2,4],digits = 2)),line = -2,adj = 0,side = 3)
  abline(mod.out)
  GperC.R2 = mod.out$r.squared
  
  mod.to.plot = dat.temp$median_lambda ~ dat.temp$median_delGd
  plot(mod.to.plot,ylab="lambda",xlab="Gibbs per Comp",main=unique(dat.temp$global_dataset))
  mod.out = summary(lm(mod.to.plot))
  mtext(paste0(" R2 = ",round(mod.out$r.squared,digits = 3)),line = -1,adj = 0,side = 3)
  mtext(paste0(" p = ",round(mod.out$coefficients[2,4],digits = 2)),line = -2,adj = 0,side = 3)
  abline(mod.out)
  GperComp.R2 = mod.out$r.squared
  
  regression.stats = rbind(regression.stats,c(unique(dat.temp$global_dataset),GperC.R2,GperComp.R2))
  
}

dev.off()

# make R2 space plot
colnames(regression.stats) = c("global_dataset","GperC.R2","GperComp.R2")
regression.stats = as.data.frame(regression.stats)
pdf("Trait_Relationships/Sample_Level_Traits_R2_Space.pdf")
par(pty="s")
plot(regression.stats$GperComp.R2 ~ regression.stats$GperC.R2,ylim=c(0,1),xlim=c(0,1),ylab="R2 Lambda V. Gibbs per Comp",xlab="R2 Lambda v. Gibbs per C")
abline(h=0.5,lty=2)
abline(v=0.5,lty=2)
dev.off()

## start into within-sample trait relationships

# there are a few peaks that have extreme values for lambda. not sure why, but removing them
peaks.to.remove = c(
  
  rownames(mol)[which(mol$lambda < 0)],
  rownames(mol)[which(mol$lambda > 1)]
  
)

mol = mol[-which(rownames(mol) %in% peaks.to.remove),]
data = data[-which(rownames(data) %in% peaks.to.remove),]
identical(rownames(mol),rownames(data))

hist(mol$delGd)
hist(mol$lamO2); range(mol$lamO2,na.rm = T); length(which(mol$lamO2 < 0)); length(which(mol$lamO2 > 1))
hist(mol$delGcoxPerCmol); range(mol$delGcoxPerCmol,na.rm = T)

# turning mol variables into z-scores. the printing should be 0 1 for each variable
mol$delGd = (mol$delGd-mean(mol$delGd,na.rm = T))/sd(mol$delGd,na.rm = T); print(c(round(mean(mol$delGd,na.rm = T),digits = 10),sd(mol$delGd,na.rm = T)))
mol$lambda = (mol$lambda-mean(mol$lambda,na.rm = T))/sd(mol$lambda,na.rm = T); print(c(round(mean(mol$lambda,na.rm = T),digits = 10),sd(mol$lambda,na.rm = T)))
mol$delGcox = (mol$delGcox-mean(mol$delGcox,na.rm = T))/sd(mol$delGcox,na.rm = T); print(c(round(mean(mol$delGcox,na.rm = T),digits = 10),sd(mol$delGcox,na.rm = T)))

#### loop through each sample and quantify the R2 and slope of the linear regression each Gibbs vs. lambda
#### compile outcomes into a dataframe

sample.reg.stats = numeric()

for (i in 1:ncol(data)) {
  
  mol.temp = mol[which(rownames(mol) %in% rownames(data)[which(data[,i] > 0)]),]
  #mol.temp = mol.temp[-which(is.na(mol.temp$lambda)==T),]
  
  #if (length(which(is.na(mol.temp) == T)) > 0) {
    
  #  print("Error: Not all NAs removed")  
  #  break()
    
  #}
  #print(c(colnames(data)[i],range(mol.temp),"last 2 must be numbers"))
  
  Comp.mol.R2 = summary(lm(mol.temp$lambda ~ mol.temp$delGd))$r.squared # R2 for Gibbs per Comp mol (pH 7)
  Comp.mol.slope = summary(lm(mol.temp$lambda ~ mol.temp$delGd))$coefficients[2,1] # slope for Gibbs per Comp mol (pH 7)
  
  C.mol.R2 = summary(lm(mol.temp$lambda ~ mol.temp$delGcox))$r.squared # R2 for Gibbs per C mol (pH 7)
  C.mol.slope = summary(lm(mol.temp$lambda ~ mol.temp$delGcox))$coefficients[2,1] # slope for Gibbs per C mol (pH 7)
  
  sample.reg.stats = rbind(sample.reg.stats,c(
    
    colnames(data)[i],
    nrow(mol.temp),
    Comp.mol.R2,
    Comp.mol.slope,
    C.mol.R2,
    C.mol.slope
    
  ))
  
}

sample.reg.stats = as.data.frame(sample.reg.stats)
colnames(sample.reg.stats) = c('Sample_ID','Num_of_formulas','Comp.mol.R2','Comp.mol.slope','C.mol.R2','C.mol.slope')
sample.reg.stats[1:ncol(sample.reg.stats)] = lapply(sample.reg.stats[1:ncol(sample.reg.stats)],as.character)
sample.reg.stats[which(colnames(sample.reg.stats) != 'Sample_ID')] = lapply(sample.reg.stats[which(colnames(sample.reg.stats) != 'Sample_ID')],as.numeric)
sample.reg.stats$Sample_ID = substring(sample.reg.stats$Sample_ID,first = 1,last = 12)
head(sample.reg.stats)

pdf("Trait_Relationships/Within_Sample_Trait_Reg.pdf")
par(pty="s")
plot(sample.reg.stats$Comp.mol.R2 ~ sample.reg.stats$C.mol.R2,ylim=c(0,1),xlim=c(0,1),ylab="R2 Lambda V. Gibbs per Comp",xlab="R2 Lambda v. Gibbs per C",cex=0.3)
abline(h=0.5,lty=2)
abline(v=0.5,lty=2)
dev.off()

pdf("Trait_Relationships/Within_Sample_Trait_Slopes.pdf")
par(pty="s")
plot(sample.reg.stats$Comp.mol.slope ~ sample.reg.stats$C.mol.slope,ylab="Slope Lambda V. Gibbs per Comp",xlab="Slope Lambda v. Gibbs per C",cex=0.3)
abline(h=0.5,lty=2)
abline(v=0.5,lty=2)
dev.off()

