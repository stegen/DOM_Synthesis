# this calculates sample level mean values of molecular traits/properties

# read in data file with sample names and drop samples with no formula
data = read.csv(list.files(pattern = "_Data_Trim"), row.names = 1) # Keeping data and mol-data seperate to ensure they are unaltered
formula.per.sample = colSums(data)
samples.to.drop = names(formula.per.sample)[which(formula.per.sample == 0)]
data = data[,-which(colnames(data) %in% samples.to.drop)]
data[1:5,1:5]

# read in mol file with thermodynamic properties
mol = read.csv(list.files(pattern = "_Mol_Trim_Lambda"), row.names = 1)
rownames(mol) = mol$X
mol[1:5,1:5]

# check
identical(rownames(mol),rownames(data))

# setup data frame
sample.level.mean.trait.matrix = data.frame('sample' = colnames(data))

# function for sample level mean

sample.level.mean.trait.fun = function(data.out=sample.level.mean.trait.matrix,col.in=col.in,data.in=data,mol.in=mol) {

  data.out[,paste0("median_",col.in)] = NA
   
  for (i in colnames(data.in)) {
    
    samp.formula = rownames(data.in)[which(data[,i] > 0)]
    samp.traits = mol[which(rownames(mol) %in% samp.formula),col.in]
    samp.median.trait = median(samp.traits,na.rm = T)
    data.out[which(data.out$sample == i),paste0("median_",col.in)] = samp.median.trait
    #print(head(data.out))
    
  }
  
  return(data.out)
  
}

# loop over traits
for (curr.trait in c("delGcox","delGd","lambda")) {

  sample.level.mean.trait.matrix = sample.level.mean.trait.fun(data.out = sample.level.mean.trait.matrix,
                                                             col.in=curr.trait,
                                                             data.in=data,
                                                             mol.in=mol)
  print(head(sample.level.mean.trait.matrix))
  
}

head(sample.level.mean.trait.matrix)

# write out
write.csv(sample.level.mean.trait.matrix,"Trait_Relationships/DOM_Syn_Sample_Level_Themro.csv",row.names=F)
