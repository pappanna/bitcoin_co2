#############################################################################################
# Bitcoin and CO2 emissions 
# Anna Papp (ap3907@columbia.edu)
# External validity and context - co2 intensity for balancing authorities 
# Requires: 
# -- data/ba_carbon_accounting/ (annual emissions from Singularity Data)
# last modified 08/15/23
#############################################################################################

# Setup -------------------------------------------------------------------------------------

## clear variables in environment and script 
rm(list=ls(all=TRUE)); cat("\014") 

## load packages
if(!require(pacman)) install.packages('pacman') 
pacman::p_load( data.table,ggplot2, dplyr, gamlr, nnet, imputeTS, caret, scales, ggthemes, foreign, ggrepel, readr, tidyr, plm, broom, dplyr, Hmisc, sqldf, stargazer, stringr, zoo, glmnet, import, lubridate, ncdf4, raster, lfe, sjPlot, tigris, rgdal, GGally, dotwhisker,choroplethr, choroplethrMaps, splines, fixest, sf,ggpubr, car, geojsonsf, rgeos, rmapshaper, readxl, usmap)    

## directory 
if(Sys.info()["user"] == "annapapp") {
  setwd('/Users/annapapp/Library/CloudStorage/GoogleDrive-ap3907@columbia.edu/My Drive/PhD/01_research/00_research/09_crypto/crypto_jpube') # anna WD
} else {
  setwd('/[OTHER USER]') 
}

# Load Balancing Authority CO2 Intensity Data  ----------------------------------------------

bas <- c("AEC", "AECI", "AVA", "AZPS", "BANC", "BPAT", "CHPD", "CISO", "CPLE", "CPLW", "DOPD", "DUK", "EPE", "ERCO", "FMPP", "FPC", "FPL",
         "GCPD", "GVL", "HST", "IID", "IPCO", "ISNE", "JEA", "LDWP", "LGEE", "MISO", "NEVP", "NWMT", "NYIS", "PACE", "PACW", "PGE", "PJM", 
         "PNM", "PSCO", "PSEI", "SC", "SCEG", "SCL", "SEC", "SOCO", "SPA", "SRP", "SWPP", "TAL", "TEC", "TEPC", "TIDC", "TPWR", "TVA", 
         "WACM", "WALC", "WAUW")

data <- data.frame()


for(baName in bas){
  
  ba <- read.csv(paste0("data/ba_carbon_accounting/", baName, ".csv"))
  ba <- ba %>% dplyr::select(co2Rate = consumed_co2_rate_lb_per_mwh_for_electricity)
  ba <- ba %>% mutate(ba = baName)
  ba <- ba %>% mutate(co2Rate = co2Rate * 0.453592 / 1000)
  
  data <- rbind(data, ba)
  
}
rm(ba)

# Load Balancing Authority CO2 Intensity Data  ----------------------------------------------

colors <- c("Cryptomining Activity" = "#CC6677", "Other" = "#88CCEE")

ggplot(data, aes(x=co2Rate)) + 
  geom_histogram(bins = 25, position = "stack", fill="#88CCEE") + 
  geom_vline(xintercept = 0.48, linetype = "dashed", color="#882255")+
  xlab("Avg. Carbon Intensity (kg CO2 per kWh)") + ylab("Count") + 
  theme_bw() + 
  theme(legend.position = "bottom", 
        axis.text.x=element_text(size = 14), 
        axis.text.y=element_text(size = 16), 
        axis.title.x=element_text(size = 14), 
        axis.title.y=element_text(size = 16),
        legend.text=element_text(size=12), 
        legend.title=element_text(size=16)) 

# APPENDIX FIGURE A8
ggsave(file="output/03_context_extvalidity/03_ba_distribution.png", width=12, height = 6)
