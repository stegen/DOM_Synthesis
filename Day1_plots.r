library(readxl)
library(ggplot2)
library(maps)
setwd('C:\\Users\\atanz\\Documents\\DOM synthesis data\\')

metad <- read_excel('metadata_merge.xlsx')

# group habitat types
metad$type[which(metad$type=='snow' | metad$type=='rainwater')] <- 'precip'

# assign to 1/2 lower DL
metad$C_pool[which(metad$C_pool=='Below_Range_Less_Than_0.45')] <- 0.45/2
# assign to 2-times upper DL
metad$C_pool[which(metad$C_pool=='Above_Range_Greater_Than_22')] <- 22*1.5

# convert TOC into common units
metad$C_con <- as.numeric(metad$C_pool)
metad$C_con[which(metad$units...25 == 'µmolL' | metad$units...25 == 'uM')] <- metad$C_con[which(metad$units...25 == 'µmolL' | metad$units...25 == 'uM')]*12.011/1000
metad$C_con[which(metad$units...25 == 'ugm3')] <- metad$C_con[which(metad$units...25 == 'ugm3')]/1000

# boxplot by habitat type
with(metad,boxplot(C_con~type,log='y',ylab='[C] (mg/L)',las=2,cex.axis=.8)) 

# convert TN/TDN into common units
metad$TN_mgL <- as.numeric(metad$N_value)
metad$TN_mgL[which(metad$units...10 == 'µmolL' | metad$units...10 == 'uM')] <- metad$TN_mgL[which(metad$units...10 == 'µmolL' | metad$units...10 == 'uM')]*14.0067/1000
metad$TN_mgL[which(metad$TN_mgL==0)] <- NA # drop three 0 values

# boxplot by habitat type
with(metad,boxplot(TN_mgL~type,log='y',ylab='[TDN/TN] (mg/L)',las=2,cex.axis=.8)) 


  
#https://www.ices.dk/data/tools/Pages/Unit-conversions.aspx
# convert TOC into common units
metad$C_con <- as.numeric(metad$C_pool)

# convert C units
metad$C_con[which(metad$units...25 == 'µmolL' | metad$units...25 == 'uM')] <- metad$C_con[which(metad$units...25 == 'µmolL' | metad$units...25 == 'uM')]*12.011/1000
metad$C_con[which(metad$units...25 == 'ugm3')] <- metad$C_con[which(metad$units...25 == 'ugm3')]/1000



################################################################
# map of study sites
world_map <- map("world", fill = TRUE, plot = FALSE)
gg <- ggplot() +
  geom_polygon(data = world_map, aes(x = long, y = lat, group = group), fill = "lightgray") +
  geom_point(data = metad, aes(x = Longitude, y = Latitude), color = "blue", size = 3, alpha = 0.2)
plot(gg)






################################################################
alld <- read.csv('Merged_Processed_Data - 10-19-23.csv')
