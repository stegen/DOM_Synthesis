#!/usr/bin/env Rscript

rep = commandArgs();
rep = as.numeric(rep[length(rep)]);

library(permute,lib.loc="~/Rlibs");
library(gee,lib.loc="~/Rlibs");
library(vegan,lib.loc="~/Rlibs");
library(ape,lib.loc="~/Rlibs");
library(picante,lib.loc="~/Rlibs");

print(date());

# put in data set specific OTU table name
otu = read.table(" XXX .txt",row.names=1,header=T) 
print(dim(otu))

# put in data set specific OTU tree
tree = read.tree(" XXX .tree")

match.phylo.otu = match.phylo.data(tree, otu); str(match.phylo.otu); 

rand.weighted.beta.mntd = as.matrix(comdistnt(comm = t(match.phylo.otu$data), dis = taxaShuffle(cophenetic(match.phylo.otu$phy)), abundance.weighted = T)); ## randomized beta.mntd

write.csv(rand.weighted.beta.mntd,paste("bMNTD_weighted_rep_",rep,".csv",sep=""),quote=F);

print(date());

