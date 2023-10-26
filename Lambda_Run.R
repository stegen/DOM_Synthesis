# Compute the lambda for chemical compositions

library(tidyverse)

# user parameters ------------------------------------------------------

CHEMICAL_ELEMENTS = c("C","H","N","O","P","S")
outfile <- "DOM_Synthesis_Mol_Trim_Lambda.csv"

# main run -------------------------------------------------------------

info <- get_compositions(mol)
out <- get_lambda(info$chemical_compositions)

# build data frame
df <- as.data.frame(out)

# build col names
names <- rep("", 62)

names[1:12] <- c("delGcox0","delGd0","delGcat0","delGan0","delGdis0","lambda0",
                 "delGcox","delGd","delGcat","delGan","delGdis","lambda")

stoich_colnames <- c("donor","h2o","hco3","nh4","hpo4","hs","h","e","acceptor","biom")
stoich_types <- c("stoichD","stoichA","stoichCat","stoichAn","stoichMet")

for (i in 1:length(stoich_types)) {
  names[((i-1)*10+13):(i*10+12)] <- array(sapply(stoich_types[i], paste, stoich_colnames, sep="_"))
}
colnames(df) <- names
df['MolForm'] <- info$formulas

df = df[,c("MolForm","delGcox0","delGd0","delGcat0","delGan0","delGdis0","lambda0","delGcox","delGd","delGcat","delGan","delGdis","lambda")]

# merge lambda with mol file
mol = merge(mol,df,by = 'MolForm',sort = F)
rownames(mol) = mol$X
mol = mol[,-which(colnames(mol) == 'X')]
mol[1:5,1:5]

