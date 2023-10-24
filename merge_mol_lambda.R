# merging Mol file and select variables from lambda script
# specific to the DOM synthesis effort

mol.in = read.csv("Merged_Processed_Mol - 10-19-23.csv")
lambda.in = read.csv("DOM_Synthesis_Lambda.csv")

out = merge(mol.in,lambda.in,by = 'MolForm')

write.csv(out,file = "Merged_Processed_Mol_Lambda - 10-19-23.csv")
