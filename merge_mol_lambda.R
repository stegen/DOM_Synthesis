# merging Mol file and select variables from lambda script
# specific to the DOM synthesis effort

mol.in = read.csv("DOM_Synthesis_Mol_Trim.csv")
lambda.in = read.csv("DOM_Synthesis_Lambda.csv")

out = merge(mol.in,lambda.in,by = 'MolForm',sort = F)

identical(mol.in$MolForm,out$MolForm)

write.csv(out,file = "DOM_Synthesis_Mol_Trim_Lambda.csv")
