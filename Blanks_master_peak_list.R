##set working directory to project folder
setwd("~/Desktop/Greece/Greece")
#import Assigned Peak list with theoretical MZ for samples (only needs to be presence absence)
#and import Molecular formulae assignments 
Peak_List <- read.csv("~/Desktop/Greece/Greece/DOM_Synthesis_Data_Trim.csv")
MF <- read.csv("~/Desktop/Greece/Greece/DOM_Synthesis_Mol_Trim.csv")
#subset Peak_list to blanks only (can add any other names of blanks into code below within "" with extra |)
Blanks_Peak_List=Peak_List[,grep("Blank|blank|DI",colnames(Peak_List))]
#Add molecular formulae column to Blanks_Peak_list 
#Add  theoretical MZ column to Blanks_Peak_list
Blanks_Peak_List$Molecular.Formula=MF$Molecular.Formula
Blanks_Peak_List$Theor_MZ=MF$X

#reorder Blanks_Peak_List so MF and MZ first (just because it's easier to see :D)
lc=length(Blanks_Peak_List)
Blanks_Peak_List=Blanks_Peak_List[,c(lc,(lc-1),(1:(lc-2)))]

##subset dataframe where peaks is present in at least 1 blank 
#and sum number of times peak
##is present across dataset
Blanks_Peak_List$Frequency=rowSums(Blanks_Peak_List[,(3:lc)])
Blanks_Peak_List=subset(Blanks_Peak_List,Blanks_Peak_List$Frequency>0)





