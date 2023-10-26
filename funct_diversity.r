library(vegan)
#library(pbapply)
#library(parallel)
setwd('C:\\Users\\atanz\\Documents\\DOM synthesis data\\')

# group habitat types
metad$type[which(metad$type=='snow' | metad$type=='rainwater')] <- 'precip'

################################################################
alld <- read.csv('DOM_Synthesis_Data_Trim.csv')
formd <- read.csv('DOM_Synthesis_Mol_Trim.csv')

# check everything in the same order
all(alld$X == formd$X)

# check if any empty samples and drop
alld <- alld[,which(colSums(alld)!=0)]

# what is the number of MF per sample
per_samp_mf <- apply(alld[,-1],2,function(x){sum(x>0)})
hist(per_samp_mf)

study_names <- sapply(strsplit(colnames(alld[-1]),'_'),function(x)x[1])

# what is the number of MF per study
per_study_mf <- sapply(names(table(study_names)), function(x){
	sum(apply(alld[,-1][,which(study_names==x)],1,function(y){any(y>0)})>0)
	})

# what is the number of P per study
per_study_P <- sapply(names(table(study_names)), function(x){
		all_MF <- apply(alld[,-1][,which(study_names==x)],2,function(y){
					mols <- formd[which(y>0),'Molecular.Formula']
					})
		sum(formd[match(unique(unlist(all_MF)), formd$Molecular.Formula),'P'])/length(unique(unlist(all_MF)))
		})


########################################################################################
# Modified from https://gist.github.com/jslefche/09756ff84afc7b6a82ea0582e663d098 
raoQ = function(abund, trait, Hill = TRUE, scale = FALSE, method = "default", pres_abs = TRUE) {
  abund <- as.matrix(abund)
  anames <- colnames(abund)[order(colnames(abund))]
  abund <- abund[, anames, drop = FALSE]
  trait <- as.matrix(trait)
  trait <- trait[anames, anames]
  if(ncol(abund) != ncol(trait))
    stop("Not all species in the abundance matrix appear in the trait matrix!") 
  if(pres_abs == FALSE)
    abund <- abund / rowSums(abund)
  if(method == "default")
  Q <- sapply(1:nrow(abund), function(x){
			print(x);
			subx <- as.numeric(which(abund[x,]!=0));
			crossprod(abund[x,subx], trait[subx,subx] %*% abund[x,subx])
			}) 
#   Q <- pbapply(abund, 1, function(x) crossprod(x, trait %*% x),cl=cl) # if need to run in parallel  
  if(method == "divc")
    Q <- apply(abund, 1, function(x) x %*% trait^2 %*% (x/2/sum(x)^2))
  if(Hill == TRUE) Q <- 1/(1 - Q)
  if(scale == TRUE) Q <- Q / max(Q)
  names(Q) <- rownames(abund)
  return(Q)
} 
alld_mod <- t(alld[,-1])
colnames(alld_mod) <- alld$X
nosc.rao = as.matrix(vegdist(formd$NOSC, method = 'euclidean'))
dimnames(nosc.rao) = list(formd$X,formd$X)

#cl <- makeCluster(6)
#clusterExport(cl, c("raoQ", "alld_mod", "nosc.rao"))
nosc.rao = raoQ(alld_mod, nosc.rao, Hill = F, scale = T, method = "default")

HC.rao = as.matrix(vegdist(formd$HtoC_ratio, method = 'euclidean'))
dimnames(HC.rao) = list(formd$X,formd$X)
HC.rao = raoQ(alld_mod, HC.rao, Hill = F, scale = T, method = "default")

OC_rao = as.matrix(vegdist(formd$OtoC_ratio, method = 'euclidean'))
dimnames(OC_rao) = list(formd$X,formd$X)
OC_rao = raoQ(alld_mod, OC_rao, Hill = F, scale = T, method = "default")

pairs(cbind(nosc.rao,HC.rao,OC_rao))
write.csv(cbind(nosc.rao,HC.rao,OC_rao),'fd_measures.csv'