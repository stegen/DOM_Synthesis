# read in data...note that this read in was not rechecked as it was done in another script, and the files are huge
data = read.csv(list.files(pattern = "_Data "), row.names = 1) # Keeping data and mol-data seperate to ensure they are unaltered
mol = read.csv(list.files(pattern = "_Mol "), row.names = 1)

# QC data matrix

formula.drop.matrix = data.frame('singleton' = rep(NA,nrow(mol)),'P'= rep(NA,nrow(mol)), 'HtoC' = rep(NA,nrow(mol)), 'OtoC' = rep(NA,nrow(mol)), 'DBE_1' = rep(NA,nrow(mol)), 'DBE_O' = rep(NA,nrow(mol)), 'mass' = rep(NA,nrow(mol)),row.names = rownames(mol))

# define singletons
formula.occurence = rowSums(x = data)
head(formula.occurence)
singletons = formula.occurence[which(formula.occurence <= 1)]
head(singletons)
formula.drop.matrix$singleton[which(rownames(formula.drop.matrix) %in% names(singletons))] = 1

# define P formulas
p.formulas = rownames(mol)[which(mol$P > 0)]
formula.drop.matrix$P[which(rownames(formula.drop.matrix) %in% p.formulas)] = 1

# define masses out of range
bad.mass.formulas = rownames(mol)[which(as.numeric(rownames(mol)) < 200 | as.numeric(rownames(mol)) > 800)]
formula.drop.matrix$mass[which(rownames(formula.drop.matrix) %in% bad.mass.formulas)] = 1

# define O:C 
OC.formulas = rownames(mol)[which(mol$OtoC_ratio > 1)]
formula.drop.matrix$OtoC[which(rownames(formula.drop.matrix) %in% OC.formulas)] = 1

# define H:C
HC.formulas = rownames(mol)[which(mol$HtoC_ratio > 2.5 | mol$HtoC_ratio < 0.3)]
formula.drop.matrix$HtoC[which(rownames(formula.drop.matrix) %in% HC.formulas)] = 1

# define DBE minus C
DBE.C.formulas = rownames(mol)[which(mol$DBE_1 <= I(mol$C*0.6 - 15))]
formula.drop.matrix$DBE_1[which(rownames(formula.drop.matrix) %in% DBE.C.formulas)] = 1

# define DBE minus O
DBE.O.formulas = rownames(mol)[which(mol$DBE_O < I(-10) | mol$DBE_O > 10)]
formula.drop.matrix$DBE_O[which(rownames(formula.drop.matrix) %in% DBE.O.formulas)] = 1

# number of drops per filter
colSums(x = formula.drop.matrix,na.rm = T)
#singleton         P      HtoC      OtoC     DBE_1     DBE_O      mass 
#80211    104223       244      4941     20441     92566     54028 

# number of filters per formula
filters.per.formula = rowSums(x = formula.drop.matrix,na.rm = T)
range(filters.per.formula)
formula.to.drop = names(filters.per.formula)[which(filters.per.formula > 0)]
length(formula.to.drop)

# trim down mol
mol.trim = mol[-which(rownames(mol) %in% formula.to.drop),]
dim(mol.trim)
summary(mol.trim)

# make Van-K plot
plot(mol.trim$HtoC_ratio ~ mol.trim$OtoC_ratio,cex=0.3)

# trim down the data file
data.trim = data[which(rownames(data) %in% rownames(mol.trim)),]
dim(data.trim)

# look at formula richness distribution
sample.richness = colSums(x = data.trim)
hist(sample.richness)

# needs to be True
identical(x = row.names(data.trim), y = row.names(mol.trim))

# write out files
write.csv(x = mol.trim,file = "DOM_Synthesis_Mol_Trim.csv")
write.csv(x = data.trim,file = "DOM_Synthesis_Data_Trim.csv")
