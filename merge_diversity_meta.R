# read in metadata. Note the 'mu' symbol needs to be manually changed to u in the file before reading in
meta = read.csv("AH_metadata_merge.csv")
dim(meta)
meta[1:5,1:5]

length(unique(meta$coreMSname))

# read in transformations
trans = read.csv("DOM_Syn_Trans_Total_Transformations_Temp.csv")
head(trans)

length(unique(trans$sample))

# merge meta with transformations
meta.trans = merge(meta,trans,by.x = 'coreMSname',by.y = 'sample',all.x=T)
dim(meta.trans)
meta.trans[1:100,c('coreMSname','global_dataset','total.transformations','num.of.formulas','normalized.trans')]
length(unique(meta.trans$coreMSname))

# find transformation samples without sample names in meta
# if all matched, will get 0
# if non-zero value, that number of samples didn't match
length(trans$sample[which(!trans$sample %in% meta.trans$coreMSname)])
miss.samples = trans$sample[which(!trans$sample %in% meta.trans$coreMSname)]
miss.samples[grep(pattern = "ECA",x = miss.samples)]

# read in Rao diversity


#meta.div = meta.trans
#plot(meta.div$num.of.formulas[grep(pattern = "mg",meta.div$units.5)] ~ log10(as.numeric(meta.div$C_pool[grep(pattern = "mg",meta.div$units.5)])))
#str(meta.div)